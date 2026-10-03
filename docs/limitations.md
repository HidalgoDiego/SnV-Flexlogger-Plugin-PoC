# Known limitations and scope boundaries

## In scope

- Multi-channel vibration waveform input processing
- Shared RMS, peak, and crest factor calculation for each active channel
- FFT and dominant metrics on one selected channel
- Minimal configuration controls
- Simulated validation and hardware second-pass validation

## Out of scope

- Complete NVH functionality
- Bearing defect diagnosis
- Gearbox diagnosis
- Order tracking
- Run-up and coast-down analysis
- FRF, coherence, and transmissibility
- EtherCAT control and VeriStand custom-device design
- CAN decoding inside the vibration plug-in
- Automated reporting and production deployment

## Technical limitations

- Incompatible waveform rates or block lengths are rejected rather than resampled.
- The PoC computes FFT for only one channel at a time.
- Colormap support is a simple proof of concept, not a production display feature.
- Results are for engineering evaluation and demonstration, not certification.

## Decision markers

- [NOT REQUIRED FOR POC] Cross-system synchronization logic
- [NOT REQUIRED FOR POC] Safety-critical logic
- [DECISION REQUIRED] Exact final FFT display method in the target FlexLogger environment
- [LICENSING CHECK REQUIRED] Confirm the NI Toolkit and PDK licensing arrangement
- [PERFORMANCE MEASUREMENT REQUIRED] Perform execution-time and memory benchmarking with 30 and 32 active channels
