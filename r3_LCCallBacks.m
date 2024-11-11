function cbh = r3_LCCallBacks(str2)

cbh = str2func(str2);
return;
%----------------------------------------------------------------------
function OnBlockStart(varargin)

return;
%----------------------------------------------------------------------
function OnBlockFinish(varargin)

r3_adi('GETLASTBLOCK');
return;
