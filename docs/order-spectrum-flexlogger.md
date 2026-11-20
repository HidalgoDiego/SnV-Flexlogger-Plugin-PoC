# OrderSpectrumToFlexLogger.vi

`src/Vibration-Core/SubVIs/OrderSpectrumToFlexLogger.vi` turns the **order power spectra** wire from the
NI example *Order Power Spectrum (Analog Tach, DAQmx).vi* into FlexLogger channels:

- a live order spectrum for an XY Graph;
- a set of summary channels for the log.

Execution: preallocated clone reentrant. The held spectrum and the spectrum count live in shift
registers.

## Inputs and outputs

| Terminal | Dir | Type | Notes |
|---|---|---|---|
| order power spectra | in | 1D array of {order 0, delta order, magnitude[]} | From *OAT Order Power Spectrum*. **dB on? must be FALSE** (linear power, EU² rms). For the (1 Channel) instance, Build Array its output. |
| Timing Reference | in | Wfm DBL | Any input waveform of this block, e.g. the accel. Supplies t0 and the block length. |
| reset? (F) | in | bool | TRUE on the first Process call after Configure Session. |
| Spectrum Display Settings | in | cluster | channels (1), plot points per block (641), plot in dB? (F), window ENBW (bins) (1.5 for Hanning). |
| error in / error out | | error | Passed through. |
| Plot Waveforms | out | 1D Wfm DBL | Order Axis, then one Order Spectrum per channel. |
| Log Waveforms | out | 1D Wfm DBL | Summary channels, one point per block. |
| Plot Values / Log Values | out | DBL arrays | The same numbers as plain arrays, for tests. |

## Live plot (Plot Waveforms)

Every block, each plot channel carries **plot points per block** samples, with dt = block length / plot points:

| Channel | Content |
|---|---|
| Order Axis | order 0, order 0 + Δorder, … (the X values) |
| Order Spectrum [ch] | the magnitude of each bin, in EU rms (√power), or 10·log10(power) dB re 1 EU rms when *plot in dB?* is TRUE |

Points past the last bin repeat the last bin, and bins past *plot points* are not plotted. With order
resolution 0.1, 641 points covers orders 0–64. The S&V resampling actually returns bins up to order 83.9;
the bins above 64 are only resampler headroom.

When no new spectrum arrives in a block, the last spectrum is repeated, so the channels never stop.

FlexLogger screen setup:

1. Place an **XY Graph**.
2. Map X to `Order Axis` and Y to `Order Spectrum`.
3. Set the graph history to about one block (0.1 s), so only the latest spectrum is drawn.
4. Optional: set Y to log scale, or set *plot in dB?* = TRUE.

Caveat: FlexLogger graphs downsample with an FIR filter. Both channels are filtered the same way, so the
X/Y pairs stay aligned, but the wrap from max order back to 0 can show a few stray points. This has not
been checked on a real FlexLogger screen yet. If the trace smears, reduce *plot points per block*.

## Log channels (Log Waveforms, in this order)

| # | Channel | Unit | Meaning |
|---|---|---|---|
| 0 | Spectrum Valid | 0/1 | 1 once a spectrum has arrived since reset |
| 1 | Spectrum Count | – | Spectra received since reset; it increments when the spectrum is new |
| 2 | Order Resolution | order | Δorder of the spectrum |
| 3 | Max Order | order | Order of the last bin |
| 4+3k | Overall Level [k] | EU rms | √(Σ power / window ENBW) over the whole spectrum |
| 5+3k | Peak Order [k] | order | Order of the highest bin |
| 6+3k | Peak Amplitude [k] | EU rms | √ of the highest bin |

The full spectrum is also logged: the Order Spectrum channel holds it every block, in blocks of
*plot points* samples. To rebuild it in DIAdem or Python, reshape that channel to [blocks × points].

## Process.vi wiring

1. Build Array the *order power spectrum* output of OAT Order Power Spectrum (1 Channel), or wire the
   multi-channel output directly.
2. Wire it, plus the accel waveform (Timing Reference), reset? and the settings, into this VI.
3. Plot Waveforms → Write 1D Wfm for the plot channels; Log Waveforms → Write 1D Wfm for the log channels.
   Use Auto Calculate T0 = TRUE for both.

Initialize creates:

- **Plot channels:** Order Axis + Order Spectrum per channel, each at plot points / block length
  (641 / 0.1 s = 6410 S/s).
- **Log channels:** 4 + 3 × channels, at 1 / block length (10 S/s).

## Tests

**`tests/unit-tests/order-spectrum-flexlogger-test.vi`** synthesises accel (orders 1, 2, 3.57, 4 and 24,
with peaks 0.5/0.2/0.1/0.05/0.3 g, plus noise) and a 1 ppr tach. It runs the S&V chain of the NI example
block by block into this VI. It returns numeric arrays only.

| Check | Result |
|---|---|
| X burst = order0 + i·Δorder | exact (error 7e-15) |
| Y burst = √power, and 10·log10(power) in dB mode | exact (error 1e-14) |
| Overall Level | 0.4430 g rms vs 0.4431 expected (√Σ tone rms² + noise) |
| Peak Order / Peak Amplitude | 1.0 / 0.3535 g rms vs 0.3536 expected |
| Bin amplitudes at orders 1, 2, 4, 24 | 0.3535, 0.1415, 0.0353, 0.2120 (expected 0.3536, 0.1414, 0.0354, 0.2121) |
| Order 3.57 (between bins) | 0.0667 vs 0.0707: Hanning scalloping, expected for an off-bin order |
| Before the first spectrum | Valid = 0 and all values 0 (3 blocks at 3000 rpm, 20 blocks at 500 rpm) |
| Channels per block | always 2 plot + 7 log |

**`tests/unit-tests/order-spectrum-flexlogger-hold-test.vi`** checks the hold and reset logic:

- An empty magnitude and an empty array both hold the previous spectrum, and the count does not increment.
- A new spectrum updates all values.
- reset clears everything to 0, with Valid = 0.
- All values match hand calculations.
