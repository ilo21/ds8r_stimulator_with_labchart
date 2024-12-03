% NFR (Reflex) is based on the condition that Z_SCORE_THRESHOLD was exceeded
% z-score is calculated: Z-score = (Reflex_window_max_value – Baseline_mean)/Baseline_SD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The stimulus intensity is increased in 2 mA steps starting at 1 mA. When a successful muscle
% response is recorded (i.e., a Z-score > 12), the intensity is decreased with steps of 1 mA until the
% muscle response disappeares. The stimulus intensity is then increased with increments of 1 mA
% until a second successful muscle response is recorded. Then, the intensity is decreased with steps
% of 1 mA until the response disappeares. The intensity is again increased with steps of 1 mA
% until a third muscle response appears. The mean value of the stimulus intensities eliciting the three
% successful muscle reflex responses is calculated and used as the NWR threshold. The stimulation
% procedure continues either until three successful muscle reflex responses are detected, until the
% stimulus intensity reached max mA, or until the subject asks to stop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Press enter to start the script
% Press spacebar to pause the script
% Press esc to quit the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear % clears variables left from before 
% Get constants from settings function
params = my_settings();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET UP LOGGING
LOG_FOLDER = "_LOG";
% Specify the folder path
LOG_FOLDER_PATH = fullfile(params.CURRENT_PATH,LOG_FOLDER);
% Check if the folder exists
if exist(LOG_FOLDER_PATH, 'dir') ~= 7
    % If the folder does not exist, create it
    mkdir(LOG_FOLDER_PATH);
    disp(['Folder created: ', LOG_FOLDER_PATH]);
else
    % If the folder exists, display a message
    disp(['Folder already exists: ', LOG_FOLDER_PATH]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET UP THE STIMULATOR
% connect digitimer to channel 2 in PowerLab!
% open device and return handle for further calls
[success, d128] = D128ctrl('open');
% Download status from device and initial d128 object parameters
[success, d128] = D128ctrl('status', d128);
[success, d128] = D128ctrl('enable', d128, 0);
% Set value of pulsewidth (does not upload to device)
[success, d128] = D128ctrl('source', d128, 'Internal');
[success, d128] = D128ctrl('pulsewidth', d128, params.PULSEWIDTH);
[success, d128] = D128ctrl('demand', d128, params.INIT_mAMP);
[success, d128] = D128ctrl('dwell', d128, params.DWELL);
% Upload all parameters to device
success = D128ctrl('upload', d128);
[success, d128] = D128ctrl('enable', d128, 1); % make sure it is enabled
% Download status from device
[success, d128] = D128ctrl('status', d128);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% confirm that the parameters were loaded to the device
if d128.pulsewidth == params.PULSEWIDTH & d128.demand == params.INIT_mAMP*10
    loaded_parameters = 1;
     disp('SUCCESS. Parameters loaded');
else
    loaded_parameters = 0;
    disp('FAILED to load Parameters on the device');
    return;
end

% Start LabChart
adi.doc = actxserver("ADIChart.Document");
adi.gLCApp = adi.doc.Application;   
adi.doc.Close();
% Open the file specified by path, and return a reference to that LabChart adi.document.
adi.doc = adi.gLCApp.Open(params.PATH2TEMPLATE);
blockIndex = 0;
secsPerTick = adi.doc.GetRecordSecsPerTick(blockIndex);
msec_per_tick = secsPerTick *1000; % get how many ms is one tick
recording_ticks_before_stim = floor(params.RECORDING_MS_BEFORE_STIM/msec_per_tick); % how many ticks is my before window
recording_ticks_after_stim = floor(params.RECORDING_MS_AFTER_STIM/msec_per_tick);   % how many ticks is my after window
% create time vector for that
time_vector = (-recording_ticks_before_stim : recording_ticks_after_stim) * msec_per_tick;
% Convert to column vector
time_column = time_vector(:); % the colon operator (:) converts to a column vector
% Initialize the matrix with the first column
data_matrix = time_column;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wait for user to be ready
disp('Press Enter to start stimulations...');
user_input = input('', 's');  % waits for any input from the user
fprintf('\nStarted the test\n');

% initialize important info to be logged:
stimNo = 0;
current = params.INIT_mAMP;
step = params.STEP_UP_BIG_mAMP;
score = 0;
total_reflexes = 0;
currents_for_threshold = [];
stim_no_column = [];
current_column = [];
score_column = [];
total_reflexes_column = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main program loop that will keep delivering the stimuli
while (current >= params.INIT_mAMP && current <= params.MAX_mAMP) && total_reflexes < params.MAX_REFLEXES
    stimNo = stimNo + 1;
    fprintf(['\n\nStimulus number: ', num2str(stimNo),'\n']);
    disp(['Current: ', num2str(current), ' mA']);
    % wait inter stimulus interval
    inter_stim_interval(params.INTER_STIM_INTERVALS);
    % start recording
    adi.doc.StartSampling;
    pause((params.RECORDING_MS_BEFORE_STIM+500)/1000) % how much to wait before the stim (add some tolerance:500ms)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % trigger the device
    success = D128ctrl('Trigger', d128);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pause((params.RECORDING_MS_AFTER_STIM+500)/1000)   % how much to wait after the stim before stopping the recording (add some tolerance:500ms)

    adi.doc.StopSampling;
    
    % get peri stim data
    peri_stim_data = get_peri_stim_data(adi.doc, params.STIM_THRESHOLD_V,recording_ticks_before_stim, recording_ticks_after_stim);
    % calculate zscore
    z_score = calculate_zscore(peri_stim_data,time_vector,params.BASELINE_WINDOW_BEGIN_MS,params.BASELINE_WINDOW_END_MS,params.REFLEX_WINDOW_BEGIN_MS,params.REFLEX_WINDOW_END_MS);
    disp(['Z-score: ', num2str(z_score)]);
    
    if z_score > params.Z_SCORE_THRESHOLD
        % if it is the first reflex or z-score was above the threshold when
        % increasing current, count it as a reflex and
        % increment the total reflexes
        if sum(total_reflexes_column) == 0 || step > 0
            total_reflexes = total_reflexes + 1;
            currents_for_threshold = [currents_for_threshold,current];
        end
        step = params.STEP_DOWN_mAMP;
    else % no reflex
       if sum(total_reflexes_column) == 0 
           % if there were no reflexes before, go up faster
           step = params.STEP_UP_BIG_mAMP;
       else
           % if there were any reflexes before, go up slower
           step = params.STEP_UP_mAMP;
       end 
    end
    disp(['Total reflexes: ', num2str(total_reflexes)]);
    % Append the new column to the data_matrix
    % Convert to column vector
    peri_stim_data = peri_stim_data(:); % the colon operator (:) converts to a column vector
    data_matrix = [data_matrix, peri_stim_data];
    % add logging info
    stim_no_column = [stim_no_column,stimNo];
    current_column = [current_column,current];
    score_column = [score_column,z_score];
    total_reflexes_column = [total_reflexes_column,total_reflexes];
    current = current+step;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Upload new values to the device
    d128 = update_device_value(current,d128);
    % Make sure it is loaded to the device
    is_updated = check_demand_value_on_device(d128,current,3);
    if ~is_updated
        display('Could not upload new value to the device');
        return;
    end
 end % end while loop
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save emg channel data from all stimuli
filename = 'peri_stim_windows.txt';
file_path = fullfile(LOG_FOLDER_PATH,filename);
% Open the file for writing
fileID = fopen(file_path, 'w');
% Write the header row with "Time (ms)" and subsequent "Stim_###" labels
fprintf(fileID, 'Time (ms)'); % first column header
% Generate headers for subsequent columns
for i = 1:stimNo
    % Create the header for each subsequent column, formatted as "Stim_###"
    fprintf(fileID, '\tStim_%03d', i); % tab-separated, with 3-digit zero-padded numbers
end
% New line after header
fprintf(fileID, '\n');
% Close the file (this saves the header)
fclose(fileID);
% Append the matrix data to the file as tab-separated values
writematrix(data_matrix, file_path, 'FileType', 'text', 'Delimiter', '\t', 'WriteMode', 'append');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save scores
filename = 'threshold.txt';
file_path = fullfile(LOG_FOLDER_PATH,filename);
% Open the file for writing
fileID = fopen(file_path, 'w');

currents_for_threshold = [3,4,5];
if length(currents_for_threshold) > 0
    calculated_threshold = mean(currents_for_threshold);
    fprintf(fileID, ['Threshold: ', num2str(calculated_threshold), ' mA\n\n\n']);
end
    
% Write the header row with the correct formatting and fixed widths
fprintf(fileID, '%-10s\t%-12s\t%-6s\t%-22s\n', 'Stim No:', 'Current (mA):', 'Score:', 'Total Reflexes:');

% Convert the columns to column vectors to ensure consistency
stim_no_column = stim_no_column(:);
current_column = current_column(:);
score_column = score_column(:);
total_reflexes_column = total_reflexes_column(:);

% Round the score column to 3 decimal places
score_column = round(score_column, 3);

% Loop through the data and write it row by row with fixed-width formatting
for i = 1:length(stim_no_column)
    fprintf(fileID, '%-10d\t%-12.1f\t%-6.3f\t%-22d\n', stim_no_column(i), current_column(i), score_column(i), total_reflexes_column(i));
end

% Close the file after writing
fclose(fileID);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save labChart file
LC_file_name = "test_log.adicht";
adi.doc.SaveAs(fullfile(LOG_FOLDER_PATH,LC_file_name));
adi.doc.Close;
adi.doc.release;
adi.gLCApp.release;
system('taskkill /F /IM LabChart8.exe');
 
 
 
 
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
end % inter_stim_interval

function device = update_device_value(new_value,device)
    % upload new mAmp value to teh device
    % return device
    [success, device] = D128ctrl('enable', device, 0);
    [success, device] = D128ctrl('demand', device, new_value);
    % Upload all parameters to device
    success = D128ctrl('upload', device);
    [success, device] = D128ctrl('enable', device, 1); % make sure it is enabled
end % update_device_value

function is_updated = check_demand_value_on_device(device,demand_value,timeout)
    % downloads device status to check if demand value is on the device
    % tries timeout times to upload it, if it was not on the device
    % returns 1 for true and 0 for false
    
    % Download status from device
    [success, device] = D128ctrl('status', device);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % confirm that the parameters were loaded to the device
    if device.demand == demand_value*10
        is_updated = 1;
        return;
    else
        % try timeout times
        for i = 1:timeout
            [success, device] = D128ctrl('demand', device, new_value);
            % Upload all parameters to device
            success = D128ctrl('upload', device);
            pause(200);
            % Download status from device
            [success, device] = D128ctrl('status', device);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % confirm that the parameters were loaded to the device
            if device.demand == demand_value*10
                is_updated = 1;
                return;
            end
        end
        is_updated = 0;
    end   
end % check_demand_value_on_device

function peri_stim_window = get_peri_stim_data(labchart_file, stim_threshold, recording_ticks_before_stim, recording_ticks_after_stim)
    % returns data window around the stimulus
    % assumes the stimulus was on channel 2 and emg on channel 1
    nr = labchart_file.NumberOfRecords;
    chan1 = labchart_file.GetChannelData(1,1,nr,1,-1); % channel 1 recent block data (emg with response)
    chan2 = labchart_file.GetChannelData(1,2,nr,1,-1); % channel 2 recent block data (stim channel)
    index_of_stim = find(chan2 > stim_threshold, 1);  % Finds the first index where value is > 0.1
    % keep relevant information in the other channel
    % Calculate the range of indices to extract
    start_index = max(index_of_stim - recording_ticks_before_stim, 1);  % Ensure we don't go below 1
    end_index = min(index_of_stim + recording_ticks_after_stim, length(chan1)); % Ensure we don't exceed vector length

    % Extract the segment of data
    peri_stim_window = chan1(start_index:end_index);
end % get_peri_stim_data

function z_score = calculate_zscore(data_window,time_window,baseline_window_begin,baseline_window_end,reflex_window_begin, reflex_window_end)
    % find beseline data to calculate mean and standard deviation
    % find zscore value in the window after stimulus
    
    % baseline
    baseline_data_indexes = (time_window >= baseline_window_begin) & (time_window <= baseline_window_end);
    % Select the values in data_window that correspond to the time_window range
    baseline_data = data_window(baseline_data_indexes);
    baseline_mean = mean(baseline_data);
    baseline_stdev = std(baseline_data);
    
    % reflex
    reflex_data_indexes = (time_window >= reflex_window_begin) & (time_window <= reflex_window_end);
    reflex_data = data_window(reflex_data_indexes);
    peak_reflex = max(reflex_data);
    z_score = (peak_reflex-baseline_mean)/baseline_stdev;
end

    

  