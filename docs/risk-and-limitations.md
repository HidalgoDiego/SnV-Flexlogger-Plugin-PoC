# Risk and limitation list

## Key risks

- Toolchain compatibility between FlexLogger, LabVIEW, and NI Toolkit versions
- PDK API usage differences across installed versions
- Hardware sample-rate or block-length mismatch
- Performance degradation at 32 active channels
- Difficulty of a direct embedded graph in FlexLogger

## Mitigations

- Validate the software stack first
- Keep the architecture to the minimum supported subset
- Reject incompatible channels instead of resampling
- Use simulation before hardware transitions
- Use a lightweight offline viewer for the colormap proof of concept

## Limitations

- This PoC is not a complete NVH system.
- The spectrum analysis is limited to one selected channel.
- The total system is intentionally constrained to a small engineering effort.
