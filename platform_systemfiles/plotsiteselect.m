function plotsiteselect(handles)

site  = cell2mat(handles.p.Data(:,2:5));
delete(findall(handles.ax1,'tag','siteplot'))
delete(findall(handles.figure2,'Tag','Colorbar'));
if isempty(site)
    return
end

Lat   = site(:,1)';
Lon   = site(:,2)';
CData = site(:,4)';
scatter(handles.ax1,Lon,Lat,20,CData,'filled','markeredgecolor','k','tag','siteplot');
caxis('auto')
colormap(parula);
C=colorbar('peer',handles.ax1,'location','eastoutside','position',[0.94 0.16 0.02 0.65]);
C.Title.String='Vs30(m/s)';
