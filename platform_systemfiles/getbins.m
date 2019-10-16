function [info]=getbins(handles)

% distance bins
% rw        = regexp(handles.rwin.String,'\s+','split');
% rmin      = str2double(rw{1});
% rmax      = str2double(rw{2});
% dr        = handles.dr;
% Rbin      = [(rmin:dr:rmax-dr)',(rmin:dr:rmax-dr)'+dr];
% Rwin      = mean(Rbin,2);
% NR        = length(Rwin);
% 
% % magnitude bins
% mw        = regexp(handles.mwin.String,'\s+','split');
% mmin      = str2double(mw{1});
% mmax      = str2double(mw{2});
% dm        = handles.dm;
% Mbin      = [(mmin:dm:mmax-dm)',(mmin:dm:mmax-dm)'+dm];
% Mwin      = mean(Mbin,2);
% NM        = length(Mwin);
% 
% % epsilon bins
% ew        = regexp(handles.ewin.String,'\s+','split');
% if isempty(ew{1})
%     emin = -3;
%     emax = +3;
%     handles.ewin.String='-3 3';
% else
%     emin      = str2double(ew{1});
%     emax      = str2double(ew{2});
% end
% de        = handles.de;
% Ebin      = [(emin:de:emax-de)',(emin:de:emax-de)'+de];
% Ewin      = mean(Ebin,2);
% NE        = length(Ewin);

info.Rbin = Rbin;
info.Rwin = Rwin;
info.NR   = NR;
info.Mbin = Mbin;
info.Mwin = Mwin;
info.NM   = NM;
info.Ebin = Ebin;
info.Ewin = Ewin;
info.NE   = NE;
