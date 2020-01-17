function varargout = CMS(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CMS_OpeningFcn, ...
    'gui_OutputFcn',  @CMS_OutputFcn, ...
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

function CMS_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

handles.Run.CData=double(imread('Play.jpg'))/255;
handles.axLimits.CData=double(imread('Limits.jpg'))/255;

handles.output      = hObject;
handles.sys         = varargin{1};
handles.opt         = varargin{2};
handles.h           = varargin{3};
handles.scenarios   = cell(0,9);
handles.tessel      = {[],zeros(0,2)};
handles.opt.MagDiscrete = {'uniform' 0.1};
handles.model      = process_model(handles.sys,handles.opt);
handles.isREGULAR  = find(horzcat(handles.model.isregular)==1);
handles.isPCE      = find(horzcat(handles.model.isregular)==0);

% ------------ REMOVES PCE MODELS (AT LEAST FOR NOW) ----------------------
isREGULAR = handles.isREGULAR;
handles.model = handles.model(isREGULAR);
[~,B]=setdiff(handles.sys.BRANCH(:,2),isREGULAR);
if ~isempty(B)
    handles.sys.BRANCH(B,:)=[];
    handles.sys.WEIGHT(B,:)=[];
    handles.sys.WEIGHT(:,4)=handles.sys.WEIGHT(:,4)/sum(handles.sys.WEIGHT(:,4));
    warndlg('PCE Models removed from logic tree. Weights were normalized')
    uiwait
end
% -------------------------------------------------------------------------

% Build interface to adjust this piece of code
%--------------------------------------------------------------------------
rmin  = 0;  rmax  = 600; dr    = 60;
handles.Rbin      = [(rmin:dr:rmax-dr)',(rmin:dr:rmax-dr)'+dr];
mmin  = 5; mmax  = 9; dm    = 0.2;
handles.Mbin      = [(mmin:dm:mmax-dm)',(mmin:dm:mmax-dm)'+dm];

%% populate pop menus
set(handles.pop_site,'string',handles.h.id);
set(handles.pop_branch,'string',{handles.model.id});
T = UHSperiods(handles);
methods = pshatoolbox_methods(4);
handles.spatial_model.String={methods.label};
handles.spatial_model.Value = 3;

if length(handles.model)==1
    handles.methodpop.String={'Method 1'};
else
    handles.methodpop.String={'Method 1','Method 2','Method 3','Method 4'};
end

%% Set up ax1
xlabel(handles.ax1,'Sa(T*)','fontsize',8)
ylabel(handles.ax1,'\lambda Sa(T*)','fontsize',8)

%% Set up ax2
xlabel(handles.ax2,'T (s)','fontsize',8)
ylabel(handles.ax2,'Sa (g)','fontsize',8)

%% set up ax3
set(handles.ax3,'fontsize',8,'visible','off')

%% Set up ax4
plot(handles.ax4,T,nan(size(T)),'.-','tag','rho');
handles.ax4.YLim=[0 1];
xlabel(handles.ax4,'T (s)','fontsize',8)
ylabel(handles.ax4,'\rho (T*,T)','fontsize',8)

%% tooltip strings for CMS
handles.tts{1}='Approximate CS Using Mean M & R and a single GMPM';
handles.tts{2}='Approximate CS Using Mean M & R and GMPMs with Logic-Tree Weights';
handles.tts{3}='Approximate CS Using GMPM-Specific Mean M & R and GMPMs with Deaggregation Weights';
handles.tts{4}='“Exact” CS Using Multiple Causal Earthquake M & R and GMPMs with Deaggregation Weights';
handles.methodpop.TooltipString=handles.tts{1};

guidata(hObject, handles);
% uiwait(handles.figure1);

function varargout = CMS_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function Ret_Period_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

str = hObject.String;
if contains(str,'%')
    str = strrep(str,'year','y');
    str = strrep(str,'yr','y');
    str = strrep(str,'in','');
    str = regexp(str,'\%|\y|\yr','split');
    p   = str2double(str{1});
    t   = str2double(str{2});
    Ret = round(-t/log(1-p/100));
    hObject.String = sprintf('%i',Ret);
end

function Cond_Period_Callback(hObject, eventdata, handles)

function Run_Callback(hObject, eventdata, handles)

switch handles.methodpop.Value
    case 1, runCMS_method1(handles);
    case 2, runCMS_method2(handles);
    case 3, runCMS_method3(handles);
end

function pop_site_Callback(hObject, eventdata, handles)

function pop_branch_Callback(hObject, eventdata, handles)

function control_R_Callback(hObject, eventdata, handles)

function control_M_Callback(hObject, eventdata, handles)

function spatial_model_Callback(hObject, eventdata, handles)

function overRM_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 0
        handles.control_R.BackgroundColor=[1 1 1];
        handles.control_M.BackgroundColor=[1 1 1];
        handles.control_R.Enable='inactive';
        handles.control_M.Enable='inactive';
        
    case 1
        handles.control_R.BackgroundColor=[1 1 178/255];
        handles.control_M.BackgroundColor=[1 1 178/255];
        handles.control_R.Enable='on';
        handles.control_M.Enable='on';
end
guidata(hObject,handles)

function axLimits_Callback(hObject, eventdata, handles)

list = {'Hazard Curve','Conditional Mean Spectra','Correlation Model'};
[indx,tf] = listdlg('ListString',list,'SelectionMode','single','ListSize',[160 100]);
if tf==0
    return
end
switch indx
    case 1, handles.ax1=ax2Control(handles.ax1);
    case 2, handles.ax2=ax2Control(handles.ax2);
    case 3, handles.ax4=ax2Control(handles.ax4);
end
guidata(hObject,handles)

function methodpop_Callback(hObject, eventdata, handles)

hObject.TooltipString=handles.tts{hObject.Value};
if hObject.Value~=1
    handles.pop_branch.Enable='off';
else
    handles.pop_branch.Enable='on';
end
guidata(hObject,handles)

function Edit_Callback(hObject, eventdata, handles)

function defineMRbins_Callback(hObject, eventdata, handles)

[handles.Rbin,handles.Mbin]=setMRebins(handles.Rbin,handles.Mbin);
guidata(hObject,handles)
