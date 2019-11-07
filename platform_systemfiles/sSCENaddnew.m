function[handles]=sSCENaddnew(handles)
if isempty(handles.t.Data)
    handles.t.Data = cell(1,8);
    handles.tessel = {[],zeros(0,2)};
else
    handles.t.Data(end+1,:) = cell(1,8);
    handles.tessel(end+1,:) = {[],zeros(0,2)};
end