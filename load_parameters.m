% STIMULATOR SETTINGS
INIT_mAMP = 1;                      % start stimulation value
MAX_mAMP = 60;                      % max stimulation value
PULSEWIDTH = 1000;                  % pulse width setting on the device
DWELL = 100;                        % dwell setting on the device

% TASK SETTINGS
% NFR (Reflex) is based on the condition that Z_SCORE_THRESHOLD was exceeded
% z-score is calculated: Z-score = (Reflex_window_max_value – Baseline_mean)/Baseline_SD
Z_SCORE_THRESHOLD = 12;             % value of the z-score above which, the reflex is counted
BASELINE_WINDOW_BEGIN_MS = -65;     % beginning of the baseline window before the stimulus onset (ms)
BASELINE_WINDOW_END_MS = -5;        % end of baseline winow before the stimulus onset (ms)
REFLEX_WINDOW_BEGIN_MS = 40;        % beginning of reflex window after the stimulus onset (ms)
REFLEX_WINDOW_END_MS = 150;         % end of reflex window after the stimulus onset (ms)
THRESHOLD_PASS_CTR = 3;             % how many times the same stimulus evoked the reflex
MIN_INTERVAL_SEC = 8;               % shortest inter stimulus interval (sec)
MAX_INTERVAL_SEC = 12;              % longest inter stimulus interval (sec)

% LABCHART SETTINGS
TEMPLATE_LC_FILE = "r3_adi_last_rec.adicht";
CURRENT_PATH = pwd;
PATH2TEMPLATE = fullfile(CURRENT_PATH,TEMPLATE_LC_FILE);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET UP THE STIMULATOR
% open device and return handle for further calss
[success, d128] = D128ctrl('open');
% Download status from device and initial d128 object parameters
[success, d128] = D128ctrl('status', d128);
% Set value of pulsewidth (does not upload to device)
[success, d128] = D128ctrl('source', d128, 'Internal');
[success, d128] = D128ctrl('pulsewidth', d128, PULSEWIDTH);
[success, d128] = D128ctrl('demand', d128, INIT_mAMP);
[success, d128] = D128ctrl('dwell', d128, DWELL);
% Upload all parameters to device
success = D128ctrl('upload', d128);
% Close device
success = D128ctrl('close', d128);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
