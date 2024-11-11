% STIMULATOR SETTINGS
INIT_mAMP = 1;
INIT_PULSEWIDTH = 1000;
INIT_DWELL = 100;
% LABCHART SETTINGS
TEMPLATE_LC_FILE = "r3_adi_last_rec.adicht";
CURRENT_PATH = pwd;
PATH2TEMPLATE = fullfile(CURRENT_PATH,TEMPLATE_LC_FILE);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET UP STIMULATOR
% open device and return handle for further calss
[success, d128] = D128ctrl('open');
% Download status from device and initial d128 object parameters
[success, d128] = D128ctrl('status', d128);
% Set value of pulsewidth (does not upload to device)
[success, d128] = D128ctrl('source', d128, 'Internal');
[success, d128] = D128ctrl('pulsewidth', d128, INIT_PULSEWIDTH);
[success, d128] = D128ctrl('demand', d128, INIT_mAMP);
[success, d128] = D128ctrl('dwell', d128, INIT_DWELL);
% Upload all parameters to device
success = D128ctrl('upload', d128);
% Close device
success = D128ctrl('close', d128);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start LabChart
adi.doc = actxserver("ADIChart.Document");
adi.gLCApp = adi.doc.Application;   
adi.doc.Close();
% Open the file specified by path, and return a reference to that LabChart adi.document.
adi.doc = adi.gLCApp.Open(PATH2TEMPLATE);
