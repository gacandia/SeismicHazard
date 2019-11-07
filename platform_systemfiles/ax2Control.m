function varargout = ax2Control(varargin)
% AX2CONTROL MATLAB code for ax2Control.fig
%      AX2CONTROL, by itself, creates a new AX2CONTROL or raises the existing
%      singleton*.
%
%      H = AX2CONTROL returns the handle to a new AX2CONTROL or the handle to
%      the existing singleton*.
%
%      AX2CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AX2CONTROL.M with the given input arguments.
%
%      AX2CONTROL('Property','Value',...) creates a new AX2CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ax2Control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ax2Control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ax2Control

% Last Modified by GUIDE v2.5 12-Dec-2018 17:11:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ax2Control_OpeningFcn, ...
                   'gui_OutputFcn',  @ax2Control_OutputFcn, ...
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

function ax2Control_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ax2Control (see VARARGIN)

% Choose default command line output for ax2Control
handles.output = hObject;

ax=varargin{1};

handles.value0 = ax.XLimMode;
handles.XLIM0  = ax.XLim;
handles.YLIM0  = ax.YLim;
handles.figure1.Name = '';
switch ax.XLimMode
    case 'auto'
        handles.checkbox1.Value=1;
        handles.text1.Enable='off';
        handles.text2.Enable='off';
        handles.XLIM.Enable='off';
        handles.YLIM.Enable='off';
    otherwise
        handles.checkbox1.Value=0;
        handles.text1.Enable='on';
        handles.text2.Enable='on';
        handles.XLIM.Enable='on';
        handles.YLIM.Enable='on';
end

handles.XLIM.String=sprintf('%g  %g',ax.XLim(1),ax.XLim(2));
handles.YLIM.String=sprintf('%g  %g',ax.YLim(1),ax.YLim(2));


% axis scale
XSCALE = ax.XScale;
YSCALE = ax.YScale;
switch [XSCALE,YSCALE]
    case 'loglog',       handles.radiobutton1.Value=1;
    case 'loglinear',    handles.radiobutton2.Value=1;
    case 'linearlog',    handles.radiobutton3.Value=1;
    case 'linearlinear', handles.radiobutton4.Value=1;
end

% grids
XMAYOR = ax.XGrid;
switch XMAYOR
    case 'on',   handles.radiobutton9.Value=1;
    case 'off',  handles.radiobutton10.Value=1;
end

XMINOR = ax.XMinorGrid;
switch XMINOR
    case 'on',   handles.radiobutton13.Value=1;
    case 'off',  handles.radiobutton14.Value=1;
end

handles.cancel = 0;
handles.ax = ax;
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = ax2Control_OutputFcn(hObject, eventdata, handles)  %#ok<*STOUT>

if handles.checkbox1.Value==0
    handles.ax.XLim=str2double(regexp(handles.XLIM.String,'\s+','split'));
    handles.ax.YLim=str2double(regexp(handles.YLIM.String,'\s+','split'));
else
    handles.ax.XLimMode='auto';
    handles.ax.YLimMode='auto';
end

if handles.radiobutton1.Value==1, handles.ax.XScale='log';handles.ax.YScale='log';end
if handles.radiobutton2.Value==1, handles.ax.XScale='log';handles.ax.YScale='linear';end
if handles.radiobutton3.Value==1, handles.ax.XScale='linear';handles.ax.YScale='log';end
if handles.radiobutton4.Value==1, handles.ax.XScale='linear';handles.ax.YScale='linear';end

if handles.radiobutton9.Value ==1, handles.ax.XGrid='on';handles.ax.YGrid='on';end
if handles.radiobutton10.Value==1, handles.ax.XGrid='off';handles.ax.YGrid='off';end

if handles.radiobutton13.Value==1, handles.ax.XMinorGrid='on';handles.ax.YMinorGrid='on';end
if handles.radiobutton14.Value==1, handles.ax.XMinorGrid='off';handles.ax.YMinorGrid='off';end

varargout{1} = handles.ax;
delete(handles.figure1)

function OKbutton_Callback(hObject, eventdata, handles)  %#ok<*DEFNU>
close(handles.figure1);

function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<*INUSD>
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function YLIM_Callback(hObject, eventdata, handles)

function YLIM_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkbox1_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 1
        handles.text1.Enable='off';
        handles.text2.Enable='off';
        handles.XLIM.Enable='off';
        handles.YLIM.Enable='off';
    case 0
        handles.text1.Enable='on';
        handles.text2.Enable='on';
        handles.XLIM.Enable='on';
        handles.YLIM.Enable='on';        
end

function radiobutton1_Callback(hObject, eventdata, handles)

function radiobutton2_Callback(hObject, eventdata, handles)

function radiobutton3_Callback(hObject, eventdata, handles)

function radiobutton4_Callback(hObject, eventdata, handles)

function radiobutton13_Callback(hObject, eventdata, handles)

function radiobutton14_Callback(hObject, eventdata, handles)

function radiobutton9_Callback(hObject, eventdata, handles)

function radiobutton10_Callback(hObject, eventdata, handles)
