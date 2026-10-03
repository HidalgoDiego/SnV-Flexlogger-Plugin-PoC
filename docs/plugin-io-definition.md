# Plug-in input/output definition

## Inputs

- Active channel count: integer, range 1–32
- Input waveform mapping: up to 32 waveform channels
- Selected FFT channel: integer, range 1–32
- FFT length: integer, configurable per project
- Window type: selection list, e.g. Hanning, Flat Top, Uniform
- Analysis update rate: time interval or scan count
- Engineering units: string or enum value
- Optional channel names or sensor prefix: string list

## Input validation rules

- Missing input: configuration error
- Disabled input: ignore or mark invalid
- Mismatched sample rates: reject configuration
- Mismatched waveform lengths: reject configuration
- Empty waveform: reject or mark invalid
- NaN / invalid values: reject waveform or flag the channel
- Invalid units: reject configuration

## Calculations per active channel

For each configured waveform:

- RMS
- Peak
- Crest factor

## Detailed FFT output

For one selected channel:

- FFT or power spectrum waveform
- Dominant frequency scalar
- Dominant amplitude scalar

## Outputs to FlexLogger

- N RMS scalar results
- N Peak scalar results
- N Crest factor scalar results
- 1 FFT waveform result
- 1 dominant frequency result
- 1 dominant amplitude result
- 1 status channel
- Optional execution-health channel

## Output naming convention

Examples:

- Vibration_01_RMS
- Vibration_01_Peak
- Vibration_01_CrestFactor
- Vibration_02_RMS
- Vibration_02_Peak
- Vibration_02_CrestFactor

## Output behavior

- All scalar results remain available for display and TDMS logging.
- FFT output is created only for the selected channel.
- This design intentionally avoids live FFT for every channel.
