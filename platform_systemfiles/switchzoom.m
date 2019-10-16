function[]=switchzoom(hObject,eventdata,zmode) %#ok<*INUSL>

set(gca,'xlim',zmode{2},'ylim',zmode{3})

switch zmode{1}
    case 0, akZoom(gca);
    case 1, akZoomX(gca);
    case 2, akZoomY(gca);
end

