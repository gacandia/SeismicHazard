function varargout = DmodelExplorer(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DmodelExplorer_OpeningFcn, ...
                   'gui_OutputFcn',  @DmodelExplorer_OutputFcn, ...
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

function DmodelExplorer_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
load All_Scenario_Buttons DiscretizeMButtonbutton
handles.DiscretizeMButtonbutton.CData = DiscretizeMButtonbutton;
handles.undock1.CData = double(imread('Undock.jpg'))/255;
handles.undock2.CData = double(imread('Undock.jpg'))/255;
handles.pushbutton1.CData = double(imread('book_open.jpg'))/255;

ch  = get(handles.panel2,'children'); tag  = char(ch.Tag);
handles.text = flipud(find(ismember(tag(:,1),'t')));
handles.edit = flipud(find(ismember(tag(:,1),'e')));
set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off','Style','edit');
meth=pshatoolbox_methods(5);
meth=meth(vertcat(meth.isregular));
handles.Dpop.String ={meth.label};
handles.Dpop.Value  =1;

handles = dDISPdefault(handles,ch(handles.text),ch(handles.edit));
handles.xlabel1=ylabel(handles.ax1,'d (cm)');
handles.xlabel2=xlabel(handles.ax2,'d (cm)');
handles.ylabel2=ylabel(handles.ax2,'P(D > d)');
handles.plotmodeax2='ccdf';

if nargin==6
    ky_param = varargin{1};
    Ts_param = varargin{2};
    handles.SMLIB         = varargin{3};
    isREGULAR=vertcat(handles.SMLIB.isregular);
    if any(isREGULAR)
        handles.SMLIB         = handles.SMLIB(isREGULAR);
        handles.ky.String     = sprintf('%g',ky_param(1));
        handles.covky .String = sprintf('%g',ky_param(2));
        handles.Ts.String     = sprintf('%g',Ts_param(1));
        handles.covTs .String = sprintf('%g',Ts_param(2));
        handles.listbox1.Visible = 'on';
        handles.smlibtxt.Visible = 'on';
        handles.listbox1.String = {handles.SMLIB.id};
        handles.listbox1.Value  = 1;
        handles = ffSMLIB(handles);
    end
end
plotDmodel(handles)
guidata(hObject, handles);
% uiwait(handles.figure1);

function varargout = DmodelExplorer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function handles = ffSMLIB(handles)
val = handles.listbox1.Value;
str = handles.SMLIB(val).str;
meth = pshatoolbox_methods(5);
[~,B]=intersect({meth.str},str);
handles.Dpop.Value=B;
ch=get(handles.panel2,'children');
set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off','Style','edit');
handles = dDISPdefault(handles,ch(handles.text),ch(handles.edit));

function Dpop_Callback(hObject, eventdata, handles) 

ch=get(handles.panel2,'children');
set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off','Style','edit');
handles = dDISPdefault(handles,ch(handles.text),ch(handles.edit));
plotDmodel(handles)
guidata(hObject,handles)

function pushbutton1_Callback(hObject, eventdata, handles) 
val     = handles.Dpop.Value;
methods = pshatoolbox_methods(5,val);
if ~isempty(methods.ref)
    try
        web(methods.ref,'-browser')
    catch
    end
end

function DiscretizeMButtonbutton_Callback(hObject, eventdata, handles)
switch handles.plotmodeax2
    case 'pdf'  , handles.plotmodeax2='cdf';
    case 'cdf'  , handles.plotmodeax2='ccdf';
    case 'ccdf' , handles.plotmodeax2='pdf';
end
plotDmodel(handles)
guidata(hObject,handles)

function e1_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
plotDmodel(handles)
function e2_Callback(hObject, eventdata, handles)
plotDmodel(handles)
function e3_Callback(hObject, eventdata, handles)
plotDmodel(handles)
function ky_Callback(hObject, eventdata, handles)
plotDmodel(handles)
function covky_Callback(hObject, eventdata, handles)
plotDmodel(handles)
function Ts_Callback(hObject, eventdata, handles)
plotDmodel(handles)
function covTs_Callback(hObject, eventdata, handles)
plotDmodel(handles)
function undock1_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax1)
function undock2_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax2)

function listbox1_Callback(hObject, eventdata, handles)
handles = ffSMLIB(handles);
plotDmodel(handles)
guidata(hObject,handles)
