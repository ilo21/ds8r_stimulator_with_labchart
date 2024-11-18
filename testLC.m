% NFR (Reflex) is based on the condition that Z_SCORE_THRESHOLD was exceeded
% z-score is calculated: Z-score = (Reflex_window_max_value – Baseline_mean)/Baseline_SD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The stimulus intensity is increased in 2 mA steps starting at 1 mA. When a successful muscle
% response is recorded (i.e., a Z-score > 12), the intensity is decreased with steps of 1 mA until the
% muscle response disappeares. The stimulus intensity is then increased with increments of 0.5 mA
% until a second successful muscle response is recorded. Then, the intensity is decreased with steps
% of 0.5 mA until the response disappeares. The intensity is again increased with steps of 0.5 mA
% until a third muscle response appears. The mean value of the stimulus intensities eliciting the three
% successful muscle reflex responses is calculated and used as the NWR threshold. The stimulation
% procedure continues either until three successful muscle reflex responses are detected, until the
% stimulus intensity reached max mA, or until the subject asks to stop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start LabChart
adi.doc = actxserver("ADIChart.Document");
adi.gLCApp = adi.doc.Application;   
adi.doc.Close();
% Open the file specified by path, and return a reference to that LabChart adi.document.
adi.doc = adi.gLCApp.Open(PATH2TEMPLATE);
blockIndex = 0;
secsPerTick = adi.doc.GetRecordSecsPerTick(blockIndex);
msec_per_tick = secsPerTick *1000; % get how many ms is one tick
recording_ticks_before_stim = floor(RECORDING_MS_BEFORE_STIM/msec_per_tick); % how many ticks is my before window
recording_ticks_after_stim = floor(RECORDING_MS_AFTER_STIM/msec_per_tick);   % how many ticks is my after window
% create time vector for that
time_vector = (-recording_ticks_before_stim : recording_ticks_after_stim) * msec_per_tick;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wait for user to be ready
stimNo = 0;
disp('Press Enter to start stimulations...');
input('', 's');  % waits for any input from the user but does not store it. As soon as the user presses Enter, MATLAB proceeds to the next line

% wait inter stimulus interval
inter_stim_interval(INTER_STIM_INTERVALS);
% start recording
adi.doc.StartSampling;
pause((RECORDING_MS_BEFORE_STIM+100)/1000) % how much to wait before the stim (add some tolerance:100ms)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trigger the device
success = D128ctrl('Trigger', d128);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pause((RECORDING_MS_AFTER_STIM+100)/1000)   % how much to wait after the stim before stopping the recording (add some tolerance:100ms)

adi.doc.StopSampling;
nr = adi.doc.NumberOfRecords;
chan1 = adi.doc.GetChannelData(1,1,nr,1,-1); % channel 1 recent block data (emg with response)
chan2 = adi.doc.GetChannelData(1,2,nr,1,-1); % channel 2 recent block data (stim channel)
index_of_stim = find(chan2 > 0.1, 1);  % Finds the first index where value is > 0.1
% keep relevant information in the other channel
% Calculate the range of indices to extract
start_index = max(index_of_stim - recording_ticks_before_stim, 1);  % Ensure we don't go below 1
end_index = min(index_of_stim + recording_ticks_after_stim, length(chan1)); % Ensure we don't exceed vector length

% Extract the segment of data
peri_stim_window = chan1(start_index:end_index);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% next stim
% change the demand mAmp on digitimer
next_stim = INIT_mAMP + STEP_UP_BIG_mAMP;
d128 = update_device_value(next_stim,d128);

% wait inter stimulus interval
inter_stim_interval(INTER_STIM_INTERVALS);

% start recording
adi.doc.StartSampling;
pause(RECORDING_MS_BEFORE_STIM/1000) % how much to wait before the stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trigger the device
[success, d128] = D128ctrl('enable', d128, 1);
success = D128ctrl('Trigger', d128);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pause(RECORDING_MS_AFTER_STIM/1000)   % how much to wait after the stim before stopping the recording

adi.doc.StopSampling;
nr = adi.doc.NumberOfRecords;
chan1 = adi.doc.GetChannelData(1,1,nr,1,-1); % channel 1 recent block data (emg with response)
chan2 = adi.doc.GetChannelData(1,2,nr,1,-1); % channel 2 recent block data (stim channel)
index_of_stim = find(chan2 > 0.1, 1);  % Finds the first index where value is > 0.1
disp("end second stim")
[success, d128] = D128ctrl('status', d128);
% keep relevant information in the other channel
% Calculate the range of indices to extract
start_index = max(index_of_stim - recording_ticks_before_stim, 1);  % Ensure we don't go below 1
end_index = min(index_of_stim + recording_ticks_after_stim, length(chan1)); % Ensure we don't exceed vector length

% Extract the segment of data
peri_stim_window = chan1(start_index:end_index);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% next stim
% change the demand mAmp on digitimer
next_stim = next_stim + STEP_DOWN_BIG_mAMP;
d128 = update_device_value(next_stim,d128);

% wait inter stimulus interval
inter_stim_interval(INTER_STIM_INTERVALS);

% start recording
adi.doc.StartSampling;
pause(RECORDING_MS_BEFORE_STIM/1000) % how much to wait before the stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trigger the device
[success, d128] = D128ctrl('enable', d128, 1);
success = D128ctrl('Trigger', d128);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pause(RECORDING_MS_AFTER_STIM/1000)   % how much to wait after the stim before stopping the recording

adi.doc.StopSampling;
nr = adi.doc.NumberOfRecords;
chan1 = adi.doc.GetChannelData(1,1,nr,1,-1); % channel 1 recent block data (emg with response)
chan2 = adi.doc.GetChannelData(1,2,nr,1,-1); % channel 2 recent block data (stim channel)
index_of_stim = find(chan2 > 0.1, 1);  % Finds the first index where value is > 0.1
disp("end third stim")
[success, d128] = D128ctrl('status', d128);
% keep relevant information in the other channel
% Calculate the range of indices to extract
start_index = max(index_of_stim - recording_ticks_before_stim, 1);  % Ensure we don't go below 1
end_index = min(index_of_stim + recording_ticks_after_stim, length(chan1)); % Ensure we don't exceed vector length

% Extract the segment of data
peri_stim_window = chan1(start_index:end_index);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function inter_stim_interval(range_of_intervals)
    % selects a random interval from range_of_intervals,
    % pauses for that duration, and displays the elapsed time.

    % Select a random interval value from the given intervals
    random_interval = randsample(range_of_intervals, 1);  % Select a random interval value
    
    % Start the timer
    tic;
    
    % Pause for the randomly selected interval
    pause(random_interval);
    
    % Measure the elapsed time
    elapsedTime = toc;
    
    % Display the elapsed time
    disp(['Interval time: ', num2str(elapsedTime), ' seconds']);
end

function device = update_device_value(new_value,device)
    % upload new mAmp value to teh device
    % return device
    [success, device] = D128ctrl('enable', device, 0);
    [success, device] = D128ctrl('demand', device, new_value);
    % Upload all parameters to device
    success = D128ctrl('upload', device);
    [success, device] = D128ctrl('enable', device, 1); % make sure it is enabled
end