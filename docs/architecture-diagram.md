# Simplified architecture diagram

## System view

```text
+---------------------------------------------------------------+
| FlexLogger host system                                         |
|---------------------------------------------------------------|
| 30–32 vibration waveform channels                              |
|  Configurable active channel count                             |
|  Selected FFT channel                                          |
|  Scalar output display                                         |
|  TDMS logging                                                  |
+---------------------------------------------------------------+
                          |
                          v
+---------------------------------------------------------------+
| FlexLogger Calculation Plug-In: Multi-Channel Vibration PoC    |
|---------------------------------------------------------------|
|  Initialization                                                |
|  Channel creation                                              |
|  Parameter creation                                            |
|  Input waveform read                                           |
|  Validation                                                    |
|  Metric calculation                                            |
|  FFT for selected channel                                      |
|  Output writing                                                |
|  Error reporting                                               |
|  Cleanup                                                      |
+---------------------------------------------------------------+
                          |
                          v
+---------------------------------------------------------------+
| LabVIEW signal-processing core                                 |
|---------------------------------------------------------------|
|  - RMS                                                        |
|  - Peak                                                       |
|  - Crest factor                                               |
|  - FFT                                                       |
|  - Dominant frequency                                         |
|  - Dominant amplitude                                         |
|  - Input validation                                            |
|  - Unit validation                                             |
+---------------------------------------------------------------+
                          |
                          v
+---------------------------------------------------------------+
| Outputs to FlexLogger                                           |
|---------------------------------------------------------------|
|  N x RMS scalar                                                |
|  N x Peak scalar                                               |
|  N x Crest factor scalar                                       |
|  1 x FFT waveform                                             |
|  1 x Dominant frequency scalar                                 |
|  1 x Dominant amplitude scalar                                 |
|  1 x plug-in status                                            |
+---------------------------------------------------------------+
```

## Validation path

- Simulated waveforms first
- TDMS playback second
- Physical PXIe-4464 or NI-9234 hardware third

## Colormap path

```text
Spectrum data --> offline LabVIEW viewer --> simple colormap/waterfall demo
```

## Scope reminder

This is not a complete NVH system; it is a focused proof-of-concept processing chain.
