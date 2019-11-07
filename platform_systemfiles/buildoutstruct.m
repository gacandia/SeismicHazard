function[statevar]=buildoutstruct(handles,pathname,filename)
%#ok<*NASGU>
fig = handles.FIGSeismicHazard;
%% PLATFORM OPTIONS
if isfield(handles,'sys')
    statevar.data.sys            = handles.sys;
    statevar.data.model          = handles.model;
end
statevar.data.opt            = handles.opt;
statevar.data.h              = handles.h;
statevar.data.im             = handles.im;
statevar.data.Zscenario      = handles.Zscenario;
statevar.data.krate          = handles.krate;
statevar.data.kY             = handles.kY;
statevar.data.TriScatterd    = handles.TriScatterd;
statevar.data.site_selection = handles.site_selection;
statevar.data.plothazmethod  = handles.plothazmethod;
statevar.data.HazOptions     = handles.HazOptions;
statevar.data.isREGULAR      = handles.isREGULAR;
statevar.data.isPCE          = handles.isPCE;
statevar.data.platformMode   = handles.platformMode;
statevar.data.TT             = handles.TT;
statevar.data.Y              = handles.Y;
statevar.data.hdist          = handles.hdist;
statevar.data.optkm          = handles.optkm;
statevar.data.site_colors    = handles.site_colors;
%% heavyweight variables
[~,NameRoot]=fileparts(filename);
tmp=[tempname,'_',NameRoot,'_0.mat']; var = handles.MRE       ; save(tmp,'var');statevar.MRE_path=tmp;
tmp=[tempname,'_',NameRoot,'_2.mat']; var = handles.MREPCE    ; save(tmp,'var');statevar.MREPCE_path=tmp;
tmp=[tempname,'_',NameRoot,'_4.mat']; var = handles.shakefield; save(tmp,'var');statevar.shakefield_path=tmp;
tmp=[tempname,'_',NameRoot,'_5.mat']; var = handles.scenarios ; save(tmp,'var');statevar.scenarios_path=tmp;
tmp=[tempname,'_',NameRoot,'_6.mat']; var = handles.L         ; save(tmp,'var');statevar.L_path=tmp;
tmp=[tempname,'_',NameRoot,'_7.mat']; var = handles.deagg     ; save(tmp,'var');statevar.deagg_path=tmp;
tmp=[tempname,'_',NameRoot,'_8.mat']; var = handles.tessel    ; save(tmp,'var');statevar.tessel_path=tmp;

%% AX1 AND GMAP
ch=findall(handles.ax1,'tag','gmap');
statevar.ax1.XLim     = handles.ax1.XLim;
statevar.ax1.YLim     = handles.ax1.YLim;
statevar.ax1.XGrid    = handles.ax1.XGrid;
statevar.ax1.YGrid    = handles.ax1.YGrid;
statevar.ax1.NextPlot = handles.ax1.NextPlot;
statevar.ch.XData     = ch.XData;
statevar.ch.YData     = ch.YData;
statevar.ch.CData     = ch.CData;
statevar.ch.Visible   = ch.Visible;

%% AX2
statevar.ax2.XScale   = handles.ax2.XScale;
statevar.ax2.YScale   = handles.ax2.YScale;

%% SHAKE PANNEL
statevar.DSHApannel.Visible = handles.DSHApannel.Visible;

%% MENUS
menus     = findall(fig,'type','uimenu');
statevar.menus = cell(length(menus),4);
for i=1:length(menus)
    statevar.menus{i,1}=menus(i).Tag;
    statevar.menus{i,2}=menus(i).Label;
    statevar.menus{i,3}=menus(i).Checked;
    statevar.menus{i,4}=menus(i).Enable;
end

ind = [];
for i=1:length(menus)
    tag = statevar.menus{i,1};
    if isempty(tag)
        ind = [ind;i]; %#ok<*AGROW>
    end
end
statevar.menus(ind,:)=[];

%% UICONTROL
uicontrol = findall(fig,'type','UIControl');
statevar.uicontrol = cell(length(uicontrol),5);
for i=1:length(uicontrol)
    statevar.uicontrol{i,1}=uicontrol(i).Tag;
    statevar.uicontrol{i,2}=uicontrol(i).String;
    statevar.uicontrol{i,3}=uicontrol(i).Value;
    statevar.uicontrol{i,4}=uicontrol(i).Visible;
    statevar.uicontrol{i,5}=uicontrol(i).Enable;
end

ind = [];
for i=1:length(uicontrol)
    tag = statevar.uicontrol{i,1};
    if isempty(tag)
        ind = [ind;i];
    end
end
statevar.uicontrol(ind,:)=[];
statevar.PSHApannel.Visible=handles.PSHApannel.Visible;
statevar.DSHApannel.Visible=handles.DSHApannel.Visible;

%% file saving
save([pathname,filename],'statevar')
