function plot_sites_PSHA(handles)

delete(findall(handles.ax1,'tag','siteplot'));

if isempty(handles.h.p)
    handles.po_sites.Enable='off';
    handles.po_clusters.Enable='off';
    handles.runMRE.Enable='off';
    handles.runMRD.Enable='off';
    handles.ShakeField.Enable='off';
    handles.ExploreDeagg.Enable='off';
    return
else
    handles.po_sites.Enable='on';
    if strcmp(handles.opt.Clusters{1},'on')
        handles.po_clusters.Enable='on';
    else
        handles.po_clusters.Enable='off';
    end
end

if strcmp(handles.opt.Clusters{1},'on') && handles.po_clusters.Value==1
    Nunique = length(unique(handles.idx));
    c = hsv(Nunique);
    c = c(handles.idx,:);
else
    c = handles.site_colors;
end

switch handles.po_sites.Value
    case 0, scatter(handles.ax1,handles.h.p(:,2),handles.h.p(:,1),16,c,'filled','markeredgecolor','none','tag','siteplot','ButtonDownFcn',{@site_click_PSHA;handles;1},'visible','off');
    case 1, scatter(handles.ax1,handles.h.p(:,2),handles.h.p(:,1),16,c,'filled','markeredgecolor','none','tag','siteplot','ButtonDownFcn',{@site_click_PSHA;handles;1},'visible','on');
end


if isfield(handles,'model')
    switch handles.model(1).id
        case 'USGS_NHSM_2008'
            handles.PSHAMenu.Enable='on';
            handles.DSHAMenu.Enable='off';
            handles.SeismicHazardTools.Enable='off';
            handles.runMRE.Enable='on';
            handles.runMRD.Enable='off';
        case 'USGS_NHSM_2014'
            handles.PSHAMenu.Enable='on';
            handles.DSHAMenu.Enable='off';
            handles.SeismicHazardTools.Enable='off';
            handles.runMRE.Enable='on';
            handles.runMRD.Enable='off';
        otherwise
            handles.PSHAMenu.Enable='on';
            handles.DSHAMenu.Enable='on';
            handles.SeismicHazardTools.Enable='on';
            handles.runMRE.Enable='on';
            handles.runMRD.Enable='on';
    end
else
    handles.Shakefield.Enable='off';
    handles.Run.Enable='off';
end

if ~isempty(handles.h.id)
    handles.site_menu.String = handles.h.id;
    handles.site_menu_psda.String = handles.h.id;
    if isempty(handles.site_selection)
        handles.site_menu.Value  = 1;
        handles.site_menu_psda.Value  = 1;
    else
        handles.site_menu.Value       = handles.site_selection(1);
        handles.site_menu_psda.Value  = handles.site_selection(1);
    end
    ch=findall(handles.ax1,'tag','siteplot');
    uistack(ch, 'top');
end

