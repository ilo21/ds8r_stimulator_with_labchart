% NFR (Reflex) is based on the condition that Z_SCORE_THRESHOLD was exceeded
% z-score is calculated: Z-score = (Reflex_window_max_value – Baseline_mean)/Baseline_SD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The stimulus intensity is increased in 2 mA steps starting at 1 mA. When a successful muscle
% response is recorded (i.e., a Z-score > 12), the intensity is decreased with steps of 1 mA until the
% muscle response disappears. The stimulus intensity is then increased with increments of 0.5 mA
% until a second successful muscle response is recorded. Then, the intensity is decreased with steps
% of 0.5 mA until the response disappears. The intensity is again increased with steps of 0.5 mA
% until a third muscle response appears. The mean value of the stimulus intensities eliciting the three
% successful muscle reflex responses is calculated and used as the NWR threshold. The stimulation
% procedure continues either until three successful muscle reflex responses are detected, until the
% stimulus intensity reached max mA, or until the subject asks to stop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% VERIFY IF PARAMETERS WERE LOADED
if exist('LOADED_PARAMETERS', 'var') == 1 && (LOADED_PARAMETERS == 1)
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
    % Convert to column vector
    time_column = time_vector(:); % the colon operator (:) converts to a column vector
    % Initialize the matrix with the first column
    data_matrix = time_column;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Wait for user to be ready
    disp('Press Enter to start stimulations...');
    input('', 's');  % waits for any input from the user but does not store it. As soon as the user presses Enter, MATLAB proceeds to the next line
    disp('Started the test');

    
    % initialize important info to be logged:
    stimNo = 0;
    current = INIT_mAMP;
    score = 0;
    total_reflexes = 0;
    stim_no_column = [];
    current_column = [];
    score_column = [];
    total_reflexes_column = [];
    
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
    stimNo = stimNo + 1;
    % get peri stim data
    peri_stim_data = get_peri_stim_data(adi.doc, STIM_THRESHOLD_V,recording_ticks_before_stim, recording_ticks_after_stim);
    % calculate zscore
    z_score = calculate_zscore(peri_stim_data,time_vector,BASELINE_WINDOW_BEGIN_MS,BASELINE_WINDOW_END_MS,REFLEX_WINDOW_BEGIN_MS,REFLEX_WINDOW_END_MS);
    disp(['Z-score: ', num2str(z_score)]);
    % Append the new column to the data_matrix
    % Convert to column vector
    peri_stim_data = peri_stim_data(:); % the colon operator (:) converts to a column vector
    data_matrix = [data_matrix, peri_stim_data];
    
    % add logging info
    stim_no_column = [stim_no_column,stimNo];
    current_column = [current_column,current];
    score_column = [score_column,z_score];
    if z_score > Z_SCORE_THRESHOLD
        total_reflexes = total_reflexes + 1;
    end
    total_reflexes_column = [total_reflexes_column,total_reflexes];
    
    
    % plot(time_vector,peri_stim_data);
    % % Add a vertical line at x = 0
    % xline(0, 'r--', 'LineWidth', 1.5);  % Red dashed line with thicker width
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % next stim
    % change the demand mAmp on digitimer
    next_stim = current + STEP_UP_BIG_mAMP;
    d128 = update_device_value(next_stim,d128);

    % wait inter stimulus interval
    inter_stim_interval(INTER_STIM_INTERVALS);

    % start recording
    adi.doc.StartSampling;
    pause((RECORDING_MS_BEFORE_STIM+100)/1000) % how much to wait before the stim
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % trigger the device
    success = D128ctrl('Trigger', d128);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pause((RECORDING_MS_AFTER_STIM+100)/1000)   % how much to wait after the stim before stopping the recording

    adi.doc.StopSampling;
    stimNo = stimNo + 1;
    peri_stim_data = get_peri_stim_data(adi.doc, STIM_THRESHOLD_V,recording_ticks_before_stim, recording_ticks_after_stim);
    % calculate zscore
    z_score = calculate_zscore(peri_stim_data,time_vector,BASELINE_WINDOW_BEGIN_MS,BASELINE_WINDOW_END_MS,REFLEX_WINDOW_BEGIN_MS,REFLEX_WINDOW_END_MS);
    disp(['Z-score: ', num2str(z_score)]);
    % Convert to column vector
    peri_stim_data = peri_stim_data(:); % the colon operator (:) converts to a column vector
    % Append the new column to the data_matrix
    data_matrix = [data_matrix, peri_stim_data];
    
    % add logging info
    stim_no_column = [stim_no_column,stimNo];
    current_column = [current_column,next_stim];
    score_column = [score_column,z_score];
    if z_score > Z_SCORE_THRESHOLD
        total_reflexes = total_reflexes + 1;
    end
    total_reflexes_column = [total_reflexes_column,total_reflexes];
    
    % plot(time_vector,peri_stim_data);
    % % Add a vertical line at x = 0
    % xline(0, 'r--', 'LineWidth', 1.5);  % Red dashed line with thicker width
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % next stim
    % change the demand mAmp on digitimer
    next_stim = next_stim + STEP_DOWN_BIG_mAMP;
    d128 = update_device_value(next_stim,d128);

    % wait inter stimulus interval
    inter_stim_interval(INTER_STIM_INTERVALS);

    % start recording
    adi.doc.StartSampling;
    pause((RECORDING_MS_BEFORE_STIM+100)/1000) % how much to wait before the stim
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % trigger the device
    success = D128ctrl('Trigger', d128);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pause((RECORDING_MS_AFTER_STIM+100)/1000)   % how much to wait after the stim before stopping the recording
    adi.doc.StopSampling;
    stimNo = stimNo + 1;
    peri_stim_data = get_peri_stim_data(adi.doc, STIM_THRESHOLD_V,recording_ticks_before_stim, recording_ticks_after_stim);
    % calculate zscore
    z_score = calculate_zscore(peri_stim_data,time_vector,BASELINE_WINDOW_BEGIN_MS,BASELINE_WINDOW_END_MS,REFLEX_WINDOW_BEGIN_MS,REFLEX_WINDOW_END_MS);
    disp(['Z-score: ', num2str(z_score)]);
    % Convert to column vector
    peri_stim_data = peri_stim_data(:); % the colon operator (:) converts to a column vector
    % Append the new column to the data_matrix
    data_matrix = [data_matrix, peri_stim_data];
    
    % add logging info
    stim_no_column = [stim_no_column,stimNo];
    current_column = [current_column,next_stim];
    score_column = [score_column,z_score];
    if z_score > Z_SCORE_THRESHOLD
        total_reflexes = total_reflexes + 1;
    end
    total_reflexes_column = [total_reflexes_column,total_reflexes];
    
    % plot(time_vector,peri_stim_data);
    % % Add a vertical line at x = 0
    % xline(0, 'r--', 'LineWidth', 1.5);  % Red dashed line with thicker width

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
    
else
    disp('You have to successfully run load_parameters.m first!');

end
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
end

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