function site_click_PSDA(hObject, eventdata, handles,entrymode) %#ok<INUSL>

delete(findall(handles.ax1,'Tag','satext'));
if isempty(handles.MRE) && isempty(handles.shakefield)
    return
end

if entrymode==1
    gps    = [get(hObject,'XData')',get(hObject,'YData')'];
    point  = get(handles.ax1,'CurrentPoint');
    point  = point(1,1:2);
    Ngps   = size(gps,1);
    select = point(ones(Ngps,1),:);
    disc   = sum((select-gps).^2,2);
    [~,B]  = min(disc);
    handles.site_menu_psda.Value = B;
    x=handles.h.p(B,2);
    y=handles.h.p(B,1);
    if ~isempty(handles.Y)
        u=handles.Y(B);
        str = ['  ',num2str(u,3),'g'];
        text(x,y,str,'parent',handles.ax1,'Tag','satext','visible','on','verticalalignment','middle');
    end
end

if entrymode==2
    Tag = str2double(get(hObject,'Tag'));
    F   = handles.TriScatterd{Tag};
    coordinates = get(handles.ax1,'CurrentPoint');
    x   = coordinates(1,1);
    y   = coordinates(1,2);
    Fxy = F(x,y);
    str = ['+ ',num2str(Fxy,3),'g'];
    text(x,y,str,'parent',handles.ax1,'Tag','satext','visible','on');
end


