function varargout = PSDA2(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PSDA2_OpeningFcn, ...
    'gui_OutputFcn',  @PSDA2_OutputFcn, ...
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

function PSDA2_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

load psdabuttons c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13
handles.CDataOpen                 = c1; 
handles.CDataClosed               = c2; 
handles.toggle1.CData             = c3; 
handles.runREG.CData              = c4; 
handles.ax2Limits.CData           = c5; 
handles.REG_DisplayOptions.CData  = c6; 
handles.treebutton.CData          = c7; 
handles.deleteButton.CData        = c8; 
handles.undock.CData              = c9; 
handles.runCDM.CData              = c10;
handles.CDM_DisplayOptions.CData  = c11;
handles.ColorSecondaryLines.CData = c12;
handles.ref1.CData                = c13;
xlabel(handles.ax1,'d (cm)','fontsize',10)
ylabel(handles.ax1,'Mean Rate of Exceedance','fontsize',10)

%% Retrieve data from SeismicHazard
if nargin==7 % called from SeismicHazard Toolbox
    handles = mat2psda(handles,varargin{:});
end
[handles.REG_Display,handles.CDM_Display]   = defaultPSDA_plotoptions;
handles.haz   = [];
handles.haz2  = [];
handles.AnalysisType = 'FPPBA';
guidata(hObject, handles);
% uiwait(handles.FIGpsda);

function varargout = PSDA2_OutputFcn(hObject, eventdata, handles)
varargout{1} = [];

% ----------------  FILE MENU ---------------------------------------------
function File_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function Load_Callback(hObject, eventdata, handles)

function OpenDrivingFile_Callback(hObject, eventdata, handles)

if ispc && isfield(handles,'sys')
    winopen(handles.sys.filename)
end

function ImportFromTextFile_Callback(hObject, eventdata, handles)

if isfield(handles,'defaultpath_others')
    [filename,pathname,FILTERINDEX]=uigetfile(fullfile(handles.defaultpath_others,'*.txt'),'select file');
else
    [filename,pathname,FILTERINDEX]=uigetfile(fullfile(pwd,'*.txt'),'select file');
end

if FILTERINDEX==0,return;end

% loads hazard curves
handles.defaultpath_others=pathname;
handles = wipePSDAModel(handles);
handles = mat2psda(handles,pathname,filename);
handles.dlist = SuitedForDeagg(handles);
if ~isempty(handles.dlist)
    handles.runMRDeagg.Enable='on';
else
    handles.runMRDeagg.Enable='off';
end
handles.FIGpsda.Name = sprintf('%s - Probabilistic Slope Displacement Analysis - PSDA',filename);
guidata(hObject,handles)

function ValidationModels_Callback(hObject, eventdata, handles)

W = what('platform_testmodels');
D = dir(W.path);
D = D(contains({D.name},'.txt'));
anw = listdlg('PromptString','Test Models:',...
    'SelectionMode','single','ListString',{D.name});
if isempty(anw)
    return
end
pathname = D(anw).folder;
filename = D(anw).name;
handles.defaultpath_others=pathname;
handles = wipePSDAModel(handles);
handles = mat2psda(handles,pathname,filename);
handles.dlist = SuitedForDeagg(handles);

if ~isempty(handles.dlist)
    handles.runMRDeagg.Enable='on';
else
    handles.runMRDeagg.Enable='off';
end
handles.FIGpsda.Name = sprintf('%s - Probabilistic Slope Displacement Analysis - PSDA',filename);

if ispc
    pdffile = fullfile(W.path,strrep(D(anw).name,'.txt','.pdf'));
   if exist(pdffile,'file')
       handles.pdffile = pdffile;
       handles.ref1.Visible='on';
   end
end

guidata(hObject,handles)

function Exit_Callback(hObject, eventdata, handles)
close(handles.FIGpsda)

function FIGpsda_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

% ----------------  EDIT MENU ---------------------------------------------
function Edit_Callback(hObject, eventdata, handles)

function ViewSeismicHazard_Callback(hObject, eventdata, handles)
SeismicHazard(handles.sys.filename)

function DModelExplorer_Callback(hObject, eventdata, handles)
if isfield(handles,'ky_param')
    DmodelExplorer(handles.ky_param,handles.Ts_param,handles.sys.SMLIB)
else
    DmodelExplorer;
end
% ----------------  ANALYSIS PARAMETERS MENU ---------------------------------------------
function Analysis_Callback(hObject, eventdata, handles)

function runREG_Callback(hObject, eventdata, handles)
if ~isfield(handles,'sys'), return;end
if ~isempty(handles.model)
    % Hazard for FPBPA
    handles.haz = haz_PSDA(handles);
    if strcmp(handles.AnalysisType,'PBPA')
        % Hazard for PBPA
        handles.haz = FP2PH(handles);
    end
    
    handles     = runPSDA_regular(handles);
    handles.deleteButton.CData  = handles.CDataClosed;
    plot_PSDA_regular(handles)
end
handles.kdesign.Enable='on';
guidata(hObject,handles)

function runCDM_Callback(hObject, eventdata, handles)
if ~isfield(handles,'sys'), return;end
if ~isempty(handles.modelcdm)
    handles.haz2 = haz_PSDA_cdmM(handles);
    handles      = runPSDA_cdm(handles);
    handles.deleteButton.CData  = handles.CDataClosed;
    plot_PSDA_cdm(handles)
end
guidata(hObject,handles)

function deleteButton_Callback(hObject, eventdata, handles)
delete(findall(handles.ax1,'type','line'));
handles.deleteButton.CData  = handles.CDataOpen;
guidata(hObject,handles)

% ----------------  POP MENUS ---------------------------------------------

function pop_source_Callback(hObject, eventdata, handles)

function pop_source_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pop_site_Callback(hObject, eventdata, handles)
plot_PSDA_regular(handles);
guidata(hObject,handles)

function pop_site_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ----------------  PLOTTING  ---------------------------------------------

function mouseClick(hObject,eventdata,handles)

x        = getAbsCoords(handles.ax1);
d_ptr    = interp1(handles.d,(1:length(handles.d))',x,'nearest','extrap');
d        = handles.d(d_ptr);
ch       = findall(handles.ax1,'tag','line');
ch.XData = d*[1 1];
ch.YData = handles.ax1.YLim;

function [x, y] = getAbsCoords(h_ax)
crd = get(h_ax, 'CurrentPoint');
x = crd(2,1);
y = crd(2,2);

function tableREG_CellSelectionCallback(hObject, eventdata, handles)
guidata(hObject,handles)

function REG_DisplayOptions_Callback(hObject, eventdata, handles)
Nbranches = size(handles.tableREG.Data,1);
str       = compose('Branch %g',(1:Nbranches)');
handles.REG_Display = Display_Options_REG(str,handles.REG_Display);
plot_PSDA_regular(handles);
guidata(hObject,handles)

function treebutton_Callback(hObject, eventdata, handles)

if ~isfield(handles,'sys')
    return
end

[handles.T1,handles.T2,handles.T3,handles.Ts_param,handles.ky_param,handles.AnalysisType]=PSDA_Logic_tree2(...
    handles.model,...
    handles.sys,...
    handles.Ts_param,...
    handles.ky_param,...
    handles.T1,...
    handles.T2,...
    handles.T3,...
    handles.AnalysisType);

[handles.tableREG.Data,handles.IJK]=main_psda(handles.T1,handles.T2,handles.T3);
handles.dlist = SuitedForDeagg(handles);
if ~isempty(handles.dlist)
    handles.runMRDeagg.Enable='on';
else
    handles.runMRDeagg.Enable='off';
end
guidata(hObject,handles)

function ax2Limits_Callback(hObject, eventdata, handles)
handles.ax1=ax2Control(handles.ax1);

function OptionsPSDA_Callback(hObject, eventdata, handles)
if isfield(handles,'paramPSDA')
    handles.paramPSDA=PSDA2Parameters(handles.paramPSDA);
    guidata(hObject,handles)
end

function ClearModel_Callback(hObject, eventdata, handles)
handles=wipePSDAModel(handles);
guidata(hObject,handles)

function handles=wipePSDAModel(handles)

if isfield(handles,'sys')
    handles=rmfield(handles,{'sys','model','modelcdm','opt','h'});
end
[handles.REG_Display,handles.CDM_Display]   = defaultPSDA_plotoptions;
handles.haz               = [];
handles.haz2              = [];
handles.FIGpsda.Name      = 'Probabilistic Slope Displacement Analysis - PSDA';
handles.tableREG.Data     = cell(0,4);
handles.tableCDM.Data     = cell(0,7);
delete(findall(handles.ax1,'type','line'))
handles.kdesign.Enable    = 'off';
handles.runMRDeagg.Enable = 'off';
handles.ref1.Visible      = 'off';

function Tools_Callback(hObject, eventdata, handles)

function CDM_DisplayOptions_Callback(hObject, eventdata, handles)
if ~isfield(handles,'modelcdm') || isempty(handles.modelcdm)
    return
end
Ntable = size(handles.tableCDM.Data,1);
str    = compose('CDM Model %g',(1:Ntable)');
handles.CDM_Display = Display_Options_CDM(str,handles.CDM_Display);
plot_PSDA_cdm(handles);
guidata(hObject,handles)

function toggle1_Callback(hObject, eventdata, handles)

ch = findall(handles.FIGpsda,'type','legend');
if ~isempty(ch)
    switch ch.Visible
        case 'on',  ch.Visible='off';
        case 'off', ch.Visible='on';
    end
end
guidata(hObject,handles);

function uibuttongroup3_SelectionChangedFcn(hObject, eventdata, handles)

switch hObject.String
    case 'Epistemic Uncertainty through Logic Tree'
        handles.tableREG.Enable      = 'on';
        handles.runREG.Enable = 'on';
        handles.treebutton.Enable = 'on';
        handles.REG_DisplayOptions.Enable = 'on';
        handles.tableCDM.Enable = 'off';
        handles.runCDM.Enable   = 'inactive';
        handles.CDM_DisplayOptions.Enable='inactive';
        plot_PSDA_regular(handles)
        
    case 'Epistemic Uncertainty through Continuos D models'
        handles.tableREG.Enable      = 'off';
        handles.runREG.Enable = 'inactive';
        handles.treebutton.Enable = 'inactive';
        handles.REG_DisplayOptions.Enable = 'inactive';
        handles.tableCDM.Enable = 'on';
        handles.runCDM.Enable   = 'on';
        handles.CDM_DisplayOptions.Enable='on';
        plot_PSDA_cdm(handles)
end

function Examples_Callback(hObject, eventdata, handles)

function Ex1_Callback(hObject, eventdata, handles)
delete(findall(handles.FIGpsda,'type','legend'))
delete(findall(handles.ax1,'type','line')); drawnow
handles.ax1.NextPlot        = 'add';
handles.ax1.ColorOrderIndex = 1;

% -------------------------------------------------------------------------
% loads and plots results from independent calculations
% -------------------------------------------------------------------------
load PSDA2_Validation_Ex1_2 D_vector percentile_10_MC_example percentile_50_MC_example percentile_90_MC_example Disp_MC_samples
plot(handles.ax1,D_vector,percentile_10_MC_example)
plot(handles.ax1,D_vector,percentile_50_MC_example)
plot(handles.ax1,D_vector,percentile_90_MC_example)
plot(handles.ax1,D_vector,mean(Disp_MC_samples,1))

% -------------------------------------------------------------------------
% computes calculations directly in the platform to test psda_BT2007_cdm
% -------------------------------------------------------------------------
load PSDA2_Validation_Ex1_2 Sa_vector Hazard_MC_samples PC_Coefficients_Sum_Hazards

d                   = D_vector;
psda_param.d        = D_vector;
psda_param.realSa   = 100;
psda_param.realD    = 100;
psda_param.method   = 'PC';
psda_param.imhazard = 'full';
Ts_param            = [1.0 0.3 100];
ky_param            = [0.1 0.3 100];
im                  = Sa_vector(:);
CDM                 = Hazard_MC_samples';
Cz                  = PC_Coefficients_Sum_Hazards;
tol                 = 1e-2;
xrnd                = norminv(linspace(tol,1-tol,100)  ,0,1); % mod by GC 15/11/2018
zrnd                = norminv(linspace(tol,1-tol,100) ,0,1); % mod by GC 15/11/2018
hd                  = psda_BT2007_cdm_benchmark(Ts_param, ky_param, psda_param,im,CDM,Cz,xrnd,zrnd,'rectangular');
handles.ax1.ColorOrderIndex=1;
plot(handles.ax1,d,prctile(hd,10),'.')
plot(handles.ax1,d,prctile(hd,50),'.')
plot(handles.ax1,d,prctile(hd,90),'.')
plot(handles.ax1,d,mean(hd,1),'.')

L=legend(...
    '10th Percentile MCS (Benchmark)', ...
    '50th Percentile MCS (Benchmark)', ...
    '90th Percentile MCS (Benchmark)', ...
    'Mean                MCS (Benchmark)', ...
    '10th Percentile MCS (PSDA2)', ...
    '50th Percentile MCS (PSDA2)', ...
    '90th Percentile MCS (PSDA2)',...
    'Mean                MCS (PSDA2)');
L.Location ='SouthWest';
L.Box      ='off';

function Ex2_Callback(hObject, eventdata, handles)

delete(findall(handles.FIGpsda,'type','legend'))
delete(findall(handles.ax1,'type','line')); drawnow
handles.ax1.NextPlot        = 'add';
handles.ax1.ColorOrderIndex = 1;

% loads and plots results from independent calculations
% -------------------------------------------------------------------------
load PSDA2_Validation_Ex1_2 D_vector percentile_10_PC_example ...
    percentile_50_PC_example percentile_90_PC_example PC_term_0_summed_array
plot(handles.ax1,D_vector,percentile_10_PC_example)
plot(handles.ax1,D_vector,percentile_50_PC_example)
plot(handles.ax1,D_vector,percentile_90_PC_example)
plot(handles.ax1,D_vector,PC_term_0_summed_array(:,1)')

% -------------------------------------------------------------------------
% computes calculations directly in the platform to test psda_BT2007_cdm
% -------------------------------------------------------------------------
load PSDA2_Validation_Ex1_2 Sa_vector Hazard_MC_samples PC_Coefficients_Sum_Hazards
d                   = D_vector;
psda_param.d        = D_vector;
psda_param.realSa   = 100;
psda_param.realD    = 100;
psda_param.method   = 'PC';
psda_param.imhazard = 'full';
Ts_param            = [1.0 0.3 100];
ky_param            = [0.1 0.3 100];
im                  = Sa_vector(:);
CDM                 = Hazard_MC_samples';
Cz                  = PC_Coefficients_Sum_Hazards;
tol                 = 1e-2;
xrnd                = norminv(linspace(tol,1-tol,100),0,1); % mod by GC 15/11/2018
zrnd                = norminv(linspace(tol,1-tol,100),0,1); % mod by GC 15/11/2018
hd                  = psda_BT2007_cdm_benchmark(Ts_param, ky_param, psda_param,im, CDM,Cz,xrnd,zrnd,[]);
handles.ax1.ColorOrderIndex=1;
plot(handles.ax1,d,prctile(hd,10),'.')
plot(handles.ax1,d,prctile(hd,50),'.')
plot(handles.ax1,d,prctile(hd,90),'.')
plot(handles.ax1,d,mean(hd,1),'.')
L=legend(...
    '10th Percentile PCE (Benchmark)', ...
    '50th Percentile PCE (Benchmark)', ...
    '90th Percentile PCE (Benchmark)', ...
    'Mean                PCE(Benchmark)', ...
    '10th Percentile PCE (PSDA2)', ...
    '50th Percentile PCE (PSDA2)', ...
    '90th Percentile PCE (PSDA2)',...
    'Mean                PCE(PSDA2)');
L.Location ='SouthWest';
L.Box      ='off';

function Problem1b_MCS_Callback(hObject, eventdata, handles)

delete(findall(handles.FIGpsda,'type','legend'))
delete(findall(handles.ax1,'type','line')); drawnow
handles.ax1.NextPlot        = 'add';
handles.ax1.ColorOrderIndex = 1;

% loads and plots results from independent calculations
% -------------------------------------------------------------------------
load Problem1 x yMCS Sa_vector Hazard_MC_samples xi_hazard xi_samples
plot(handles.ax1,x,yMCS)

% -------------------------------------------------------------------------
% computes calculations directly in the platform to test psda_BT2007_cdm
% -------------------------------------------------------------------------
d                   = logsp(1,100,10);
psda_param.d        = logsp(1,100,10);
psda_param.realSa   = 1000;
psda_param.realD    = 1000;
psda_param.method   = 'MC';
psda_param.imhazard = 'average';
xrnd                = xi_samples;
zrnd                = xi_hazard;
Ts_param            = [1.0 0.3 100];
ky_param            = [0.1 0.3 100];
im                  = Sa_vector(:);
CDM                 = Hazard_MC_samples(1:psda_param.realSa,:)';
Cz                  = [];
hd                  = psda_BT2007_cdm_benchmark(Ts_param, ky_param, psda_param,im, CDM,Cz,xrnd,zrnd,'rectangular');
handles.ax1.ColorOrderIndex=1;
plot(handles.ax1,d,prctile(hd,10),'.')
plot(handles.ax1,d,prctile(hd,50),'.')
plot(handles.ax1,d,prctile(hd,90),'.')
plot(handles.ax1,d,mean(hd,1),'.')
L=legend(...
    '10th Percentile MCS (Benchmark)', ...
    '50th Percentile MCS (Benchmark)', ...
    '90th Percentile MCS (Benchmark)', ...
    'Mean                MCS (Benchmark)', ...
    '10th Percentile MCS (PSDA2)', ...
    '50th Percentile MCS (PSDA2)', ...
    '90th Percentile MCS (PSDA2)',...
    'Mean                MCS (PSDA2)');
L.Location ='SouthWest';
L.Box      ='off';

function Problem1b_PCE_Callback(hObject, eventdata, handles)

delete(findall(handles.FIGpsda,'type','legend'))
delete(findall(handles.ax1,'type','line')); drawnow
handles.ax1.NextPlot        = 'add';
handles.ax1.ColorOrderIndex = 1;

% loads and plots results from independent calculations
% -------------------------------------------------------------------------
load Problem1_updated x yPCE Sa_vector Hazard_MC_samples xi_hazard xi_samples PC_Coefficients_Sum_Hazards
plot(handles.ax1,x,yPCE)

% -------------------------------------------------------------------------
% computes calculations directly in the platform to test psda_BT2007_cdm
% -------------------------------------------------------------------------
d                   = logsp(1,100,10);
psda_param.d        = logsp(1,100,10);
psda_param.realSa   = 200;%1000;
psda_param.realD    = 200;%1000;
psda_param.method   = 'PC';
psda_param.imhazard = 'average';
xrnd                = xi_samples;
zrnd                = xi_hazard;
%%added by JM
tol                 = 1e-2;
xrnd                = norminv(linspace(tol,1-tol,100)  ,0,1); 
zrnd                = norminv(linspace(tol,1-tol,100) ,0,1); 
%%
Ts_param            = [1.0 0.3 100];
ky_param            = [0.1 0.3 100];
im                  = Sa_vector(:);
CDM                 = Hazard_MC_samples(1:psda_param.realSa,:)';
Cz                  = PC_Coefficients_Sum_Hazards;
hd                  = psda_BT2007_cdm_benchmark(Ts_param, ky_param, psda_param,im, CDM,Cz,xrnd,zrnd,[]);
handles.ax1.ColorOrderIndex=1;
plot(handles.ax1,d,prctile(hd,10),'.')
plot(handles.ax1,d,prctile(hd,50),'.')
plot(handles.ax1,d,prctile(hd,90),'.')
plot(handles.ax1,d,mean(hd,1),'.')
L=legend(...
    '10th Percentile PCE (Benchmark)', ...
    '50th Percentile PCE (Benchmark)', ...
    '90th Percentile PCE (Benchmark)', ...
    'Mean                PCE (Benchmark)', ...
    '10th Percentile PCE (PSDA2)', ...
    '50th Percentile PCE (PSDA2)', ...
    '90th Percentile PCE (PSDA2)',...
    'Mean                PCE (PSDA2)');
L.Location ='SouthWest';
L.Box      ='off';

function kdesign_Callback(hObject, eventdata, handles)
if isempty(handles.haz)
    return
end
prompt   = {'Return period (yr):','Allowable displacement Da(cm):'};
dlgtitle = 'k-design';
dims     = [1 50];
definput = {'475','20'};
answer   = inputdlg(prompt,dlgtitle,dims,definput);
if isempty(answer)
    return
end

Tr        = str2double(answer{1});
Da        = str2double(answer{2});
tit       = sprintf('k-design: Tr = %g, Da = %g cm',Tr,Da);
Nbranches = size(handles.IJK,1);
kydata(1:Nbranches,1) = struct('d',[],'lambdaD',[],'ky',[],'error',[],'iter',[]);
leg       = cell(Nbranches,1);
model     = cell(Nbranches,1);
delete(findall(handles.FIGpsda,'type','legend'))
delete(findall(handles.ax1,'type','line'));drawnow
XL = handles.paramPSDA.d([1 end]); plot(handles.ax1,XL,1/Tr*[1 1],'k--','tag','kdesign','handlevisibility','off')
YL = handles.ax1.YLim;   plot(handles.ax1,Da*[1 1],YL,'k--','tag','kdesign','handlevisibility','off')
drawnow
handles.ax1.ColorOrderIndex=1;
home
fprintf('\n')
t0 = tic;
fprintf('                        SEISMIC PSEUDOSTATIC COEFFICIENT (SPC)\n');
fprintf('-----------------------------------------------------------------------------------------------------------\n');
for i = 1:Nbranches
    kydata(i) = runPSDA_singlebranch(handles,Tr,Da,i);
    leg{i}   = sprintf('PSDA %g (k = %.3f)',i,kydata(i).ky);
    model{i} = sprintf('PSDA %g',i);
    fprintf('PSDA branch %-3i ky=%-4.3f ; iter=%-2i ; error=%-3.2g\n',i,kydata(i).ky,kydata(i).iter,abs(kydata(i).error))
end

fprintf('-----------------------------------------------------------------------------------------------------------\n');
fprintf('%-88sTotal:     %-4.3f s\n','',toc(t0));

handles.kydata=kydata;
plot(handles.ax1,kydata(1).d,vertcat(kydata.lambdaD))

switch handles.toggle1.Value
    case 0, legend(handles.ax1,leg,'Box','off','Visible','off')
    case 1, legend(handles.ax1,leg,'Box','off','Visible','on')
end

axis(handles.ax1,'auto')
cF   = get(0,'format');
format long g
data = num2cell([kydata(1).d;vertcat(kydata.lambdaD)]');
c    = uicontextmenu;

uimenu(c,'Label','Summary Table'     ,'Callback',{@data2table_uimenu,model,vertcat(kydata.ky)});
uimenu(c,'Label','Create Histogram'  ,'Callback',{@data2hist_uimenu,vertcat(kydata.ky)});
uimenu(c,'Label','Copy data'         ,'Callback',{@data2clipboard_uimenu,data});
uimenu(c,'Label','Undock'            ,'Callback',{@figure2clipboard_uimenu,handles.ax1,tit});
set(handles.ax1,'uicontextmenu',c);
format(cF);

function data2table_uimenu(~, ~,model,k)

disp(table(model,k));

function data2hist_uimenu(~,~,k)
figure
N = length(k);
histogram(k,min(N,20));
xlabel('SPC')
ylabel('Freequency')

function runMRDeagg_Callback(hObject, eventdata, handles)
T1    = handles.T1;
T2    = handles.T2;
T3    = handles.T3;
dlist = handles.dlist;
param = handles.paramPSDA;
DispDeaggMR(handles.sys,handles.model,handles.opt,handles.h,T1,T2,T3,param,dlist)

function undock_Callback(hObject, eventdata, handles)

figure2clipboard_uimenu(hObject, eventdata,handles.ax1)

function ColorSecondaryLines_Callback(hObject, eventdata, handles)

if handles.mode1.Value, plot_PSDA_regular(handles);end
if handles.mode2.Value, plot_PSDA_cdm(handles);end

function ref1_Callback(hObject, eventdata, handles)

winopen(handles.pdffile)
