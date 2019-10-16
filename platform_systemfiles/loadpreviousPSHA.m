function [handles]=loadpreviousPSHA(handles,statevar)

fig = handles.FIGSeismicHazard;

%% MENUS
for i=1:size(statevar.menus,1)
    ch = findall(fig,'tag',statevar.menus{i,1});
    if ~isempty(ch)
        ch.Label   =  statevar.menus{i,2};
        ch.Checked =  statevar.menus{i,3};
        ch.Enable  =  statevar.menus{i,4};
    end
end

%% UICONTROLS
for i=1:size(statevar.uicontrol,1)
    ch = findall(fig,'tag',statevar.uicontrol{i,1});
    ch.String  =  statevar.uicontrol{i,2};
    ch.Value   =  statevar.uicontrol{i,3};
    ch.Visible =  statevar.uicontrol{i,4};
    ch.Enable  =  statevar.uicontrol{i,5};
end

%% DATA
if isfield(statevar.data,'sys')
    handles.sys            = statevar.data.sys;
    handles.model          = statevar.data.model;
end
handles.opt            = statevar.data.opt;
handles.h              = statevar.data.h;
handles.im             = statevar.data.im;
handles.Zscenario      = statevar.data.Zscenario;
handles.krate          = statevar.data.krate;
handles.kY             = statevar.data.kY;
handles.TriScatterd    = statevar.data.TriScatterd;
handles.site_selection = statevar.data.site_selection;
handles.plothazmethod  = statevar.data.plothazmethod;
handles.HazOptions     = statevar.data.HazOptions;
handles.isREGULAR      = statevar.data.isREGULAR;
handles.isPCE          = statevar.data.isPCE;
handles.platformMode   = statevar.data.platformMode;
handles.TT             = statevar.data.TT;
handles.Y              = statevar.data.Y;
handles.hdist          = statevar.data.hdist;
handles.optkm          = statevar.data.optkm;
handles.site_colors    = statevar.data.site_colors;


load(statevar.MRE_path         ,'var');handles.MRE        = var; %#ok<*LTARG>
load(statevar.MREPCE_path      ,'var');handles.MREPCE     = var;
load(statevar.shakefield_path  ,'var');handles.shakefield = var;
load(statevar.scenarios_path   ,'var');handles.scenarios  = var;
load(statevar.L_path           ,'var');handles.L          = var;
load(statevar.deagg_path       ,'var');handles.deagg      = var;
load(statevar.tessel_path      ,'var');handles.tessel     = var;

%% AX1 PROPERTIES
handles.ax1.XLim     = statevar.ax1.XLim;
handles.ax1.YLim     = statevar.ax1.YLim;
handles.ax1.XGrid    = statevar.ax1.XGrid;
handles.ax1.YGrid    = statevar.ax1.YGrid;
handles.ax1.NextPlot = statevar.ax1.NextPlot;

delete(findall(handles.ax1,'tag','gmap'));
gmap=image(...
    statevar.ch.XData,...
    statevar.ch.YData,...
    statevar.ch.CData,...
    'Parent', handles.ax1);
gmap.Tag         = 'gmap';
gmap.Visible = statevar.ch.Visible;
handles.ax1.YDir = 'normal';
uistack(gmap,'bottom');
handles.ax1.Layer='top';

%% AX2 PROPERTIES
axis(handles.ax2,'auto');
handles.ax2.XScale   = statevar.ax2.XScale;
handles.ax2.YScale   = statevar.ax2.YScale;

%% UPDATE GRAPHICAL OBJECTS
handles.PSHApannel.Visible = statevar.PSHApannel.Visible;
handles.DSHApannel.Visible = statevar.DSHApannel.Visible;
if isfield(handles,'sys')
    handles = plot_geometry_PSHA(handles);
    plot_sites_PSHA(handles);
end

if strcmp(handles.PSHApannel.Visible,'on')
    handles.switchmode.CData=handles.form1;
    plot_hazard_PSHA(handles);
    handles.siteplot.ButtonDownFcn={@site_click_PSHA;handles;1};
    plot_hazardmap_PSHA(handles);
end

if strcmp(handles.DSHApannel.Visible,'on')
    handles.switchmode.CData=handles.form2;
    dsha_lambda(handles,1);
end



