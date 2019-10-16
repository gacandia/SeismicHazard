function handles = delete_analysis_PSHA(handles)

handles.MRE       = [];
handles.MRD       = [];
handles.MREPCE    = cell(0,0);
handles.MRDPCE    = cell(0,0);
handles.deagg     = [];
handles.Y         = [];
ch=findall(handles.FIGSeismicHazard,'tag','Colorbar');delete(ch);

handles.TriScatterd = cell(0,1);
handles.ExportPSHAMenu.Enable='off';
handles.Export_Deaggregation.Enable='off';
handles.HazardMap.Enable='off';
handles.MapOptionsButton.Enable='inactive';
handles.db_type.Enable='off';

ch=findall(handles.ax1,'Tag','scenario');delete(ch);
ch=findall(handles.ax1,'Tag','satext');delete(ch);
nt = size(handles.h.t,1);
for i=1:nt
    ch = findall(handles.ax1,'tag',num2str(i));
    delete(ch);
end
ch=findall(handles.ax2,'Type','line');        delete(ch);
ch=findall(handles.FIGSeismicHazard,'tag','Colorbar'); delete(ch);
ch=findall(handles.FIGSeismicHazard,'type','legend');delete(ch);

Nsites = size(handles.h.p,1);
if Nsites>0
    handles.site_colors = repmat([0 0 1],Nsites,1);
end