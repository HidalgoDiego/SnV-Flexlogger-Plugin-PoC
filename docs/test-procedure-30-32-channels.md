# 30-channel and 32-channel test procedure

## Test objective

Verify that the PoC remains stable when operating at 30 and 32 active waveform channels while still computing the selected FFT analysis.

## Procedure

### 30-channel test

1. Configure 30 active vibration channels.
2. Map all 30 channels to the plug-in.
3. Set the FFT channel to one of the active inputs.
4. Run the analysis at the target update rate.
5. Record RMS, peak, crest factor, and dominant metrics.
6. Confirm no channel swapping or missing outputs.
7. Confirm the plug-in remains stable for the test duration.

### 32-channel test

1. Configure 32 active vibration channels.
2. Repeat the same mapping and analysis setup.
3. Confirm all 96 scalar outputs are created and updated.
4. Confirm the selected FFT result still updates correctly.
5. Capture execution time and memory usage.
6. Compare the 30-channel and 32-channel behavior.

## Pass/fail goals

- All configured channels produce valid outputs.
- No result swapping between channels.
- No crashes or silent data corruption.
- FFT output remains correct for the selected channel.
- Execution remains acceptable for the intended update rate.

## Note

If any channel has incompatible rate or block length, reject the configuration with an explicit error rather than attempting resampling.
