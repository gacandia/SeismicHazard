function varargout = SeismicHazard(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SeismicHazard_OpeningFcn, ...
    'gui_OutputFcn',  @SeismicHazard_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function SeismicHazard_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
home
fprintf(' --------- Seismic Hazard Toolbox ---------\n')
load pshabuttons c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12
handles.form1                      = c1;
handles.form2                      = c2;
handles.engine.CData               = c3;
handles.switchmode.CData           = c4;
handles.addLeg.CData               = c5;
handles.ax2Limits.CData            = c6;
handles.Exit_button.CData          = c7;
handles.Distance_button.CData      = c8;
handles.po_refresh_GE.CData        = c9;
handles.RefreshButton.CData        = c10;
handles.OpenRef.CData              = c11;
handles.ColorSecondaryLines.CData  = c12;
handles.GoogleEarthOpt             = GEOptions('default');

if nargin==3
    handles                  = initializePSHA(handles);
elseif nargin==4
    fname = varargin{1};
    handles=psha_updatemodel(handles,[],fname);
    handles.launch_PSDA.Enable='off';
    plot_sites_PSHA(handles);
end
akZoom(handles.ax1)
guidata(hObject, handles);
% uiwait(handles.FIGSeismicHazard);

function varargout = SeismicHazard_OutputFcn(hObject, eventdata, handles)
varargout{1}=handles;
% delete(handles.FIGSeismicHazard)

function FIGSeismicHazard_CloseRequestFcn(hObject, eventdata, handles)
% if isequal(get(hObject,'waitstatus'),'waiting')
%     uiresume(hObject);
% else
%     delete(hObject);
% end
delete(hObject);

% -----FILE MENU ----------------------------------------------------------
function File_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>

function Reset_Callback(hObject, eventdata, handles)
if isfield(handles,'sys')
    handles = rmfield(handles,{'sys','model','opt'});
end
handles = initializePSHA(handles);
guidata(hObject, handles);

function Clear_Analysis_Callback(hObject, eventdata, handles)
handles = delete_analysis_PSHA(handles);
plot_sites_PSHA(handles);
guidata(hObject, handles);

function InspectInputFile_Callback(hObject, eventdata, handles)
if isfield(handles,'sys')
    if ispc,winopen(handles.sys.filename);end
end

function LoadSession_Callback(hObject, eventdata, handles)
[filename,pathname,FILTERINDEX]=uigetfile('*.mat','Seismic Hazard');
if FILTERINDEX==0
    return
end
load([pathname,filename]) %#ok<LOAD>
handles=loadpreviousPSHA(handles,statevar);
guidata(hObject,handles)

function SaveSession_Callback(hObject, eventdata, handles)
[filename,pathname,FILTERINDEX]=uiputfile('*.mat','Seismic Hazard');
if FILTERINDEX==0
    return
end
statevar=buildoutstruct(handles,pathname,filename);

function LoadTXT_Callback(hObject, eventdata, handles)

function DefaultSeismicity_Callback(hObject, eventdata, handles)
anw = listdlg('PromptString','Default Seismicity Models:',...
    'SelectionMode','single','ListSize',[200 300],...
    'ListString',{...
    'Chile (Martin 1990)'...
    'Chile (Poulos et al., 2018)'...
    'Peru (SENCICO, 2016)',...
    'Mexico (2019)',...
    'Ciudad Universitaria, Mexico (2019)',...
    'USGS (NSHM 2008 Dynamic)',...
    'USGS (NSHM 2014 Dynamic)'});
if isempty(anw)
    return
end
switch anw
    case 1,  handles=psha_updatemodel(handles,'Chile_Default');
    case 2,  handles=psha_updatemodel(handles,'Chile_Poulos');
    case 3,  handles=psha_updatemodel(handles,'Peru_Default');
    case 4,  handles=psha_updatemodel(handles,'Mexico_Default_not_CU');
    case 5,  handles=psha_updatemodel(handles,'MexicoCity_CU_PreviousTectonic_2018_f2');
    case 6,  handles=usgs_updatemodel(handles,'USGS_NHSM_2008');
    case 7,  handles=usgs_updatemodel(handles,'USGS_NHSM_2014');
end

plot_sites_PSHA(handles);

if isfield(handles.sys,'lambdaTest')
    plot(handles.ax2,handles.sys.IM,handles.sys.lambdaTest(1,:),'ko','tag','lambdaTest');
end
guidata(hObject,handles)

function TestModels_Callback(hObject, eventdata, handles)
W = what('platform_testmodels');
D = dir(W.path);
D = D(contains({D.name},'.txt'));
anw = listdlg('PromptString','Test Models:',...
    'SelectionMode','single','ListString',{D.name});
if isempty(anw)
    return
end
handles  =psha_updatemodel(handles,[],fullfile(W.path,D(anw).name));
plot_sites_PSHA(handles);
if isfield(handles.sys,'lambdaTest')
    plot(handles.ax2,handles.sys.IM,handles.sys.lambdaTest(1,:),'ko','tag','lambdaTest');
end
if ispc
    pdffile = fullfile(W.path,strrep(D(anw).name,'.txt','.pdf'));
   if exist(pdffile,'file')
       handles.pdffile = pdffile;
       handles.OpenRef.Visible='on';
   end
end

guidata(hObject, handles);

function ValidationPEER2018_Callback(hObject,envetdata,handles)
anw = listdlg('PromptString','PEER 2018 Validation Tests:',...
    'SelectionMode','single','ListString',{'Test 1.1','Test 1.2','Test 1.3','Test 1.4','Test 1.5',...
    'Test 1.6','Test 1.7','Test 1.8a','Test 1.8b','Test 1.8c','Test 1.10','Test 1.11',...
    'Test 2.1','Test 2.2a','Test 2.2b','Test 2.2c','Test 2.2d',...
    'Test 2.3a','Test 2.3b','Test 2.3c','Test 2.3d'});
if isempty(anw)
    return
end

switch anw
    case 1,  handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_1');
    case 2,  handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_2');
    case 3,  handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_3');
    case 4,  handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_4');
    case 5,  handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_5');
    case 6,  handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_6');
    case 7,  handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_7');
    case 8,  handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_8a');
    case 9,  handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_8b');
    case 10, handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_8c');
    case 11, handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_10');
    case 12, handles=psha_updatemodel(handles,'PEER2018_Set1_Test1_11');
    case 13, handles=psha_updatemodel(handles,'PEER2018_Set2_Test2_1');
    case 14, handles=psha_updatemodel(handles,'PEER2018_Set2_Test2_2a');
    case 15, handles=psha_updatemodel(handles,'PEER2018_Set2_Test2_2b');
    case 16, handles=psha_updatemodel(handles,'PEER2018_Set2_Test2_2c');
    case 17, handles=psha_updatemodel(handles,'PEER2018_Set2_Test2_2d');
    case 18, handles=psha_updatemodel(handles,'PEER2018_Set2_Test2_3a');
    case 19, handles=psha_updatemodel(handles,'PEER2018_Set2_Test2_3b');
    case 20, handles=psha_updatemodel(handles,'PEER2018_Set2_Test2_3c');
    case 21, handles=psha_updatemodel(handles,'PEER2018_Set2_Test2_3d');
end
handles.pdffile = handles.sys.filename;
plot_sites_PSHA(handles);

if isfield(handles.sys,'lambdaTest')
    plot(handles.ax2,handles.sys.IM,handles.sys.lambdaTest(1,:),'ko','tag','lambdaTest');
    Leg=legend(handles.ax2,'Benchmark');
    ch  = findall(handles.FIGSeismicHazard,'tag','hazardlegend');
    Leg.Visible='on';
    Leg.FontSize=8;
    Leg.EdgeColor=[1 1 1];
    Leg.Location='SouthWest';
    Leg.Tag='hazardlegend';
    handles.ax2.XScale='linear';
    handles.ax2.YScale='log';
end
guidata(hObject,handles)

function LoadCustom_Callback(hObject, eventdata, handles)

if isfield(handles,'defaultpath_others')
    [filename,pathname,FILTERINDEX]=uigetfile(fullfile(handles.defaultpath_others,'*.txt'),'select file');
else
    [filename,pathname,FILTERINDEX]=uigetfile(fullfile(pwd,'*.txt'),'select file');
end

if FILTERINDEX==0,return;end
handles=psha_updatemodel(handles,[],[pathname,filename]);
plot_sites_PSHA(handles);
handles.defaultpath_others=pathname;

if isfield(handles.sys,'lambdaTest')
    plot(handles.ax2,handles.sys.IM,handles.sys.lambdaTest(1,:),'ko','tag','lambdaTest');
end
guidata(hObject, handles);

function Export_Results_Callback(hObject, eventdata, handles)

function ExportHazard_Callback(hObject, eventdata, handles)
[FileName,PathName,FILTERINDEX] =  uiputfile('*.out','Save Hazard Analysis As');
if FILTERINDEX==0
    return
end
haz2txt(FileName,PathName,handles)

function ExportIS_Callback(hObject, eventdata, handles)

[FileName,PathName,FILTERINDEX] =  uiputfile('*.bin','Save Hazard Analysis As');
if FILTERINDEX==0
    return
end
dsha_bin(FileName,PathName,handles,'IS'); % new function

function ExportKM_Callback(hObject, eventdata, handles)
[FileName,PathName,FILTERINDEX] =  uiputfile('*.bin','Save Hazard Analysis As');
if FILTERINDEX==0
    return
end
dsha_bin(FileName,PathName,handles,'KM'); % new function

function ExportGE_Image_Callback(hObject, eventdata, handles)

D=what('DEFAULT_MATFILES');
if isempty(D)
    [filename,pathname,FILTERINDEX] =  uiputfile('*.mat','Save Google Earth Image');
else
    [filename,pathname,FILTERINDEX] =  uiputfile([D.path,'\*.mat'],'Save Google Earth Image');
end
if FILTERINDEX==0
    return
end
ch=findall(handles.ax1,'tag','gmap');
if ~isempty(ch)
    xx = ch.XData; yy = ch.YData; cc = ch.CData; %#ok<*NASGU>
    XLIM=handles.ax1.XLim;
    YLIM=handles.ax1.YLim;
    save([pathname,filename],'xx','yy','cc','XLIM','YLIM');
else
    warndlg('No Background Image Found')
end

function Undockax_Callback(hObject, eventdata, handles)

function ExportHazardCurves_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax2)

function ExportMap_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax1)

function Exit_Callback(hObject, eventdata, handles)
close(gcf)

function Exit_button_Callback(hObject, eventdata, handles)
close(handles.FIGSeismicHazard)

% ------EDIT MENU --------------------------------------------------------
function Edit_Callback(hObject, eventdata, handles)

function Update_Global_Parameters_Callback(hObject, eventdata, handles)

old_opt     = handles.opt;
switch handles.sys.filename
    case {'USGS_NHSM_2008','USGS_NHSM_2014'}
        new_opt     = GlobalParamUSGS(handles.opt);
        handles.opt = new_opt;
        handles.IM_select.String=handles.opt.IM;
        if ~structcmp(new_opt,old_opt)
            handles = delete_analysis_PSHA(handles);
        end
    otherwise
        new_opt = GlobalParam(handles.opt);
        Tmax = [];
        for i=1:length(handles.model)
            for j=1:length(handles.model(i).source)
                T    = handles.model(i).source(j).gmpe.T;
                Tmax = [Tmax;max(T)]; %#ok<AGROW>
            end
        end
        Tmax      = min(Tmax);
        Tdeleted  = new_opt.IM(new_opt.IM>Tmax);
        new_opt.IM(new_opt.IM>Tmax) = [];
        
        if ~isempty(Tdeleted)
            h=warndlg({['Analysis for T = ',mat2str(Tdeleted'),'  not available'],...
                'check limits of GMMs'});
            uiwait(h);
        end
        
        handles.opt  = new_opt;
        handles.IM_select.Value  = 1;
        handles.IM_select.String = IM2str(handles.opt.IM);
        if ~structcmp(new_opt,old_opt)
            handles = delete_analysis_PSHA(handles);
        end
        if strcmp(handles.opt.Clusters{1},'on')
            handles.po_clusters.Enable='on';
        else
            handles.po_clusters.Enable='off';
        end
end
[handles.idx,handles.hc] = compute_clusters(handles);
plot_sites_PSHA(handles);
default_maps(handles,handles.ax1);
guidata(hObject, handles);

function LogicTree_Callback(hObject, eventdata, handles)
if ~isfield(handles,'sys'), return;end
handles.sys=PSHA_Logic_Tree(handles.sys);
guidata(hObject,handles)

function SourceGeometry_Callback(hObject, eventdata, handles)
SourceGeometry(handles);
guidata(hObject, handles);

function MagnitudeRecurrence_Callback(hObject, eventdata, handles)
MR_explorer(handles)

function Seismicity_Callback(hObject, eventdata, handles)
GMM_explorer(handles)

function Sites_Callback(hObject, eventdata, handles)

handin.h           = handles.h;
handin.ax          = handles.ax1;
handin.opt         = handles.opt;
handin.Vs30        = handles.sys.VS30;
[h_new,Vs30,index] = SelectLocations(handin);
equalh             = structcmp(handin.h,h_new);

if equalh
    return
end

handles = delete_analysis_PSHA(handles);
handles.site_selection = 1:length(h_new.id);
Nsites = size(h_new.p,1);
handles.site_colors = repmat([0 0 1],Nsites,1);
handles.h                = h_new;
handles.sys.VS30         = Vs30;
handles.index            = index;
handles.site_menu.String = handles.h.id;
handles.site_menu.Value  = 1;
handles.site_menu_psda.String = handles.h.id;
handles.site_menu_psda.Value  = 1;
[handles.idx,handles.hc] = compute_clusters(handles);
plot_sites_PSHA(handles);

guidata(hObject, handles);

function GEmaps_Callback(hObject, eventdata, handles)

if ~exist('api_Key.mat','file')
    warndlg('You must use an API key to authenticate each request to Google Maps Platform APIs. For additional information, please refer to http://g.co/dev/maps-no-account')
    return
end

handles.GoogleEarthOpt=GEOptions(handles.GoogleEarthOpt);
guidata(hObject, handles);

% -----TOOLS MENU --------------------------------------------------------
function SeismicHazardTools_Callback(hObject, eventdata, handles)

function launch_UHS_Callback(hObject, eventdata, handles)
if ~isempty(handles.isREGULAR)
    UHS(handles.sys,handles.model,handles.opt,handles.h)
end

function launch_CMS_Callback(hObject, eventdata, handles)
if ~isempty(handles.isREGULAR)
    CMS(handles.sys,handles.opt,handles.h)
end

function launch_CSS_Callback(hObject, eventdata, handles)

if ~isempty(handles.isREGULAR)
    CSS(handles.sys,handles.opt,handles.h)
end

function launch_CSSIa_Callback(hObject, eventdata, handles)
if ~isempty(handles.isREGULAR)
%     CSSAI(handles.sys,handles.opt,handles.h)
end

function launch_DEAGG_MR_Callback(hObject, eventdata, handles)
switch handles.sys.filename
    case {'USGS_NHSM_2008','USGS_NHSM_2014'}
        % DeaggregationUSGS(handles);
    otherwise
        if ~isempty(handles.isREGULAR)
            DeaggregationMR(handles.sys,handles.model,handles.opt,handles.h);
        end
end
guidata(hObject,handles)

function launch_DEAGG_MRe_Callback(hObject, eventdata, handles)
switch handles.sys.filename
    case {'USGS_NHSM_2008','USGS_NHSM_2014'} % not available
    otherwise
        if ~isempty(handles.isREGULAR)
            DeaggregationMRe(handles.sys,handles.model,handles.opt,handles.h);
        end
end
guidata(hObject,handles)

function launch_PSDA_Callback(hObject, eventdata, handles)
PSDA2(handles.sys,handles.model,handles.opt,handles.h)

function launch_PVSHA_Callback(hObject, eventdata, handles)
if ~isempty(handles.isREGULAR)
    VPSHA(handles.sys,handles.model,handles.opt,handles.h)
end

function launch_CGMM_Callback(hObject, eventdata, handles)
if ~isempty(handles.isPCE)
    CGMM(handles.sys,handles.model,handles.opt,handles.h,handles.HazOptions,handles.isPCE)
end

function launch_GRD_Callback(hObject, eventdata, handles)
if ~isempty(handles.isREGULAR)
    handin.sys    = handles.sys;
    handin.opt    = handles.opt;
    handin.h      = handles.h;
    handin.model  = handles.model;
    handin.GoogleEarthOpt  = handles.GoogleEarthOpt;
    handin.ax     = handles.ax1;
    GRD(handin)
end

% -----PSHA MENU --------------------------------------------------------
function PSHAsetup_Callback(hObject, eventdata, handles)
handles.site_selection=PSHARunOptions(handles);
guidata(hObject,handles)

function PSHAMenu_Callback(hObject, eventdata, handles)

function site_menu_Callback(hObject, eventdata, handles)
plot_hazard_PSHA(handles);
plot_hazardmap_PSHA(handles);
guidata(hObject, handles);

function IM_select_Callback(hObject, eventdata, handles)
plot_hazard_PSHA(handles);
plot_hazardmap_PSHA(handles);
guidata(hObject, handles);

function runMRE_Callback(hObject, eventdata, handles)

opt    = handles.opt;
slist  = handles.site_selection;
idx    = handles.idx;
slistc = 1:length(unique(idx));
str    = sprintf('%s%s',opt.LiteMode,opt.Clusters{1});

switch handles.sys.filename
   case 'USGS_NHSM_2008', handles=runhazUSGS(handles);
   case 'USGS_NHSM_2014', handles=runhazUSGS(handles);
   otherwise
       switch str
           case 'onoff'  , [handles.MRE,handles.MREPCE] = runlogictree0(handles.sys,handles.model,opt,handles.h ,slist);
           case 'onon'   , [handles.MRE,handles.MREPCE] = runlogictree0(handles.sys,handles.model,opt,handles.hc,idx);
           case 'offoff' , [handles.MRE,handles.MREPCE] = runlogictree1(handles.sys,handles.model,opt,handles.h ,slist);
           case 'offon'  , [handles.MRE,handles.MREPCE] = runlogictree1(handles.sys,handles.model,opt,handles.hc,slistc,idx);
       end

       handles.site_menu.Value  = handles.site_selection(1);
       plot_hazard_PSHA(handles);
       handles.site_colors = compute_v(handles);
       plot_hazardmap_PSHA(handles);
end
handles.platformMode = 1;
handles.PSHApannel.Visible='on';
handles.DSHApannel.Visible='off';
handles.switchmode.Enable=enableswitchmode(handles);
handles.switchmode.CData=handles.form1;
handles.switchmode.TooltipString='switch to PSDA mode';
handles.ax2.XScale='log';
handles.ax2.YScale='log';

if ispc && isfield(handles.sys,'lambdaTest')
   comparePEER(handles)
   handles.ax2.XScale='linear';
   handles.ax2.YScale='log';    
end

guidata(hObject, handles);

% ---------------- DSHAMENU MENU----------------------------
function DSHAMenu_Callback(hObject, eventdata, handles)

function CreateScenarios_Callback(hObject, eventdata, handles)
A = handles.scenarios;
[handles.scenarios,handles.tessel,handles.ptrs,handles.ScenOptions] = ...
    ScenarioBuilder(handles.sys,handles.model,handles.opt,A,handles.tessel,handles.ScenOptions);
handles.pop_scenario.Value = 1;
guidata(hObject,handles)

if ~isequal(handles.scenarios,A)
    if isfield(handles,'shakefield')
        handles.shakefield=[];
        handles.DSHApannel.Visible='off';
        delete(findall(handles.ax2,'type','line'));
        delete(findall(handles.FIGSeismicHazard,'type','legend'))
    end
end

Ns   = length(handles.scenarios);
per  = [handles.opt.IM1;handles.opt.IM2];

handles.pop_scenario.String  = compose('scen %i-%i',handles.ptrs);
handles.pop_field.String     = IM2str(per);

if Ns>=1
    handles.Run_DHSA_IS.Enable='on';
    handles.Run_DSHA_KM.Enable='on';
end
guidata(hObject,handles)

function Run_DHSA_IS_Callback(hObject, eventdata, handles)

handles.pop_scenario.Value = 1;
handles    = dsha_assembler2(handles);
plot_scenario_PSDA2(handles);
handles.platformMode = 2;
handles.PSHApannel.Visible='off';
handles.DSHApannel.Visible='on';
handles.switchmode.Enable=enableswitchmode(handles);
handles.switchmode.CData=handles.form2;
handles.switchmode.TooltipString='switch to PSHA mode';
dsha_lambda2(handles,1);

guidata(hObject,handles)

function Run_DSHA_KM_Callback(hObject, eventdata, handles)
answer = inputdlg({'Number of Clusters:','Replicate'},'k-means',[1,35],{'100','5'});
if isempty(answer)
    return
end
handles.optkm = str2double(answer);
[handles.krate,handles.kY] = dsha_kmeans(handles,handles.optkm);
dsha_lambda2(handles,1);
guidata(hObject,handles)

function pop_scenario_Callback(hObject, eventdata, handles)
plot_scenario_PSDA2(handles);
handles.Zscenario=1;
guidata(hObject,handles)

function pop_field_Callback(hObject, eventdata, handles)
plot_scenario_PSDA2(handles);
handles.Zscenario=1;
dsha_lambda2(handles,1);
guidata(hObject,handles)

function RefreshButton_Callback(hObject, eventdata, handles)

plot_scenario_PSDA2(handles);
dsha_lambda2(handles,1);
guidata(hObject,handles)

function show_RA_Callback(hObject, eventdata, handles)
ch = findall(handles.ax1,'tag','scenario');
switch hObject.Value
    case 1,set(ch,'Visible','on');
    case 2,set(ch,'Visible','off');
end
guidata(hObject,handles)

function PSDA_display_mode_Callback(hObject, eventdata, handles)
plot_scenario_PSDA2(handles);
guidata(hObject,handles)

function NumSim_Callback(hObject, eventdata, handles)
dsha_lambda2(handles,1);
guidata(hObject,handles)

function shakecorrmode_Callback(hObject, eventdata, handles)
opt2 = handles.opt;
switch hObject.Value
    case 1 % default
    case 2, opt2.Spectral=@none_spectral;
    case 3, opt2.Spatial=@none_spatial;
    case 4, opt2.Spatial=@none_spatial; opt2.Spectral=@none_spectral;
end
handles.L  = dsha_chol2(handles.shakefield,handles.hdist,opt2);
plot_scenario_PSDA2(handles);
dsha_lambda2(handles,1);
guidata(hObject,handles)

% -----DISPLAY OPTIONS ------------------------------------------------------
function po_grid_Callback(hObject, eventdata, handles)

val = hObject.Value;
switch val
    case 1, grid(handles.ax1,'on')
    case 0, grid(handles.ax1,'off')
end
guidata(hObject,handles);

function Boundary_check_Callback(hObject, eventdata, handles)
ch = findall(handles.ax1,'tag','shape1');
val = hObject.Value;
switch val
    case 1, set(ch,'visible','on');
    case 0, set(ch,'visible','off')
end
guidata(hObject,handles);

function po_sources_Callback(hObject, eventdata, handles)
i   = handles.po_region.Value;
switch hObject.Value
    case 1
        handles.points(i).Visible='on';
        handles.lines(i).Visible='on';
        handles.areas(i).Visible='on';
        
    case 0
        handles.points(i).Visible='off';
        handles.lines(i).Visible='off';
        handles.areas(i).Visible='off';
        handles.linemesh(i).Visible='off';
        handles.areamesh(i).Visible='off';
        handles.po_sourcemesh.Value=0;
end
guidata(hObject,handles);

function po_sourcemesh_Callback(hObject, eventdata, handles)
i   = handles.po_region.Value;
switch hObject.Value
    case 1
        set(handles.linemesh(i),'visible','on');
        set(handles.areamesh(i),'visible','on');
    case 0
        set(handles.linemesh(i),'visible','off');
        set(handles.areamesh(i),'visible','off');
        
end
guidata(hObject,handles);

function po_sites_Callback(hObject, eventdata, handles)
ch=findall(handles.ax1,'tag','siteplot');

switch hObject.Value
    case 1, set(ch,'visible','on');
    case 0, set(ch,'visible','off');
end

v = handles.po_sites.Value+handles.po_contours.Value;
ch = findall(handles.FIGSeismicHazard,'type','ColorBar');
if ~isempty(ch)
    switch v
        case 0    ,ch.Visible='off';
        otherwise ,ch.Visible='on';
    end
end

guidata(hObject,handles);

function po_clusters_Callback(hObject, eventdata, handles)
ch = findall(handles.ax1,'tag','siteplot');

switch hObject.Value
    case 0
        Nsites   = size(handles.h.p,1);
        ch.CData = handles.site_colors;
    case 1
        Nunique = length(unique(handles.idx));
        c = hsv(Nunique);
        ch.CData = c(handles.idx,:);
end

function po_contours_Callback(hObject, eventdata, handles)

switch handles.po_contours.Value
    case 0
        for i=1:size(handles.h.t,1)
            ch = findall(handles.ax1,'tag',num2str(i));
            ch.Visible='off';
        end
        ch=findall(handles.ax1,'Tag','satext');
        if ~isempty(ch)
            ch.Visible='off';
        end
    case 1
        for i=1:size(handles.h.t,1)
            ch = findall(handles.ax1,'tag',num2str(i));
            ch.Visible='on';
        end
        ch=findall(handles.ax1,'Tag','satext');
        if ~isempty(ch)
            ch.Visible='on';
        end
end
v = handles.po_sites.Value+handles.po_contours.Value;
ch = findall(handles.FIGSeismicHazard,'type','ColorBar');
if ~isempty(ch)
    switch v
        case 0    ,ch.Visible='off';
        otherwise ,ch.Visible='on';
    end
end
guidata(hObject, handles);

function po_region_Callback(hObject, eventdata, handles)
i = hObject.Value; %change in geometry selection
set(handles.points,'visible','off');
set(handles.lines,'visible','off');
set(handles.areas,'visible','off');
set(handles.areamesh,'visible','off');
set(handles.linemesh,'visible','off');

Nmodels = length(hObject.String);
for j=1:Nmodels
    set(handles.TT{j},'Visible','off');
end

switch handles.po_sources.Value
    case 1
        handles.points(i).Visible='on';
        handles.lines(i).Visible='on';
        handles.areas(i).Visible='on';
    case 0
        handles.points(i).Visible='off';
        handles.areas(i).Visible='off';
        handles.areas(i).Visible='off';
end

switch handles.po_sourcemesh.Value
    case 1
        handles.areamesh(i).Visible='on';
        handles.linesmesh(i).Visible='on';
    case 0
        handles.areamesh(i).Visible='off';
        handles.linesmesh(i).Visible='off';
end

switch handles.SourceLabels.Value
    case 1, set(handles.TT{i},'Visible','on');
    case 0, set(handles.TT{i},'Visible','off');
end

function po_googleearth_Callback(hObject, eventdata, handles)
ch=findall(handles.ax1,'tag','gmap');
if isempty(ch)
    return
end
switch hObject.Value
    case 0, ch.Visible='off';
    case 1, ch.Visible='on';
end

function po_refresh_GE_Callback(hObject, eventdata, handles)
if handles.opt.ellipsoid.Code==0
    return
end

if ~exist('api_Key.mat','file')
    warndlg('You must use an API key to authenticate each request to Google Maps Platform APIs. For additional information, please refer to http://g.co/dev/maps-no-account')
    return
end

a=1;
if ispc
    a=system('ping -n 1 www.google.com');
elseif isunix
    a=system('ping -c 1 www.google.com');
end
if a==1
    fprintf('Warning: No Internet Access found\n');
    return
end

opt=handles.GoogleEarthOpt;
caxis(handles.ax1);
gmap=plot_google_map(...
    'Axis',handles.ax1,...
    'Height',640,...
    'Width',640,...
    'Scale',2,...
    'MapType',opt.MapType,...
    'Alpha',opt.Alpha,...
    'ShowLabels',opt.ShowLabels,...
    'autoAxis',0,...
    'refresh',0,...
    'Color',opt.Color);

gmap.Tag='gmap';
ch = findall(handles.ax1,'Tag','gmap');
if length(ch)>1
    delete(ch(1))
    ch(1)=[];
end
try %#ok<TRYNC>
    uistack(gmap,'bottom');
    handles.ax1.Layer='top';
end
guidata(hObject,handles)

% ---------CUSTOM TOOLS----------------------------------------------------
function Layers_check_Callback(hObject, eventdata, handles)
ch = findall(handles.ax1,'tag','shape2');
val = hObject.Value;
switch val
    case 1, set(ch,'visible','on');
    case 0, set(ch,'visible','off')
end
guidata(hObject,handles);

function Distance_button_Callback(hObject, eventdata, handles)
ch1=findall(handles.ax1,'tag','patchselect');
ch2=findall(handles.ax1,'tag','patchtxt');
if isempty(ch1) && isempty(ch2)
    ch1=findall(handles.FIGSeismicHazard,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
    ch2=findall(handles.FIGSeismicHazard,'type','uimenu','Enable','on'); set(ch2,'Enable','off');
    XYLIM1 = get(handles.ax1,{'xlim','ylim'});
    if handles.opt.ellipsoid.Code==0
        show_distanceECEF(handles.ax1,'line');
    else
        show_distance(handles.ax1,'line');
    end
    XYLIM2 = get(handles.ax1,{'xlim','ylim'});
    set(handles.ax1,{'xlim','ylim'},XYLIM1);
    set(handles.ax1,{'xlim','ylim'},XYLIM2);
    set(ch1,'Enable','on')
    set(ch2,'Enable','on')
else
    delete(ch1);
    delete(ch2);
end
guidata(hObject, handles);

function CreateAPI_Callback(hObject, eventdata, handles)

prompt = {'Paste API key:'};
title = 'API key';
dims = [1 50];
if exist('api_key.mat','file')
    load api_key.mat apiKey
    definput = {apiKey};
else
    definput = {''};
end
answer = inputdlg(prompt,title,dims,definput);
if isempty(answer)
    return
else
    apiKey = answer{1};
    D=what('platform_apiKey');
    filename = fullfile(D.path,'api_key.mat');
    save(filename,'apiKey');
end

function engine_Callback(hObject, eventdata, handles)

if ~isfield(handles,'model')
    return
end
str = [{handles.model.id};num2cell(horzcat(handles.model.isregular))];
handles.HazOptions = HazardOptions(str,handles.HazOptions,handles.opt.LiteMode);
plot_hazard_PSHA(handles);
model_ptr = handles.HazOptions.sbh(1);
if handles.model(model_ptr).isregular
    % plots maps only for regular GMMs
    handles.site_colors = compute_v(handles);
    plot_hazardmap_PSHA(handles);
end
guidata(hObject,handles)

function addLeg_Callback(hObject, eventdata, handles)

ch = findall(handles.FIGSeismicHazard,'tag','hazardlegend');
if ~isempty(ch)
    switch ch.Visible
        case 'on',  ch.Visible='off';
        case 'off', ch.Visible='on';
    end
end
guidata(hObject,handles);

function site_menu_psda_Callback(hObject, eventdata, handles)
dsha_lambda2(handles,1);
guidata(hObject,handles)

function ax2Scale_Callback(hObject, eventdata, handles)
XYSCALE=[handles.ax2.XScale,handles.ax2.YScale];

switch XYSCALE
    case 'linearlinear', handles.ax2.XScale='log';
    case 'loglinear',    handles.ax2.XScale='linear'; handles.ax2.YScale='log';
    case 'linearlog',    handles.ax2.XScale='log';
    case 'loglog',       handles.ax2.XScale='linear'; handles.ax2.YScale='linear';
end

function ax2Grid_Callback(hObject, eventdata, handles)

XY=[handles.ax2.XGrid,handles.ax2.XMinorGrid];
switch XY
    case 'offoff',handles.ax2.XGrid='off'; handles.ax2.XMinorGrid='on';  handles.ax2.YGrid='off'; handles.ax2.YMinorGrid='on';
    case 'offon' ,handles.ax2.XGrid='on';  handles.ax2.XMinorGrid='off'; handles.ax2.YGrid='on';  handles.ax2.YMinorGrid='off';
    case 'onoff' ,handles.ax2.XGrid='on';  handles.ax2.XMinorGrid='on';  handles.ax2.YGrid='on';  handles.ax2.YMinorGrid='on';
    case 'onon'  ,handles.ax2.XGrid='off'; handles.ax2.XMinorGrid='off'; handles.ax2.YGrid='off'; handles.ax2.YMinorGrid='off';
end
guidata(hObject,handles)

function ax2Limits_Callback(hObject, eventdata, handles)
handles.ax2=ax2Control(handles.ax2);

function switchmode_Callback(hObject, eventdata, handles)

switch handles.platformMode
    case 1
        handles.switchmode.CData=handles.form2;
        handles.switchmode.TooltipString='switch to PSHA mode';
        handles.platformMode = 2;
        handles.PSHApannel.Visible='off';
        handles.DSHApannel.Visible='on';
        dsha_lambda2(handles,1);
        plot_scenario_PSDA2(handles);
        
    case 2
        handles.switchmode.CData=handles.form1;
        handles.switchmode.TooltipString='switch to DSHA mode';
        handles.platformMode=1;
        handles.PSHApannel.Visible='on';
        handles.DSHApannel.Visible='off';
        plot_hazard_PSHA(handles);
        plot_sites_PSHA(handles);
        if ~isempty(handles.h.t)
            handles.po_contours.Enable='on';
            handles.po_contours.Value=1;
            plot_hazardmap_PSHA(handles);
        end
        handles.ax2.XScale='log';
        handles.ax2.YScale='log';
end
guidata(hObject,handles)

function SourceLabels_Callback(hObject, eventdata, handles)

val = handles.po_region.Value;
switch hObject.Value
    case 0, set(handles.TT{val},'visible','off')
    case 1, set(handles.TT{val},'visible','on')
end

function Help_Callback(hObject, eventdata, handles)

function QueryMem_Callback(hObject, eventdata, handles)

M= memory;
flds  = fields(handles);
usedM = zeros(size(flds,1),3);
for i =1:length(flds)
    tmp = handles.(flds{i});
    tmp = whos('tmp');
    sp  = tmp.bytes/M.MemAvailableAllArrays*100;
    if sp>0.01
        usedM(i,:)= [i,tmp.bytes,sp];
    end
end
usedM(usedM(:,1)==0,:)=[];
[~,IND]=sortrows(usedM,-2);
UHand    = M.MemUsedMATLAB/M.MemAvailableAllArrays*100;
tab      = [flds(usedM(IND,1)),num2cell(usedM(IND,2:3))];
Variable = ['Matlab';tab(:,1)];
Size     = [M.MemUsedMATLAB;tab(:,2)];
Usage    = [UHand;tab(:,3)];
T        = table(Variable,Size,Usage);
home
disp(T);

function EnableLightMode_Callback(hObject, eventdata, handles)

switch hObject.Checked
    case 'off'
        hObject.Checked='on';
        handles.engine.Enable='inactive';
    case 'on'
        hObject.Checked='off';
        handles.engine.Enable='on';
end

function About_Callback(hObject, eventdata, handles)
if ispc
    winopen('pshatoolbox_about.txt')
end

function OpenRef_Callback(hObject, eventdata, handles)
if ispc && ~isempty(handles.pdffile) && contains(handles.pdffile,'.pdf')
    winopen(handles.pdffile)
end

function ColorSecondaryLines_Callback(hObject, eventdata, handles)

plot_hazard_PSHA(handles);
