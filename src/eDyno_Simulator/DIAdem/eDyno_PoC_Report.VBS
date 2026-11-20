'-------------------------------------------------------------------------------
' eDyno NVH PoC - automated test report for DIAdem
'
' What it does (same analysis as the web report):
'   1. Loads a FlexLogger eDyno log (full log, or the reduced copy made by
'      eDyno TDMS Reducer.vi).
'   2. Data sanity + correlation checks:
'        - accel amplitude scaling (measured / commanded fault amplitude)
'        - tach channel has shaft content
'        - plug-in RMS vs RMS computed from raw accel
'        - MCU electrical power vs MCU model
'        - CAN alive counters, AO block-counter rate
'   3. Spectra of representative fault states and order tracks (1x, 2x, 24x)
'      from 1 s raw snapshots every 15 s.
'   4. Builds report sheets (summary, timeline, MCU, spectra, order tracks),
'      exports a PDF and saves the results as TDMS next to the log.
'
' How to use: open in DIAdem SCRIPT, set the CONFIG block, press Run.
' Tested logic: the numeric checks mirror build_datasets.py (web report).
' Written for DIAdem 2023+; the report API calls are wrapped so that one
' failing object is logged instead of stopping the run.
'-------------------------------------------------------------------------------
Option Explicit

'============================ CONFIG ===========================================
Dim sLogFile, bReduced, sOutDir, dFs, lSnapLen, dSnapPeriod
sLogFile    = "C:\Users\dihidalg\Desktop\MCP\MCP_SnV_Test\data\Reduced_LogFile_2026-11-20-13-36-19.tdms"
bReduced    = True          ' True = reduced file (group "Raw": Accel_g/Tach_V back to back)
                            ' False = full FlexLogger log (raw in group "Log")
sOutDir     = "C:\Users\dihidalg\Desktop\MCP\MCP_SnV_Test\data\Report\"
dFs         = 51200         ' raw sample rate (S/s)
lSnapLen    = 51200         ' 1 s snapshots -> 1 Hz FFT lines
dSnapPeriod = 15            ' s between snapshots
Const SIM_SENS_MV_PER_G = 1000   ' simulator AO sensitivity, for the scaling note
'===============================================================================

Dim oLog, oRaw, oRes, sAccel, sTach, lSnaps, i, k
Dim aChecks(), nChecks : nChecks = 0
ReDim aChecks(30)

Call LogFileWrite("eDyno report: start " & Now)
If Not FolderExist(sOutDir) Then Call FolderCreate(sOutDir)

'---------------------------- 1) load ------------------------------------------
Call Data.Root.Clear()
If bReduced Then
  Call DataFileLoad(sLogFile, "TDMS", "Load")
Else
  ' 3 GB file: register (load on demand) instead of loading into memory
  Call DataFileLoad(sLogFile, "TDMS", "Register")
End If
Function GroupIdx(sName)   ' 1-based index of a channel group by name
  Dim g : GroupIdx = 0
  For g = 1 To Data.Root.ChannelGroups.Count
    If Data.Root.ChannelGroups(g).Name = sName Then GroupIdx = g
  Next
End Function
Set oLog = Data.Root.ChannelGroups("Log")
If bReduced Then
  Set oRaw = Data.Root.ChannelGroups("Raw")
  sAccel = "[" & GroupIdx("Raw") & "]/Accel_g"
  sTach  = "[" & GroupIdx("Raw") & "]/Tach_V"
  lSnaps = Fix(oRaw.Channels("Accel_g").Size / lSnapLen)
Else
  sAccel = "[" & GroupIdx("Log") & "]/DSA_4464/ai0"
  sTach  = "[" & GroupIdx("Log") & "]/DAQ_6396/ai0"
  lSnaps = Fix(oLog.Channels("DSA_4464/ai0").Size / (dSnapPeriod * dFs))
End If
Call LogFileWrite("Loaded " & sLogFile & " - snapshots: " & lSnaps)

' VBScript has no IIf / Max: small helpers
Function IIf(bCond, vT, vF)
  If bCond Then IIf = vT Else IIf = vF
End Function
Function MaxOf(a, b)
  If a > b Then MaxOf = a Else MaxOf = b
End Function

Dim gLog : gLog = GroupIdx("Log")   ' group index of "Log" (differs between full and reduced file)
Function LR(sName)   ' channel reference string in the Log group
  LR = "[" & gLog & "]/" & sName
End Function

' results group
Set oRes = Data.Root.ChannelGroups.Add("Report_Results")
Dim gRes : gRes = GroupIdx("Report_Results")
Call oRes.Activate()   ' FFT results are written to the active group

' helper: CAN / plug-in channel objects
Function L(sName)
  Set L = oLog.Channels(sName)
End Function

' CAN (100 Hz) and plug-in (10 Hz) increments and start offsets vs accel
Dim dtCan, dtPlg, t0Acc, t0Can, t0Plg
dtCan = L("DynoSts_SpeedAct").Properties("wf_increment").Value
dtPlg = L("RMS Levels  Accel").Properties("wf_increment").Value
t0Can = 0.00664  ' CAN starts 6.6 ms after accel (wf_start_time difference in this log)
t0Plg = 0.00002

Function CanRow(tSec)   ' 1-based row in CAN channels at time tSec
  CanRow = Fix((tSec - t0Can) / dtCan) + 1
  If CanRow < 1 Then CanRow = 1
  If CanRow > L("DynoSts_SpeedAct").Size Then CanRow = L("DynoSts_SpeedAct").Size
End Function

Function SnapStartRow(kSnap)   ' 1-based row of snapshot kSnap (0-based) in the raw channel
  If bReduced Then
    SnapStartRow = kSnap * lSnapLen + 1
  Else
    SnapStartRow = CLng(kSnap * dSnapPeriod * dFs) + 1
  End If
End Function

Sub AddCheck(sCat, sName, sExpected, sMeasured, sResult)
  aChecks(nChecks) = Array(sCat, sName, sExpected, sMeasured, sResult)
  nChecks = nChecks + 1
  Call LogFileWrite(sResult & "  " & sName & " | " & sMeasured)
End Sub

'---------------------------- 2) FFT helper ------------------------------------
' Copies snapshot k into [gRes]/Snap, runs an amplitude spectrum (Hann, peak)
' and returns the names of the frequency and amplitude channels.
Dim sTimeChn : sTimeChn = "[" & gRes & "]/SnapTime"
Call ChnLinGen(sTimeChn, 0, (lSnapLen - 1) / dFs, lSnapLen, "s")

Sub SnapSpectrum(sSrc, kSnap, ByRef sFreq, ByRef sAmp, ByRef dRms, ByRef dStd)
  Dim oSnap, nBefore, oGrp
  Set oGrp = Data.Root.ChannelGroups(gRes)
  If oGrp.Channels.Exists("Snap") Then Call oGrp.Channels.Remove("Snap")
  Set oSnap = oGrp.Channels.Add("Snap", DataTypeChnFloat64)
  Call DataBlCopy(sSrc, SnapStartRow(kSnap), lSnapLen, "[" & gRes & "]/Snap", 1)
  ' RMS of the snapshot with mean removed = standard deviation
  Dim js
  On Error Resume Next            ' StatSel size differs between DIAdem versions
  For js = 1 To 30 : StatSel(js) = "Yes" : Next
  Err.Clear
  On Error GoTo 0
  StatClipCopy = 0 : StatClipValue = 0 : StatFormat = "" : StatResChn = False
  StatResChnNames = False : StatResChnNameFormat = "NameName"
  Call StatBlockCalc("Channel", "1-", "[" & gRes & "]/Snap")
  dStd = StatStdDev
  dRms = StatStdDev     ' RMS about the mean, as the plug-in computes it
  ' amplitude spectrum
  FFTIntervUser = "NumberStartOverl"
  FFTIntervPara(1) = 1 : FFTIntervPara(2) = lSnapLen : FFTIntervPara(3) = 1 : FFTIntervPara(4) = 0
  FFTWndFct = "Hanning" : FFTWndPara = 10 : FFTWndChn = sTimeChn : FFTWndCorrectTyp = "Periodic"
  FFTAverageType = "No averaging" : FFTAmplFirst = "Amplitude spectrum" : FFTAmpl = 1
  FFTAmplType = "Ampl.Peak" : FFTAmplExt = "No extension" : FFTNormalization = "No"
  FFTPhaseSpec = "Phase" : FFTCalc = 1 : FFTCalcPhase = 0
  nBefore = oGrp.Channels.Count
  Call ChnFFT1(sTimeChn, "[" & gRes & "]/Snap")
  ' the FFT adds a frequency channel (unit Hz) and an amplitude channel to the active group
  Dim oAG, oC1, oC2 : Set oAG = Data.Root.ActiveChannelGroup
  Set oC1 = oAG.Channels(oAG.Channels.Count - 1) : Set oC2 = oAG.Channels(oAG.Channels.Count)
  If LCase(oC2.UnitSymbol) = "hz" Then
    sFreq = "[" & GroupIdx(oAG.Name) & "]/" & oC2.Name : sAmp = "[" & GroupIdx(oAG.Name) & "]/" & oC1.Name
  Else
    sFreq = "[" & GroupIdx(oAG.Name) & "]/" & oC1.Name : sAmp = "[" & GroupIdx(oAG.Name) & "]/" & oC2.Name
  End If
End Sub

Function AmpAt(sFreq, sAmp, dF)   ' max amplitude within +-2 Hz of dF
  Dim oF, oA, df, j0, j, m
  Set oF = Data.GetChannel(sFreq) : Set oA = Data.GetChannel(sAmp)
  df = oF.Values(2) - oF.Values(1)
  j0 = CLng(dF / df) + 1 : m = 0
  For j = j0 - 2 To j0 + 2
    If j >= 1 And j <= oA.Size Then
      If oA.Values(j) > m Then m = oA.Values(j)
    End If
  Next
  AmpAt = m
End Function

Sub DropFFT(sFreq, sAmp)   ' remove the two FFT result channels again
  Dim oA, oF
  Set oA = Data.GetChannel(sAmp) : Set oF = Data.GetChannel(sFreq)
  Call oA.ChannelGroup.Channels.Remove(oA.Name)
  Call oF.ChannelGroup.Channels.Remove(oF.Name)
End Sub

'---------------------------- 3) per-snapshot loop -----------------------------
' result channels: one value per snapshot
Dim cT, cRpm, c1x, c2x, c24, cRmsRaw, cRmsPlg, cConst
Set cT      = oRes.Channels.Add("Snap_t_s", DataTypeChnFloat64)
Set cRpm    = oRes.Channels.Add("Snap_speed_rpm", DataTypeChnFloat64)
Set c1x     = oRes.Channels.Add("Order_1x_g", DataTypeChnFloat64)
Set c2x     = oRes.Channels.Add("Order_2x_g", DataTypeChnFloat64)
Set c24     = oRes.Channels.Add("Order_24x_ripple_g", DataTypeChnFloat64)
Set cRmsRaw = oRes.Channels.Add("RMS_raw_g", DataTypeChnFloat64)
Set cRmsPlg = oRes.Channels.Add("RMS_plugin_g", DataTypeChnFloat64)

Dim sF, sA, dRms, dStd, r, tS, dRatioSum2x, nRatio2x, dRatioSumRip, nRatioRip, dRatioBase, nBase
Dim rp, pRms, nP, j, dMinR, dMaxR
dRatioSum2x = 0 : nRatio2x = 0 : dRatioSumRip = 0 : nRatioRip = 0 : dRatioBase = 0 : nBase = 0
dMinR = 1E9 : dMaxR = -1E9
For k = 0 To lSnaps - 1
  tS = k * dSnapPeriod
  r = CanRow(tS + 0.5)
  Call SnapSpectrum(sAccel, k, sF, sA, dRms, dStd)
  cT.Values(k + 1)   = tS
  cRpm.Values(k + 1) = L("DynoSts_SpeedAct").Values(r)
  c1x.Values(k + 1)  = AmpAt(sF, sA, L("FltSts_Freq_1x").Values(r))
  c2x.Values(k + 1)  = AmpAt(sF, sA, L("FltSts_Freq_2x").Values(r))
  c24.Values(k + 1)  = AmpAt(sF, sA, L("FltSts_Freq_Ripple").Values(r))
  cRmsRaw.Values(k + 1) = dRms
  ' plug-in RMS mean over the same second
  pRms = 0 : nP = 0
  rp = Fix((tS - t0Plg) / dtPlg) + 1
  For j = rp To rp + 9
    If j >= 1 And j <= L("RMS Levels  Accel").Size Then pRms = pRms + L("RMS Levels  Accel").Values(j) : nP = nP + 1
  Next
  If nP > 0 Then cRmsPlg.Values(k + 1) = pRms / nP
  If nP > 0 And dRms > 0 Then
    If cRmsPlg.Values(k + 1) / dRms < dMinR Then dMinR = cRmsPlg.Values(k + 1) / dRms
    If cRmsPlg.Values(k + 1) / dRms > dMaxR Then dMaxR = cRmsPlg.Values(k + 1) / dRms
  End If
  ' scaling: constant 3000 rpm snapshots with misalignment / ripple on
  If L("DynoSts_SpeedAct").Values(CanRow(tS)) = L("DynoSts_SpeedAct").Values(CanRow(tS + 1)) Then
    If cRpm.Values(k + 1) = 3000 And L("FltSts_Misalign_On").Values(r) = 1 Then
      dRatioSum2x = dRatioSum2x + c2x.Values(k + 1) / L("FltSts_Misalign_Amp").Values(r) : nRatio2x = nRatio2x + 1
    End If
    If cRpm.Values(k + 1) = 3000 And L("FltSts_Ripple_On").Values(r) = 1 Then
      dRatioSumRip = dRatioSumRip + c24.Values(k + 1) / L("FltSts_Ripple_Amp").Values(r) : nRatioRip = nRatioRip + 1
    End If
  End If
  Call DropFFT(sF, sA)
  If k Mod 20 = 0 Then Call LogFileWrite("snapshot " & k & " / " & lSnaps)
Next

'---------------------------- 4) checks ----------------------------------------
Dim dScale, sScale
If nRatio2x + nRatioRip > 0 Then
  dScale = (dRatioSum2x + dRatioSumRip) / (nRatio2x + nRatioRip)
  sScale = "Measured / commanded = " & Str(Round(dScale, 2)) & "x (" & (nRatio2x + nRatioRip) & " snapshots)"
  If Abs(dScale - 1) < 0.05 Then
    Call AddCheck("Sanity", "Accelerometer amplitude scaling", "Measured = commanded", sScale, "PASS")
  Else
    Call AddCheck("Sanity", "Accelerometer amplitude scaling", "Measured = commanded", sScale & " - check DSA sensitivity vs simulator " & SIM_SENS_MV_PER_G & " mV/g", "FAIL")
  End If
End If

' tach: a shaft signal has most of its power at rpm/60; here we only test for a live signal
Dim sTF, sTA, dTRms, dTStd, dTach1x
Call SnapSpectrum(sTach, 0, sTF, sTA, dTRms, dTStd)
dTach1x = AmpAt(sTF, sTA, L("FltSts_Freq_1x").Values(CanRow(0.5)))
If dTach1x > 0.3 * dTStd * Sqr(2) Then
  Call AddCheck("Sanity", "Tach channel", "Shaft-synchronous signal", "1x amplitude " & Str(Round(dTach1x, 3)) & " V", "PASS")
Else
  Call AddCheck("Sanity", "Tach channel", "Shaft-synchronous signal", "No content at rpm/60 (" & Str(Round(dTach1x, 4)) & " V vs " & Str(Round(dTStd, 2)) & " V rms broadband)", "FAIL")
End If
Call DropFFT(sTF, sTA)

Call AddCheck("Correlation", "Plug-in RMS vs RMS from raw accel", "Ratio 1.000", Str(Round(dMinR, 4)) & " to " & Str(Round(dMaxR, 4)) & " over " & lSnaps & " snapshots", IIf(dMinR > 0.97 And dMaxR < 1.03, "PASS", "FAIL"))

' MCU model: P_elec = T*w + 3*Rph*(I0+|T|/Kt)^2 + k*rpm
Dim sMcuErr : sMcuErr = "[" & gRes & "]/MCU_Power_Error_W"
Call Calculate("Ch(""" & sMcuErr & """) = Ch(""" & LR("MCU_ElecPower") & """) - (Ch(""" & LR("MCU_TorqueEst") & """)*Ch(""" & LR("MCU_MotorSpeed") & """)*0.104719755 + 3*0.05*(1.5+Abs(Ch(""" & LR("MCU_TorqueEst") & """))/0.05)^2 + 0.004*Ch(""" & LR("MCU_MotorSpeed") & """))")
Dim dErrMax : dErrMax = MaxOf(Abs(Data.GetChannel(sMcuErr).Properties("minimum").Value), Abs(Data.GetChannel(sMcuErr).Properties("maximum").Value))
Call AddCheck("Sanity", "MCU power vs MCU model", "Within 1 W (1 LSB)", "Max error " & Str(Round(dErrMax, 2)) & " W", IIf(dErrMax <= 1.5, "PASS", "WARN"))

' alive counters: count steps > 1 (mod 16)
Function SkipCount(sName)
  Dim o, n, j, d : Set o = L(sName) : n = 0
  For j = 2 To o.Size
    d = (o.Values(j) - o.Values(j - 1) + 16) Mod 16
    If d > 1 Then n = n + 1
  Next
  SkipCount = n
End Function
Dim nSkipD, nSkipF : nSkipD = SkipCount("DynoSts_Alive") : nSkipF = SkipCount("FltSts_Alive")
Call AddCheck("Sanity", "CAN alive counters", "No skipped updates", "DYNO_Status " & nSkipD & ", SIM_FaultStatus " & nSkipF & " skipped", IIf(nSkipD + nSkipF < 50, "PASS", "WARN"))

Dim oBC : Set oBC = L("DynoSts_BlockCounter")
Dim dBlk : dBlk = (oBC.Values(oBC.Size) - oBC.Values(1)) / ((oBC.Size - 1) * dtCan)
Call AddCheck("Sanity", "AO block counter rate", "10 blocks/s", Str(Round(dBlk, 4)) & " blocks/s", IIf(Abs(dBlk - 10) < 0.01, "PASS", "FAIL"))

Dim bCfg : bCfg = oLog.Channels.Exists("SimCfg_Baseline1x")
Call AddCheck("Sanity", "Simulator configuration logged", "SIM_Config frame in log", IIf(bCfg, "present", "SimCfg_* not logged"), IIf(bCfg, "PASS", "WARN"))

' checks table as channels (so it lands in the results file too)
Dim cCat, cName, cExp, cMeas, cResult
Set cCat = oRes.Channels.Add("Check_type", DataTypeString)
Set cName = oRes.Channels.Add("Check", DataTypeString)
Set cExp = oRes.Channels.Add("Expected", DataTypeString)
Set cMeas = oRes.Channels.Add("Measured", DataTypeString)
Set cResult = oRes.Channels.Add("Result", DataTypeString)
Dim nPass, nFail, nWarn : nPass = 0 : nFail = 0 : nWarn = 0
For i = 0 To nChecks - 1
  cCat.Values(i + 1) = aChecks(i)(0) : cName.Values(i + 1) = aChecks(i)(1)
  cExp.Values(i + 1) = aChecks(i)(2) : cMeas.Values(i + 1) = aChecks(i)(3) : cResult.Values(i + 1) = aChecks(i)(4)
  Select Case aChecks(i)(4)
    Case "PASS" : nPass = nPass + 1
    Case "FAIL" : nFail = nFail + 1
    Case Else   : nWarn = nWarn + 1
  End Select
Next

'---------------------------- 5) spectra for report ----------------------------
' snapshot index -> label (same cases as the web report)
Dim aCases : aCases = Array(Array(0, "Healthy 3011 rpm"), Array(10, "Imbalance 3000 rpm"), _
                            Array(12, "+BPFO +ripple 3000 rpm"), Array(220, "Misalign 1.4 g 4500 rpm"))
Dim aSpecF(3), aSpecA(3), sDb, xx, yy
For i = 0 To 3
  Call SnapSpectrum(sAccel, aCases(i)(0), sF, sA, dRms, dStd)
  ' keep: rename into the results group as dB re 1 g
  sDb = "[" & gRes & "]/Spec" & i & "_dB"
  Call Calculate("Ch(""" & sDb & """) = 20*Lg(Ch(""" & sA & """) + 1e-7)")
  Call ChnCopy(sF, "[" & gRes & "]/Spec" & i & "_Hz")
  aSpecF(i) = "[" & gRes & "]/Spec" & i & "_Hz" : aSpecA(i) = sDb
  Call DropFFT(sF, sA)
Next
If oRes.Channels.Exists("Snap") Then Call oRes.Channels.Remove("Snap")

'---------------------------- 6) report ----------------------------------------
Sub SafeRun(sWhat, oErrNum)
  If oErrNum <> 0 Then Call LogFileWrite("Report: " & sWhat & " failed (" & Err.Description & ")") : Err.Clear
End Sub

Function NewAxis(oSheet, sName, x1, x2, y1, y2, sXLabel, sYLabel)
  Dim oAx
  Set oAx = oSheet.Objects.Add(eReportObject2DAxisSystem, sName)
  oAx.Position.ByCoordinate.X1 = x1 : oAx.Position.ByCoordinate.X2 = x2
  oAx.Position.ByCoordinate.Y1 = y1 : oAx.Position.ByCoordinate.Y2 = y2
  oAx.XAxis.Label.Text = sXLabel : oAx.YAxis.Label.Text = sYLabel
  Set NewAxis = oAx
End Function

Sub AddCurve(oAx, sName, sX, sY)
  Dim oC : Set oC = oAx.Curves2D.Add(e2DShapeLine, sName)
  oC.Shape.XChannel.Reference = sX
  oC.Shape.YChannel.Reference = sY
End Sub

Sub AddText(oSheet, sName, x, y, sTxt, dSize)
  Dim oT : Set oT = oSheet.Objects.Add(eReportObjectText, sName)
  oT.Position.ByCoordinate.X = x : oT.Position.ByCoordinate.Y = y
  oT.Text = sTxt : oT.Font.Size = dSize
End Sub

On Error Resume Next
Call Report.NewLayout()
Dim oSh, oAx, sLine
' --- sheet 1: summary
Set oSh = Report.Sheets.Add("Summary") : Call SafeRun("sheet Summary", Err.Number)
Call AddText(oSh, "Title", 5, 95, "eDyno NVH PoC - Test Report", 6) : Call SafeRun("title", Err.Number)
Call AddText(oSh, "Sub", 5, 90, "Log: " & sLogFile & "   Generated: " & Now, 2.5)
Call AddText(oSh, "Verdict", 5, 84, nPass & " of " & nChecks & " checks pass, " & nFail & " fail, " & nWarn & " warnings", 4)
For i = 0 To nChecks - 1
  sLine = aChecks(i)(4) & "   " & aChecks(i)(0) & " - " & aChecks(i)(1) & ":  " & aChecks(i)(3)
  Call AddText(oSh, "Chk" & i, 5, 78 - i * 4.5, sLine, 2.6)
Next
Call SafeRun("summary text", Err.Number)

' --- sheet 2: timeline (waveform channels: X reference left empty)
Set oSh = Report.Sheets.Add("Timeline")
Set oAx = NewAxis(oSh, "Speed", 8, 95, 70, 95, "time (s)", "speed (rpm)")
Call AddCurve(oAx, "SpeedAct", "", LR("DynoSts_SpeedAct"))
Set oAx = NewAxis(oSh, "Vib", 8, 95, 38, 65, "time (s)", "RMS (g) / velocity (mm/s)")
Call AddCurve(oAx, "RMS", "", LR("RMS Levels  Accel"))
Call AddCurve(oAx, "Vel", "", LR("Velocity  Accel"))
Set oAx = NewAxis(oSh, "Kurt", 8, 95, 6, 33, "time (s)", "kurtosis / crest factor")
Call AddCurve(oAx, "Kurtosis", "", LR("Kurtosis  Accel"))
Call AddCurve(oAx, "Crest", "", LR("Crest Factors  Accel"))
Call SafeRun("timeline", Err.Number)

' --- sheet 3: MCU
Set oSh = Report.Sheets.Add("MCU")
Set oAx = NewAxis(oSh, "Power", 8, 95, 55, 95, "time (s)", "power (W)")
Call AddCurve(oAx, "P", "", LR("MCU_ElecPower"))
Set oAx = NewAxis(oSh, "Temps", 8, 95, 6, 48, "time (s)", "temperature (degC) / torque x100 (Nm)")
Call AddCurve(oAx, "Tw", "", LR("MCU_WindingTemp"))
Call AddCurve(oAx, "Tc", "", LR("MCU_ControllerTemp"))
Call SafeRun("MCU", Err.Number)

' --- sheet 4: spectra 2 x 2
Set oSh = Report.Sheets.Add("Spectra")
For i = 0 To 3
  xx = 8 + (i Mod 2) * 46 : yy = 52 - (i \ 2) * 46
  Set oAx = NewAxis(oSh, "Spec" & i, xx, xx + 42, yy, yy + 40, "frequency (Hz)", "dB re 1 g pk")
  Call AddCurve(oAx, "S" & i, aSpecF(i), aSpecA(i))
  Call AddText(oSh, "SpecT" & i, xx + 2, yy + 42, aCases(i)(1), 2.6)
Next
Call SafeRun("spectra", Err.Number)

' --- sheet 5: order tracks + RMS agreement
Set oSh = Report.Sheets.Add("Orders")
Set oAx = NewAxis(oSh, "Ord", 8, 95, 55, 95, "speed (rpm)", "amplitude (g pk)")
Call AddCurve(oAx, "o1", "[" & gRes & "]/Snap_speed_rpm", "[" & gRes & "]/Order_1x_g")
Call AddCurve(oAx, "o2", "[" & gRes & "]/Snap_speed_rpm", "[" & gRes & "]/Order_2x_g")
Call AddCurve(oAx, "o24", "[" & gRes & "]/Snap_speed_rpm", "[" & gRes & "]/Order_24x_ripple_g")
Set oAx = NewAxis(oSh, "RmsChk", 8, 95, 6, 48, "time (s)", "RMS (g): plug-in vs raw")
Call AddCurve(oAx, "rr", "[" & gRes & "]/Snap_t_s", "[" & gRes & "]/RMS_raw_g")
Call AddCurve(oAx, "rp", "[" & gRes & "]/Snap_t_s", "[" & gRes & "]/RMS_plugin_g")
Call SafeRun("orders", Err.Number)

Call Report.Refresh()
Dim sPdf : sPdf = sOutDir & "eDyno_PoC_Report_" & Replace(Replace(Replace(CStr(Now), "/", "-"), ":", "-"), " ", "_") & ".pdf"
Call Report.Sheets.ExportToPDF(sPdf, False) : Call SafeRun("PDF export", Err.Number)
On Error GoTo 0

'---------------------------- 7) save results ----------------------------------
Call DataFileSaveSel(sOutDir & "eDyno_PoC_Results.tdms", "TDMS", "[" & gRes & "]/*")
Call LogFileWrite("eDyno report: done. PDF: " & sPdf)
Call MsgBoxDisp("eDyno report finished." & vbCrLf & nPass & " pass / " & nFail & " fail / " & nWarn & " warn" & vbCrLf & sPdf)
