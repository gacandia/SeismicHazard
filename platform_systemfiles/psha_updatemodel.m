function handles=psha_updatemodel(handles,matfile,fname)
handles  = initializePSHA(handles);

if nargin==2 && exist([matfile,'.mat'],'file')==2
    load(matfile,'sys','model','opt','h')
    handles.sys   = sys; %#ok<*NODEF>
    handles.model = model;
    handles.opt   = opt;
    handles.h     = h;
    
elseif nargin==2 && exist([matfile,'.mat'],'file')~=2
    handles.sys = []; handles.model = []; handles.opt = []; handles.h  = [];    
    fname = [matfile,'.txt'];
    [handles.sys,handles.opt,handles.h]= loadPSHA(fname);
    handles.model = process_model(handles.sys,handles.opt);
    sys   = handles.sys;  %#ok<*NASGU>
    opt   = handles.opt;
    h     = handles.h;
    model = handles.model;
    
    %D=what('platform_defaultmodels'); save([D.path,'\',matfile],'model','h','sys','opt');
    
elseif nargin==3
    handles.sys = []; handles.model = []; handles.opt = []; handles.h  = [];    
    [handles.sys,handles.opt,handles.h]= loadPSHA(fname);
    handles.model = process_model(handles.sys,handles.opt);
end



handles.isREGULAR = find(horzcat(handles.model.isregular)==1);
handles.isPCE     = find(horzcat(handles.model.isregular)==0);

handles.site_selection = 1:size(handles.h.p,1);
handles.FIGSeismicHazard.Name=[handles.sys.filename,' - Seismic Hazard'];
delete(findall(handles.ax2,'type','line'));

handles.HazOptions.mod = 1;
handles.HazOptions.avg = [1 0 0 50 0];
handles.HazOptions.sbh = [1 0 0 1];
handles.HazOptions.dbt = [1 0 0 50];
handles.HazOptions.map = [475 1];
handles.HazOptions.pce = [0 1 50];
handles.HazOptions.rnd = 1;

% ---  Updates Period Selection ---
handles.IM_select.Value  = 1;
handles.IM_select.String = IM2str(handles.opt.IM);

% Updates Po-Region
if length(handles.sys.GEOM)>1
    handles.po_region.Enable='on';
    handles.po_region.Visible='on';
    handles.po_region.String={handles.sys.GEOM.id};
end

handles=plot_geometry_PSHA(handles);
xlabel(handles.ax2,handles.IM_select.String{1},'fontsize',8);

handles.InspectInputFile.Enable  = 'on';
handles.Edit.Enable              = 'on';
handles.Boundary_check.Enable    = 'on'; handles.Boundary_check.Value = 1;
handles.Layers_check.Enable      = 'on'; handles.Layers_check.Value      = 0;
default_maps(handles,handles.ax1);

if isempty(handles.opt.Image)
    rat = diff(handles.ax1.YLim)/diff(handles.ax1.XLim);
    axis(handles.ax1,'equal');
    axis(handles.ax1,'auto');
    XL = handles.ax1.XLim;
    YC = mean(handles.ax1.YLim);
    handles.ax1.YLim=YC+rat*diff(XL)*[-1 1];
end

if isfield(handles,'h') && ~isempty(handles.h.id)
    handles.PSHAMenu.Enable='on';
    handles.DSHAMenu.Enable='on';
    handles.SeismicHazardTools.Enable='on';
    handles.runMRE.Enable='on';
    handles.runMRD.Enable='on';
    handles.Compute_UHS.Enable='on';
end

if strcmp(handles.opt.Clusters{1},'on')
    handles.po_clusters.Enable='on';
end
[handles.idx,handles.hc] = compute_clusters(handles);
Nsites = size(handles.h.p,1);
handles.site_colors = repmat([0 0 1],Nsites,1);
