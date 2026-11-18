# Release note: hardware validation on PXIe-4464 (2026-11-18)

## Summary

The Vibration Parameters plug-in was validated in FlexLogger against a **real PXIe-4464 acquisition** instead of simulated waveforms. The input was PXIe-4464 ai0, driven by the eDyno NVH accelerometer simulator on a PXIe-4468. **Result: PASS.**

- The plug-in outputs (RMS, Peak, Max, Min, Max-Min, Crest Factor) equal the values recomputed from the raw 4464 samples to machine precision, over all 450 blocks of a 45 s run. Power in Band agrees with RMS² to within 4 % in steady blocks.
- ai0 tracked every injected fault at the expected frequency and amplitude: imbalance (1×), misalignment (2×), bearing BPFO (envelope at 178.5 Hz), torque ripple (1200 Hz) and PWM (16 kHz plus sidebands).
- Plug-in outputs are time-aligned with ai0 (fixed 0.1 s blocks, continuous t0), so no post-alignment is needed in DIAdem.

Full report: [`tests/validation-results/2026-11-18_pxie4464-hardware-validation.md`](../tests/validation-results/2026-11-18_pxie4464-hardware-validation.md)

## Changes in this stage

- `PowerSpectrum.vi`: one result per block, output dt = block length, t0 = block start, restart averaging = TRUE (fixes outputs being repeated 9× and stamped with the input dt).
- Plug-in is now **single-channel, one instance per axis**, with an `Axis` enum parameter.
- `Initialize.vi`: No Resampling + Block Size; Set Plugin Timing removed.
- `Process.vi`: Write 1D Wfm (DBL) with Auto Calculate T0 = TRUE.
- `acc-daq-test.vi`: accelerometer sensitivity wired to 100 mV/g.

## Known open items

Output channel units are not set; the Window parameter has no effect; `PowerSpectrum.vi` is not yet reentrant; only 0.1 s blocks and one channel were tested; run-ups need order tracking. Details are in the report's "Open items" section.
