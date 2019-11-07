function handles=usgs_updatemodel(handles,usgssource)
handles  = initializePSHA(handles);

load pshatoolbox_RealValuesUSGS.mat opt

opt.LiteMode='off';
opt.Clusters={'off',[100 1]};

sys.filename = usgssource;
sys.VS30.baseline = 760;
sys.VS30.source   = {' '};

% creades USGS model structure
model.id  = usgssource;
model.id1 = 'Default';
model.id2 = 'Default';
model.id3 = 'Default';
model.isregular = 1;
switch usgssource
    case 'USGS_NHSM_2008'
        opt.Edition = 'E2008';
        model.source(1)=build_empty_source('Grid');
        model.source(2)=build_empty_source('Slab');
        model.source(3)=build_empty_source('Interface');
        model.source(4)=build_empty_source('Fault');
        
    case 'USGS_NHSM_2014'
        opt.Edition = 'E2014';
        model.source(1)=build_empty_source('System');
        model.source(2)=build_empty_source('Grid');
        model.source(3)=build_empty_source('Slab');
        model.source(4)=build_empty_source('Interface');
        model.source(5)=build_empty_source('Fault');        
end

sys.BRANCH                  = [1 1 1];
sys.WEIGHT                  = [1 1 1 1];

handles.opt                 = opt;
handles.model               = model;
handles.sys                 = sys;

handles.isREGULAR = find(horzcat(handles.model.isregular)==1);
handles.isPCE     = find(horzcat(handles.model.isregular)==0);



handles.FIGSeismicHazard.Name=[handles.sys.filename,' - Seismic Hazard'];
delete(findall(handles.ax2,'type','line'));

handles=plot_geometry_PSHA(handles);
xlabel(handles.ax2,handles.IM_select.String{1},'fontsize',10);
handles.InspectInputFile.Enable  = 'on';
handles.Edit.Enable              = 'on';
handles.Boundary_check.Enable    = 'on'; handles.Boundary_check.Value = 1;
handles.Layers_check.Enable      = 'on'; handles.Layers_check.Value      = 0;
handles.Enable_Deaggregation.Checked='off';
default_maps(handles,handles.ax1);

if isempty(handles.opt.Image)
    rat = diff(handles.ax1.YLim)/diff(handles.ax1.XLim);
    axis(handles.ax1,'equal');
    axis(handles.ax1,'auto');
    XL = handles.ax1.XLim;
    YC = mean(handles.ax1.YLim);
    handles.ax1.YLim=YC+rat*diff(XL)*[-1 1];
    akZoom(handles.ax1);
end

if isfield(handles,'h') && size(handles.h.p,1)>0
    handles.PSHAMenu.Enable='on';
    handles.DSHAMenu.Enable='on';
    handles.Run.Enable='on';    
    handles.Compute_UHS.Enable='on';
end

handles.pop_branch.String={handles.model.id};
handles.pop_branch.Enable='on';

if strcmp(handles.opt.Clusters{1},'on')
    handles.po_clusters.Enable='on';
end


