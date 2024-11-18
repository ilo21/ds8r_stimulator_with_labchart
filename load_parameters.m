clear                               % remove any previous variables from matlab environment
% STIMULATOR SETTINGS
INIT_mAMP = 1;                      % start stimulation value
MAX_mAMP = 60;                      % max stimulation value
PULSEWIDTH = 1000;                  % pulse width setting on the device
DWELL = 100;                        % dwell setting on the device

% TASK SETTINGS
Z_SCORE_THRESHOLD = 12;             % value of the z-score above which, the reflex is counted
BASELINE_WINDOW_BEGIN_MS = -65;     % beginning of the baseline window before the stimulus onset (ms)
BASELINE_WINDOW_END_MS = -5;        % end of baseline winow before the stimulus onset (ms)
REFLEX_WINDOW_BEGIN_MS = 40;        % beginning of reflex window after the stimulus onset (ms)
REFLEX_WINDOW_END_MS = 150;         % end of reflex window after the stimulus onset (ms)
STEP_UP_BIG_mAMP = 2;               % initial step up when no reflex was detected
STEP_DOWN_BIG_mAMP = -1;            % step down when reflex was detected, until no reflex
STEP_UP_FINE_mAMP = 0.5;            % small step up until next reflex is detected
STEP_DOWN_FINE_mAMP = -0.5;         % small step down until no reflex
THRESHOLD_PASS_CTR = 3;             % how many times the same stimulus evoked the reflex
MIN_INTERVAL_SEC = 3;               % shortest inter stimulus interval (sec)
MAX_INTERVAL_SEC = 5;              % longest inter stimulus interval (sec)
INTER_STIM_INTERVALS = MIN_INTERVAL_SEC:0.5:MAX_INTERVAL_SEC;    % Create an array of values from 8 to 12 with 0.5 steps

% LABCHART SETTINGS
TEMPLATE_LC_FILE = "NFR_template.adicht";
CURRENT_PATH = pwd;
PATH2TEMPLATE = fullfile(CURRENT_PATH,TEMPLATE_LC_FILE);
STM_THRESHOLD_V = 0.1;           % min value in V, in LabChart channel for stmiulation with 1 mAmp
RECORDING_MS_BEFORE_STIM = 100;
RECORDING_MS_AFTER_STIM = 500;

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
[success, d128] = D128ctrl('pulsewidth', d128, PULSEWIDTH);
[success, d128] = D128ctrl('demand', d128, INIT_mAMP);
[success, d128] = D128ctrl('dwell', d128, DWELL);
% Upload all parameters to device
success = D128ctrl('upload', d128);
[success, d128] = D128ctrl('enable', d128, 1); % make sure it is enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
