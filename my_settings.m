function params = settings()
    % STIMULATOR SETTINGS
    params.INIT_mAMP = 1;                      % start stimulation value
    params.MAX_mAMP = 7;                      % max stimulation value
    params.PULSEWIDTH = 1000;                  % pulse width setting on the device
    params.DWELL = 100;                        % dwell setting on the device

    % TASK SETTINGS
    params.LOG_FOLDER = "_LOG";
    params.Z_SCORE_THRESHOLD = 12;             % value of the z-score above which, the reflex is counted
    params.MAX_REFLEXES = 3;                   % total number of reflexes to calculate average threshold
    params.BASELINE_WINDOW_BEGIN_MS = -65;     % beginning of the baseline window before the stimulus onset (ms)
    params.BASELINE_WINDOW_END_MS = -5;        % end of baseline winow before the stimulus onset (ms)
    params.REFLEX_WINDOW_BEGIN_MS = 40;        % beginning of reflex window after the stimulus onset (ms)
    params.REFLEX_WINDOW_END_MS = 150;         % end of reflex window after the stimulus onset (ms)
    params.STEP_UP_BIG_mAMP = 2;               % initial step up when no reflex was detected
    params.STEP_DOWN_mAMP = -1;                % step down when reflex was detected, until no reflex
    params.STEP_UP_mAMP = 1;                   % step up when no reflex was detected, until reflex
    params.THRESHOLD_PASS_CTR = 3;             % how many times the same stimulus evoked the reflex
    params.MIN_INTERVAL_SEC = 3;               % shortest inter stimulus interval (sec)
    params.MAX_INTERVAL_SEC = 5;               % longest inter stimulus interval (sec)
    params.INTER_STIM_INTERVALS = params.MIN_INTERVAL_SEC:0.5:params.MAX_INTERVAL_SEC;    % Create an array of values from 8 to 12 with 0.5 steps

    % LABCHART SETTINGS
    params.TEMPLATE_LC_FILE = "NFR_template.adicht";
    params.CURRENT_PATH = pwd;
    params.PATH2TEMPLATE = fullfile(params.CURRENT_PATH,params.TEMPLATE_LC_FILE);
    params.STIM_THRESHOLD_V = 0.1;           % min value in V, in LabChart channel for stmiulation with 1 mAmp
    params.RECORDING_MS_BEFORE_STIM = 100;
    params.RECORDING_MS_AFTER_STIM = 500;
end