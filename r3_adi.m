function r3_adi(action)

persistent adi;

action = lower(action);
switch action,
	case 'getlastblock',
		%fprintf(1,'GetLastBlock\n');
		adi.d.NN = adi.d.NN + 1;
		%fprintf(1,'%i\n',adi.d.NN);
		if adi.d.NN > 1,
			nr = adi.doc.NumberOfRecords;
			fprintf(1,'block nr %i\tNumberOfRecords = %i\n',adi.d.NN,nr);
			%bl = 1;
			adi.d.aa1 = adi.doc.GetChannelData(1,2,nr,1,-1);
			adi.d.aa1a = adi.doc.GetChannelData(1,3,nr,1,-1);
            aa = [adi.d.aa1',adi.d.aa1a'];
			%fprintf(1,'Size of recorded matrix:\t%i\tx\t%i\n',size(aa));
            save('\Data\R3\riii\chart_000.mat','aa');
		end;
	case 'setup',
		p2 = fileparts(mfilename('fullpath'));
		n2 = fullfile(p2,'test_template.adiset');
		%Start LabChart, if needed, and return a reference to the LabChart Application object.
		if isempty(adi) || isempty(adi.gLCApp) || not(adi.gLCApp.isinterface),
			%create a new adi.document to get LabChart running!
			adi.doc = actxserver('ADIChart.Document');
			adi.gLCApp = adi.doc.Application;   
			adi.doc.Close();
		end;
		%Open the file specified by path, and return a reference to that LabChart adi.document.
		adi.doc = adi.gLCApp.Open(n2);
		%Register callback functions
		adi.doc.registerevent({
			'OnStartSamplingBlock' r3_LCCallBacks('OnBlockStart'); 
			'OnFinishSamplingBlock' r3_LCCallBacks('OnBlockFinish')
			});
		adi.d.NN = 0;
		adi.d.aa1 = 1;
		adi.d.aa1a = 1;
		adi.doc.StartSampling;
	case 'exit',
		[p2,f2] = fileparts(mfilename('fullpath'));
		n2 = fullfile(p2,[f2,'_last_rec.adicht']);
		adi.doc.StopSampling;
		if not(isempty(adi.doc.eventlisteners)),
			adi.doc.unregisterallevents;
		end;
		adi.doc.SaveAs(n2);
		adi.doc.Close;
		adi.doc.release;
		adi.gLCApp.release;
		system('taskkill /F /IM LabChart8.exe');
end;

return;