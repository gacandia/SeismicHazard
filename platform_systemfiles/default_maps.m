function default_maps(h,ax)

delete(findall(ax,'tag','gmap'));
delete(findall(ax,'tag','shape1'));
delete(findall(ax,'tag','shape2'));

if isempty(h.opt.Image) 
    h.opt.Image = 'pshatoolbox_emptyGEmap.mat';
end
DATA         = load(h.opt.Image);
ax.XLim      = DATA.XLIM;
ax.YLim      = DATA.YLIM;
gmap         = image(DATA.xx,DATA.yy,DATA.cc, 'Parent', ax);
gmap.Tag     = 'gmap';
gmap.Visible = 'on';
ax.YDir      = 'normal';
uistack(gmap,'bottom');

h.ax1.ColorOrderIndex=1;
% shape1
if ~isempty(h.opt.Boundary)
    data = shaperead(h.opt.Boundary, 'UseGeoCoords', true);
    h.Boundary_check.Enable='on';
    switch h.Boundary_check.Value
        case 0,vis = 'off';
        case 1,vis = 'on';
    end
    plot(ax,horzcat(data.Lon),horzcat(data.Lat),'tag','shape1','visible',vis);
end

% shape2
if ~isempty(h.opt.Layer)
    data = shaperead(h.opt.Layer, 'UseGeoCoords', true);
    h.Layers_check.Enable='on';
    switch h.Layers_check.Value
        case 0,vis = 'off';
        case 1,vis = 'on';
    end    
    plot(ax,horzcat(data.Lon),horzcat(data.Lat),'tag','shape2','visible',vis);
end

ax.Layer='top';
setTickLabel(ax);

