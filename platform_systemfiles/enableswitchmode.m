function out=enableswitchmode(handles)

isMRE   = ~isempty(handles.MRE);
isSHAKE = ~isempty(handles.shakefield);

if and(isMRE,isSHAKE)
    out='on';
else
    out='inactive';
end
