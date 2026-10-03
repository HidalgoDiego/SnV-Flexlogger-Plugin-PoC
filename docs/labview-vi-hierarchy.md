# LabVIEW VI hierarchy

## Proposed hierarchy

- Vibration_PoC_Main.vi
  - Vibration_Configuration_Cluster.ctl
  - Vibration_Input_Validation.vi
  - Vibration_Metrics.vi
    - Compute_RMS.vi
    - Compute_Peak.vi
    - Compute_Crest_Factor.vi
  - Vibration_FFT_Analysis.vi
    - Select_FFT_Channel.vi
    - Apply_Window.vi
    - FFT_Engine.vi
    - Extract_Dominant_Frequency.vi
    - Extract_Dominant_Amplitude.vi
  - Vibration_Output_Mapping.vi
  - Vibration_Status.vi

## Role of each VI

- Vibration_PoC_Main.vi: top-level workflow and orchestration.
- Vibration_Input_Validation.vi: checks channel count, sample rate, block size, NaN values, and empty data.
- Vibration_Metrics.vi: computes the required scalar metrics for all active channels.
- Vibration_FFT_Analysis.vi: performs the more detailed analysis for one selected channel.
- Vibration_Output_Mapping.vi: assigns data to FlexLogger outputs.
- Vibration_Status.vi: publishes execution health and configuration status.

## Scope note

This hierarchy is purposely small and does not attempt to implement a full NVH feature set.
