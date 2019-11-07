function plotVs30sources(handles)

if strcmp(handles.Vs30.source,' ')
    delete(findall(handles.ax1,'tag','microzone'))
    delete(findall(handles.ax1,'tag','raster'))
    return
end

for jj = 1:length(handles.Vs30.source)
    DATA = load(handles.Vs30.source{jj});
    if isfield(DATA,'microzone')
        for i=1:length(DATA.microzone)
            LAT=DATA.microzone(i).Lat;
            LON=DATA.microzone(i).Lon;
            col=DATA.microzone(i).col;
            patch(handles.ax1,LON,LAT,col,'tag','microzone','visible','off')
        end
    end
    if isfield(DATA,'raster')
        for i=1:length(DATA.raster)
            LON = DATA.raster(i).box([1 2 2 1],1);
            LAT = DATA.raster(i).box([1 1 2 2],2);
            patch(handles.ax1,LON,LAT,[0.92941       0.6902      0.12941],'facealpha',0.3,'tag','raster','visible','off','edgecolor','k')
        end
    end
end
