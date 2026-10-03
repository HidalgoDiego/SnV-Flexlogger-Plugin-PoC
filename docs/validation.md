# Validation and test plan

## Core validation goals

The PoC must prove that:

- channel mapping is correct
- RMS, peak, and crest factor calculations are correct
- FFT and dominant frequency calculations are correct
- results remain stable over 30 and 32 active channels
- invalid or missing channels are handled cleanly

## Validation signals

Use synthetic signals with known expected behavior:

1. Clean sine wave
2. Sine wave with added noise
3. Two-tone waveform
4. Impulse-rich waveform
5. Zero-valued waveform
6. Empty or invalid waveform

Repeat and scale these signals across 32 channels to simulate a multi-channel acquisition environment.

## Pass/fail expectations

- RMS tolerance: within a defined engineering tolerance for known synthetic signals
- Peak: within a defined tolerance
- Crest factor: within a defined tolerance
- Dominant frequency: within FFT bin resolution
- Channel mapping: no cross-channel result swapping
- Missing channel: clear configuration error
- Invalid waveform: no crash or silent corruption

## Validation framework

- Create a standalone LabVIEW VI that accepts 32 simulated waveforms.
- Compute metrics in a controlled environment.
- Compare results against expected values.
- Measure execution time and memory consumption.
- Export the validation results into tests/validation-results/.

## Hardware validation sequence

1. Validate on simulated waveforms.
2. Validate through TDMS playback if available.
3. Move to PXIe-4464 or NI-9234 hardware.
4. Confirm waveform rates and block lengths are compatible.
5. Verify logging of raw and calculated data.
6. Confirm the FFT object or spectrum output behaves as expected.

## Failure handling

If sample rates or block lengths differ, do not implement automatic resampling for this PoC. Return a clear configuration error instead.

## Acceptance criteria

The project passes validation when all known synthetic waveforms produce expected metrics and stable execution with 30 and 32 active channels.
