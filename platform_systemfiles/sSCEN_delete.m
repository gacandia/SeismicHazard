function[handles]=sSCEN_delete(handles)

Sdata = size(handles.t.Data,1);
if Sdata==0, return; end
if isempty(handles.current),  return; end

ind = handles.current(:,1);

if Sdata==1
    handles.current=[];
else
    handles.current=[1,handles.current(2)];
end
handles.t.Data(ind,:)=[];
handles.tessel(ind,:)=[];
handles.voroni.XData=nan;
handles.voroni.YData=nan;
handles.hyp.XData=nan;
handles.hyp.YData=nan;