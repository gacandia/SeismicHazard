function varargout = PSDA2Parameters(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PSDA2Parameters_OpeningFcn, ...
    'gui_OutputFcn',  @PSDA2Parameters_OutputFcn, ...
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

function PSDA2Parameters_OpeningFcn(hObject, eventdata, handles, varargin)

if nargin==4
    iparam = varargin{1};
    handles.Nd.String     = sprintf('%i',(length(iparam.d)));
    handles.dmin.String   = sprintf('%g',iparam.d(1));
    handles.dmax.String   = sprintf('%g',iparam.d(end));
    handles.realSa.String = sprintf('%g',iparam.realSa);
    handles.realD.String  = sprintf('%g',iparam.realD);
    handles.butt1.Value   = strcmp(iparam.optimize ,'on');
    handles.butt2.Value   = strcmp(iparam.optimize ,'off');
    handles.butt3.Value   = strcmp(iparam.imhazard ,'full');
    handles.butt4.Value   = strcmp(iparam.imhazard ,'average');
    handles.butt5.Value   = strcmp(iparam.method   ,'PC');
    handles.butt6.Value   = strcmp(iparam.method   ,'MC');
    handles.butt7.Value   = strcmp(iparam.rng      ,'shuffle');
    handles.butt8.Value   = strcmp(iparam.rng      ,'default');    
end

guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = PSDA2Parameters_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>

Nd   = str2double(handles.Nd.String);
dmin = str2double(handles.dmin.String);
dmax = str2double(handles.dmax.String);
outparam.d      = logsp(dmin,dmax,Nd);
outparam.realSa = str2double(handles.realSa.String);
outparam.realD  = str2double(handles.realD.String);

switch handles.butt1.Value
    case 1, outparam.optimize = 'on';
    case 0, outparam.optimize = 'off';
end

switch handles.butt3.Value
    case 1, outparam.imhazard = 'full';
    case 0, outparam.imhazard = 'average';
end

switch handles.butt5.Value
    case 1, outparam.method = 'PC';
    case 0, outparam.method = 'MC';
end

switch handles.butt7.Value
    case 1, outparam.rng = 'shuffle';
    case 0, outparam.rng = 'default';
end

varargout{1}=outparam;
delete(handles.figure1)

function realSa_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function realD_Callback(hObject, eventdata, handles)

function Nd_Callback(hObject, eventdata, handles)

function dmin_Callback(hObject, eventdata, handles)

function dmax_Callback(hObject, eventdata, handles)

function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);
