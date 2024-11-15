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
