# Information still required

This list calls out the remaining items that must be confirmed before implementation is complete:

- Exact installed versions of FlexLogger, LabVIEW, and NI Sound and Vibration Toolkit
- Exact target hardware available for validation
- Whether a PXIe-4464, NI-9234, or simulated waveform path is the primary test route
- Valid licensing and support model for the final environment
- Exact FFT output type supported by the installed FlexLogger PDK
- Whether the customer wants the proof-of-concept to be delivered as a documentation package, a LabVIEW prototype, or both

## Decision markers

- [DECISION REQUIRED] FFT output type and display method
- [HARDWARE CHECK REQUIRED] Available hardware and channel count
- [COMPATIBILITY CHECK REQUIRED] Installed software versions and supported pairing
- [LICENSING CHECK REQUIRED] License status for all NI dependencies
- [PERFORMANCE MEASUREMENT REQUIRED] Benchmark to confirm acceptable live processing latency
