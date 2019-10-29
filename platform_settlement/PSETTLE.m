function varargout = PSETTLE(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PSETTLE_OpeningFcn, ...
    'gui_OutputFcn',  @PSETTLE_OutputFcn, ...
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

function PSETTLE_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

load psdabuttons c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11
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
xlabel(handles.ax1,'Settlement (mm)','fontsize',10)
ylabel(handles.ax1,'Mean Rate of Exceedance','fontsize',10)

%% Retrieve data from SeismicHazard
if nargin==7 % called from SeismicHazard Toolbox
    handles = mat2psda(handles,varargin{:});
end
[handles.REG_Display,handles.CDM_Display]   = defaultPSDA_plotoptions;
handles.haz   = [];
handles.haz2  = [];

guidata(hObject, handles);
% uiwait(handles.FIGpsda);

function varargout = PSETTLE_OutputFcn(hObject, eventdata, handles)
varargout{1} = [];

% ----------------  FILE MENU ---------------------------------------------
function File_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function ImportSeismicHazard_Callback(hObject, eventdata, handles)

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

function Exit_Callback(hObject, eventdata, handles)
close(handles.FIGpsda)

function FIGpsda_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

% ----------------  EDIT MENU ---------------------------------------------
function Edit_Callback(hObject, eventdata, handles)

function SModelExplorer_Callback(hObject, eventdata, handles)
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
    handles.haz = haz_PSDA(handles);
    handles     = runPSDA_regular(handles);
    handles.deleteButton.CData  = handles.CDataClosed;
    plot_PSDA_regular(handles)
end
handles.kdesign.Enable='on';
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

[handles.T1,handles.T2,handles.T3,handles.Ts_param,handles.ky_param]=PSDA_Logic_tree2(...
    handles.model,...
    handles.sys,...
    handles.Ts_param,...
    handles.ky_param,...
    handles.T1,...
    handles.T2,...
    handles.T3);

[handles.tableREG.Data,handles.IJK]=main_psda(handles.T1,handles.T2,handles.T3);

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

function Tools_Callback(hObject, eventdata, handles)

function toggle1_Callback(hObject, eventdata, handles)

ch = findall(handles.FIGpsda,'type','legend');
if ~isempty(ch)
    switch ch.Visible
        case 'on',  ch.Visible='off';
        case 'off', ch.Visible='on';
    end
end
guidata(hObject,handles);

function OpenDrivingFile_Callback(hObject, eventdata, handles)

if ispc
    winopen(handles.sys.filename)
end

function undock_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax1)
