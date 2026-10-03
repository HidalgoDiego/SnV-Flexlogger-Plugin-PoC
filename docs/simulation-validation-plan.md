# Simulation and validation plan

## Validation strategy

The PoC should begin with simulation and only move to hardware after the algorithm is validated. This reduces the chance of debugging hardware and algorithm issues at the same time.

## Simulated data set

Create a set of synthetic signals within the tests/simulated-data/ folder:

- clean_sine.vi or equivalent waveform generator
- sine_plus_noise.vi
- two_tone.vi
- impulsive_signal.vi
- zero_signal.vi
- invalid_signal.vi

## Data generation pattern

- Use known amplitudes and frequencies.
- Scale the same pattern across multiple channels.
- Populate a 32-input test matrix.
- Check both the scalar outputs and the FFT result.

## Validation metrics

- RMS expected value
- Peak expected value
- Crest factor expected value
- Dominant frequency expectation
- Stability with 30 and 32 active channels
- Missing and invalid channel handling

## Benchmark procedure

- Measure computation time for 1, 8, 16, 30, and 32 active channels.
- Record execution time and memory usage for each case.
- Record whether the selected FFT channel changes output correctly.
- Record whether validation errors occur as expected.

## Notes

- [PERFORMANCE MEASUREMENT REQUIRED] Benchmark execution time at the intended analysis update rate.
- [DECISION REQUIRED] Whether the final benchmark should be done in simulation, on hardware, or both.
