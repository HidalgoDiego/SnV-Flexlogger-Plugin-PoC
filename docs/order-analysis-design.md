# Order tracks subVI (FlexLogger plug-in)

`src/Vibration-Core/SubVIs/OrderTracks.vi` gives FlexLogger RPM and a few order amplitudes, so they can
be plotted against RPM on an XY Graph. The overall level (accel RMS vs RPM) comes from FlexLogger's own
statistics channel, not from this VI.

The VI follows the NI shipping example *Order Power Spectrum (Analog Tach, DAQmx).vi*. Only the input
(Data In replaces the DAQmx Read) and the output (FlexLogger waveforms) are changed.
Execution: preallocated clone reentrant.

## Connector pane

| Terminal | Dir | Type | Notes |
|---|---|---|---|
| Data In | in | 1D Wfm DBL | From *Read 1D Wfm (DBL)_v2*: [0] = accel (g), [1] = tach (V) |
| Order Settings | in | cluster | Defaults below |
| reset? (F) | in | bool | TRUE on the first block after Configure Session |
| error in / error out | | error | S&V warnings are cleared |
| Array of Waveforms | out | 1D Wfm DBL | One 1-point waveform per channel, dt = block length. Wire to *Write 1D Wfm*, Auto Calculate T0 = TRUE |
| Values | out | 1D DBL | The same numbers as a plain array (for tests) |

Order Settings defaults:

| Field | Default |
|---|---|
| pulses per rev | 1 (4468 simulator tach) |
| trigger level | 2.5 V |
| max order | 64 |
| order resolution | 0.1 |
| window | Hanning |
| averaging | none |
| order ranges | 0.8–1.2, 1.8–2.2, 23.8–24.2 |

Replace the order ranges with the real motor pole-pair and gear-mesh orders when they are known.

## Holding values between blocks: `OT Hold Last Values.vi`

**Why it is needed.** FlexLogger expects one value per channel on every block. The S&V order VIs don't
always deliver one:

- The tach VI needs tach edges before it reports a speed.
- The order spectrum needs about 10 revolutions per spectrum (order resolution 0.1). At 3000 rpm and
  0.1 s blocks, a new spectrum arrives about every 2nd block; at 500 rpm it is slower still.

In a block without a new result, the last result is repeated.

**What it does.** OrderTracks.vi calls the subVI twice:

| Call | new values | update? | reset values |
|---|---|---|---|
| RPM | [last tach speed point] | the tach produced speed points this block | [0] |
| Amplitudes | Power in Band → √ (g rms) | new spectrum available? | one 0 per order range |

Every call applies these rules, in this order:

1. If **update?** is TRUE, output the new values. A fresh result always wins, even on the reset call.
2. If **reset?** is TRUE, or the memory doesn't have the same length as *reset values*, output the reset
   values. The length check covers the first call ever, a plug-in that forgot to wire reset, or a
   change in the number of order ranges.
3. Otherwise, output the values held on the previous call.

**How it remembers.** A While Loop runs exactly once per call. Its shift register is deliberately left
unwired on the left, so it keeps its value from one call to the next. That shift register is the memory.

**Why preallocated reentrant matters.** Both OT Hold Last Values.vi and OrderTracks.vi must stay
*preallocated clone reentrant*. Each call site then gets its own memory: the RPM hold, the amplitude
hold, and each instance of the plug-in. If they were non-reentrant or shared clones, the RPM call and
the amplitude call would overwrite each other's memory.

**Tests.** `tests/unit-tests/ot-hold-last-values-test.vi` calls the subVI 8 times. All 8 outputs match
the expected values:

| Call | Inputs | Output |
|---|---|---|
| 0 | First call, no reset | reset values [0,0,0] |
| 1 | update | [1,2,3] |
| 2 | no update | holds [1,2,3] |
| 3 | empty input, no update | holds [1,2,3] |
| 4 | update + reset | new values [4,5,6] win |
| 5 | reset | [0,0,0] |
| 6 | update | [2,2,2] |
| 7 | reset values change to 2 elements | [0,0] |

In the OrderTracks run-up test, the amplitudes were held on 160 of 300 blocks. RPM and accuracy are
identical to the version before the subVI.

## Channels (created in Initialize, all at 1 / block length = 10 S/s)

`RPM`, then one `Order N Amplitude` (g rms) per order range, in the same order as the ranges.

- Amplitudes are held between spectra, so every channel gets a value every block.
- Amplitudes read 0 until the first spectrum after reset.

## FlexLogger screen

- **XY Graph 1:** X = RPM, Y = accel RMS (a FlexLogger statistics channel).
- **XY Graph 2:** X = RPM, Y = the Order N Amplitude channels (order tracks).

## Test results

From `tests/unit-tests/order-tracks-test.vi`, using a synthetic 1 ppr tach and accel (all outputs numeric):

| Case | RPM | Amplitudes (orders 1, 2, 24) |
|---|---|---|
| 3000 rpm constant, 30 s | Exact | Within ±0.26 %, from block 3 |
| Run-up 500→4500 rpm in 30 s | Mean error 0.78 %. Up to 6.8 % low around 600 rpm (the last tach edge lags with only 1 pulse per rev) | Within ±0.21 %, from block 16 |

Runtime is about 1 ms per block. There are no errors, and every block outputs 4 channels.
