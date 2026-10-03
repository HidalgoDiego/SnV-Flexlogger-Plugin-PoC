# Ten-minute demonstration script

## Step 1: Open the project

- Presenter words: “We are showing a small multi-channel vibration plug-in PoC that demonstrates the architecture without building a full NVH system.”
- On-screen action: Open FlexLogger and load the demonstration system definition.
- Expected observation: 30+ waveform channels are visible and mapped.
- Engineering meaning: The plug-in is receiving real waveform data.
- Backup action: Use simulated FlexLogger waveform channels if hardware is unavailable.

## Step 2: Confirm channel mapping

- Presenter words: “The plug-in supports up to 32 configurable waveform inputs and uses a selected FFT channel.”
- On-screen action: Show channel list in configuration dialog.
- Expected observation: All active channels appear in expected order.
- Engineering meaning: No channel-to-channel mis-ordering occurs.
- Backup action: Re-run with a smaller channel count.

## Step 3: Show basic metrics

- Presenter words: “For every active channel, we compute RMS, peak, and crest factor.”
- On-screen action: Display scalar outputs for a subset of sensors.
- Expected observation: Values update at the selected analysis rate.
- Engineering meaning: The plug-in is processing the waveforms in real time.
- Backup action: Reduce the display count if the dashboard is crowded.

## Step 4: Switch the FFT channel

- Presenter words: “Only one channel is analyzed in detail with FFT, dominant frequency, and dominant amplitude.”
- On-screen action: Change the FFT selection from Channel 03 to Channel 17.
- Expected observation: The spectrum and scalar results follow the new selection.
- Engineering meaning: The selected FFT workflow is flexible and user configurable.
- Backup action: Reopen the configuration page and reset the FFT selection.

## Step 5: Inject a simulated imbalance

- Presenter words: “Now we simulate a higher amplitude or changed vibration state on one channel.”
- On-screen action: Increase the amplitude or add a second tone on one selected channel.
- Expected observation: RMS increases and dominant frequency shifts accordingly.
- Engineering meaning: The plug-in reacts to a meaningful vibration change.
- Backup action: Use a prerecorded simulated waveform instead of a live modification.

## Step 6: Show the spectrum result

- Presenter words: “The FFT result is a compact proof that the detailed analysis works on a selected channel.”
- On-screen action: Open the spectrum display or offline viewer.
- Expected observation: A clear peak appears at the expected frequency.
- Engineering meaning: The detailed analysis is behaviorally valid.
- Backup action: Use the offline TDMS or simulated data viewer.

## Step 7: Show the offline colormap or waterfall

- Presenter words: “This is a lightweight proof of concept for visualizing spectrum evolution.”
- On-screen action: Open the offline spectrum display or waterfall.
- Expected observation: A small colormap or waterfall view appears with spectral intensity.
- Engineering meaning: The signal content can be visualized without building a full NVH display system.
- Backup action: Use TDMS playback if the live view is unstable.

## Step 8: Trigger logging

- Presenter words: “We log the raw and calculated data so the results can be reviewed later.”
- On-screen action: Start TDMS logging.
- Expected observation: Data is recorded in the expected file set.
- Engineering meaning: The design supports output capture for analysis and later review.
- Backup action: Use offline logging if the live session is not available.

## Step 9: Review results

- Presenter words: “The purpose here is not a production NVH platform; it is to confirm the architecture and the measurement pattern.”
- On-screen action: Open the logged TDMS file and review selected channels.
- Expected observation: Raw and calculated results match the displayed behavior.
- Engineering meaning: The outputs are consistent and auditable.
- Backup action: Review the validation result files instead of the live log.

## Step 10: Close with future expansion

- Presenter words: “This architecture can grow later for order analysis, envelope analysis, gear metrics, and more advanced NVH workflows.”
- On-screen action: Summarize the PoC and next engineering steps.
- Expected observation: The audience understands the limited but validated proof-of-concept scope.
- Engineering meaning: The architecture is intentionally minimal and extensible.
- Backup action: Transition to a future roadmap slide or architecture note.
