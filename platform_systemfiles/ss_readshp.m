function handles=ss_readshp(handles,filename,pathname)

boundingbox = [handles.ax1.XLim;handles.ax1.YLim]';
grid_data   = cell2mat(handles.grid_data.Data(:,[2,1]));
p = shape_import(0,[pathname,filename],boundingbox,grid_data);
set(handles.p,'data',p);
Lat = cell2mat(p(:,2));
Lon = cell2mat(p(:,3));
set(handles.siteplot,'XData',Lon,'YData',Lat)
Ngrid     = 0;
handles.t = cell(Ngrid,2);