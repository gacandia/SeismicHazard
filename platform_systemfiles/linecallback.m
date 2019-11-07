function linecallback(hObject,~,handles)

ch=findall(handles.axes3,'type','line');
set(ch,'Linewidth',0.5);

tag=hObject.Tag;
ch=findall(handles.axes3,'tag',tag);
set(ch,'Linewidth',1.5);
uistack(ch,'top');

T=regexp(tag,'\_','split');
i=str2double(T{1});
j=str2double(T{2});

handles.curr_ID.String         =handles.tabla.Data{i,1};
handles.curr_earthquake.String =handles.tabla.Data{i,3};
handles.curr_filename.String   =handles.tabla.Data{i,j};

switch j
    case 10, handles.curr_component.String='H1';
    case 11, handles.curr_component.String='H2';
    case 12, handles.curr_component.String='UP';
end

handles.HideLine.Visible='on';
handles.DeleteSelection.Enable='on';
