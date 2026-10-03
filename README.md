# FlexLogger Multi-Channel Vibration PoC

## PoC objective

This repository captures a deliberately small proof of concept for a FlexLogger calculation plug-in that accepts multiple vibration waveform channels, performs LabVIEW-based processing, and returns calculated results to FlexLogger. The goal is to prove the architecture and the processing pattern without creating a complete NVH solution.

## What the PoC proves

- A single FlexLogger calculation plug-in can accept at least 30 high-rate vibration waveform channels.
- LabVIEW can process high-rate waveform data and compute basic vibration metrics.
- Calculated scalar results can be returned to FlexLogger for display and logging.
- One selected channel can be analyzed in more detail with FFT, dominant frequency, and dominant amplitude.
- The design can be extended later for additional measurements without redesigning the plug-in.

## What the PoC does not prove

- Complete NVH analysis capability.
- Bearing, gearbox, modal, order-tracking, or transmission diagnostics.
- Production qualification or deployment.
- Real-time deterministic synchronization across multiple systems.
- Safety-critical or certification-grade operation.

## Supported software versions

- FlexLogger: current supported version for the target deployment environment
- LabVIEW: version compatible with the installed FlexLogger PDK and NI Sound and Vibration Toolkit
- NI Sound and Vibration Toolkit: version approved by the target FlexLogger environment
- NI-DAQmx / NI-9234 / PXIe-4464 support: as available in the target lab

[HARDWARE CHECK REQUIRED]
[COMPATIBILITY CHECK REQUIRED]
[LICENSING CHECK REQUIRED]

## Required NI software

- FlexLogger
- FlexLogger Plug-In Development Kit (PDK)
- LabVIEW
- NI Sound and Vibration Toolkit
- DAQmx (for hardware validation)
- Optional: TDMS tooling for playback and logging validation

## Required licenses

- FlexLogger license with calculation-plug-in support
- LabVIEW license compatible with the installed PDK
- Sound and Vibration Toolkit license
- DAQmx and hardware driver licenses as needed

## Hardware alternatives

The PoC is intended to start with simulated waveforms, then move to supported hardware. Validation targets include:

- PXIe-4464-based vibration acquisition
- NI-9234-based vibration acquisition
- Simulated FlexLogger waveform channels
- TDMS replay or other offline playback sources

## Installation steps

1. Install FlexLogger and the FlexLogger PDK.
2. Install LabVIEW and the NI Sound and Vibration Toolkit.
3. Install DAQmx if using physical acquisition hardware.
4. Clone this repository.
5. Review the design documentation in docs/.
6. Begin with the simulated-data validation flow.
7. Move to hardware validation only after the simulation results are stable.

## FlexLogger channel-mapping steps

1. Create or open a FlexLogger project.
2. Add at least 30 waveform channels to the project.
3. Ensure the channels are visible as waveform inputs to the plug-in.
4. Map each active channel to the plug-in configuration.
5. Configure the active channel count and the selected FFT channel.
6. Validate that all channels share compatible sample rates and block lengths.
7. Run the calculation and confirm scalar outputs appear.

## Simulation steps

1. Generate synthetic test waveforms using the validation set in tests/simulated-data/.
2. Confirm RMS, peak, crest factor, and FFT behavior for known signals.
3. Use repeated copies of the signals to populate 32 input channels.
4. Validate channel mapping and the single-channel FFT selection.
5. Sweep update rate, FFT size, and window selection to confirm stability.

## Hardware test steps

1. Connect the target PXIe or NI-9234 channel set.
2. Confirm the waveform channels are visible in FlexLogger.
3. Map the channels to the plug-in.
4. Run the calculation at the intended update rate.
5. Check RMS, peak, crest factor, and dominant frequency outputs.
6. Log raw and calculated data to TDMS and review the results.

## Demo instructions

See [docs/demo-script.md](docs/demo-script.md) for the 10-minute proof-of-concept script.

## Known limitations

- This is not a production NVH platform.
- It does not include order tracking, bearing diagnosis, or gearbox analysis.
- The PoC does not implement automatic resampling for incompatible waveforms.
- FFT is computed only for one selected channel.
- Colormap support is limited to a simple proof-of-concept approach.

## Repository disclaimer

This repository is intended for engineering evaluation and proof-of-concept work only. It is not a customer-specific implementation, not a certified product, and not a substitute for official NI documentation, supported PDK examples, or the customer’s own validation process.

## Repository layout

- docs/ — architecture, setup, validation, and demo materials
- src/ — reusable LabVIEW logic and FlexLogger plug-in skeleton
- tests/ — simulated signals and validation outputs
- configs/ — sample FlexLogger configuration notes
- releases/ — release notes and packaged outputs

## Deliverables included

This repository includes the required PoC planning and design materials:

- Executive PoC definition
- Architecture diagram
- Plug-in input/output definition
- PDK implementation plan
- VI hierarchy
- Toolkit example mapping
- Simulation and validation plan
- 30-channel and 32-channel test procedure
- Repo structure
- README draft
- Demo script
- Risk and limitation list
- Definition of done
- Remaining information required

## Immediate next step

Start with [docs/executive-poc-definition.md](docs/executive-poc-definition.md) and [docs/flexlogger-pdk-implementation-plan.md](docs/flexlogger-pdk-implementation-plan.md). These establish the PoC boundaries before implementation begins.
