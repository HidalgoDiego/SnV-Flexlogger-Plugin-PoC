# Setup and installation

## Minimum software required

- FlexLogger
- FlexLogger Plug-In Development Kit
- LabVIEW
- NI Sound and Vibration Toolkit
- DAQmx
- TDMS-compatible logging tools or NI software for validation

## Minimum hardware required

- One Windows system running FlexLogger
- At least one vibration acquisition source for hardware validation
- Preferably a PXIe-4464 or NI-9234-based setup for physical validation
- Optional simulated waveform source for early proof-of-concept checks

## Minimum simulated configuration

- 32 simulated waveform channels
- 30 active channels configured in the plug-in
- One selected FFT channel
- FFT size: configurable, e.g. 1024 or 2048 samples
- Window: Hanning or similar standard window
- Update rate: chosen to match a realistic acquisition configuration

## Installation sequence

1. Install FlexLogger.
2. Install FlexLogger PDK.
3. Install LabVIEW.
4. Install NI Sound and Vibration Toolkit.
5. Install DAQmx.
6. Clone this repository and review the design docs.
7. Validate the core signal-processing VI with simulated waveforms.
8. Move to FlexLogger plug-in integration.
9. Test with hardware only after simulation passes.

## Recommended environment validation

- Confirm supported LabVIEW/FlexLogger pairings.
- Check the current installation versions before building the plug-in.
- Confirm the Sound and Vibration Toolkit examples are available on the machine.
- Verify there are no blocked or unsupported software versions in the lab environment.

## Compatibility checks

- [COMPATIBILITY CHECK REQUIRED] Confirm the target FlexLogger version supports the installed PDK architecture.
- [COMPATIBILITY CHECK REQUIRED] Check whether example APIs are available in the local NI Sound and Vibration Toolkit installation.
- [HARDWARE CHECK REQUIRED] Confirm module and cable availability before hardware validation.
