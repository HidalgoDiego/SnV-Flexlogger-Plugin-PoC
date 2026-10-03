# Mapping of Sound and Vibration Toolkit examples

## Example mapping

- Color Map (Offline).vi
  - Starting point for small colormap proof-of-concept work
  - Use as an offline display reference only
- Waterfall Display for Power Spectra (Simulated).vi
  - Strong fit for the selected-channel FFT display concept
  - Good candidate for a lightweight offline demonstration
- Waterfall and Cascade Plot (Offline).vi
  -Useful as a reference for spectrum-evolution visualization
- Transient Analysis (Simulated).vi
  - Useful for signal interpretation and validation pattern creation

## Decision on simplest approach

### Confirmed to work

- Returning suitable spectrum waveform data to FlexLogger for display and logging
- Simulated offline waterfall or colormap demonstration using logged data

### Recommended for the PoC

- Return the selected FFT waveform data to FlexLogger as the primary output
- Use a lightweight LabVIEW companion VI or TDMS-based offline viewer for the colormap proof-of-concept

### Potentially suitable for production

- Offline waterfall or spectrum visualization built from logged TDMS data
- A more formal LabVIEW companion viewer if the customer wants a richer demonstration at a later phase

### Not supported or not verified

- Direct embedding of a LabVIEW Sound and Vibration Toolkit graph into FlexLogger without official support confirmation

## Recommendation

Use a simple spectrum output plus a separate offline viewer instead of attempting direct graph embedding in the FlexLogger host. This keeps the PoC aligned with supported patterns and avoids unsupported UI assumptions.
