function plot_hazard_PSHA(handles,holdcolorbar)

if isempty(handles.MRE)
    return
end
ch=findall(handles.ax2,'Type','line'); delete(ch);

if nargin ==1
   holdcolorbar=false;
end

if holdcolorbar==0
    ch=findall(handles.FIGSeismicHazard,'tag','Colorbar'); delete(ch);
end
ch=findall(handles.FIGSeismicHazard,'type','legend');delete(ch);


switch handles.HazOptions.mod
    case 1
        switch handles.opt.LiteMode
            case 'on',  str = plotHazMode1_lite(handles); % plots averaged seismic hazard
            case 'off', str = plotHazMode1(handles); % plots averaged seismic hazard
        end
    case 2, str = plotHazMode2(handles); % plots single branch hazard for GMMs of type REGULAR
    case 3, str = plotHazMode3(handles); % plots single branch hazard for GMMs of type PCE
end

Leg=legend(handles.ax2,strrep(str,'_',' '));
switch handles.addLeg.Value
    case 0,Leg.Visible='off';
    case 1,Leg.Visible='on';
end
Leg.FontSize=8;
Leg.EdgeColor=[1 1 1];
Leg.Location='SouthWest';
Leg.Tag='hazardlegend';
set(handles.ExportHazard,'enable','on');
