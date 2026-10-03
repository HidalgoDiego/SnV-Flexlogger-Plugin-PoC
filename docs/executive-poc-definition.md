# One-page executive PoC definition

## Objective

Prove that a FlexLogger calculation plug-in can accept multiple vibration waveform inputs, compute basic vibration metrics in LabVIEW, and return useful results to FlexLogger. The PoC is deliberately narrow and is not intended as a production NVH platform.

## Customer context

The target environment includes a separate Windows system running FlexLogger acquiring CAN, analog sensor, and high-rate vibration data while NI VeriStand controls eDynos through EtherCAT drives. The purpose of this PoC is not to solve the complete NVH or drivetrain analysis challenge; it is only to prove the architecture for multi-channel vibration processing and result return.

## Scope

- 32 configurable waveform inputs
- 30+ active channels demonstrated
- RMS, peak, and crest factor for every active channel
- FFT, dominant frequency, and dominant amplitude for one selected channel
- Simulated-validation-first approach with hardware validation second
- Output to FlexLogger as scalar and waveform channels

## What the PoC proves

- FlexLogger can expose waveform data to a calculation plug-in.
- LabVIEW can process at least 30 vibration channels in a realistic configuration.
- Scalar outputs can be logged and displayed.
- A dedicated FFT channel can be selected without rebuilding the plug-in.
- The pattern is extensible for future measurement types.

## What the PoC does not prove

- Full NVH diagnosis
- Order analysis or modal analysis
- Fault detection or automated diagnostics
- Production deployment readiness

## Decision summary

- [DECISION REQUIRED] Which FFT channel selection pattern is best for the selected FlexLogger PDK API
- [HARDWARE CHECK REQUIRED] Which acquisition hardware is available for the final validation step
- [COMPATIBILITY CHECK REQUIRED] Which versions of LabVIEW, FlexLogger, and the Sound and Vibration Toolkit are supported together
- [LICENSING CHECK REQUIRED] Confirm the valid licensing arrangement for the environment

## Success criteria

The PoC is successful if it:

1. Accepts and processes at least 30 waveform channels.
2. Calculates RMS, peak, and crest factor for all active inputs.
3. Calculates FFT and dominant metrics for one selected channel.
4. Returns results to FlexLogger for display and logging.
5. Demonstrates stable behavior with 30 and 32 active channels.

## End state

This PoC becomes the engineering foundation for a future expanded vibration or NVH workflow. It does not replace the design of a complete measurement and analysis system.
