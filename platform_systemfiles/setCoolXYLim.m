function varargout = setCoolXYLim(varargin)
% SETCOOLXYLIM MATLAB code for setCoolXYLim.fig
%      SETCOOLXYLIM, by itself, creates a new SETCOOLXYLIM or raises the existing
%      singleton*.
%
%      H = SETCOOLXYLIM returns the handle to a new SETCOOLXYLIM or the handle to
%      the existing singleton*.
%
%      SETCOOLXYLIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETCOOLXYLIM.M with the given input arguments.
%
%      SETCOOLXYLIM('Property','Value',...) creates a new SETCOOLXYLIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setCoolXYLim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setCoolXYLim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setCoolXYLim

% Last Modified by GUIDE v2.5 25-Aug-2017 12:00:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setCoolXYLim_OpeningFcn, ...
                   'gui_OutputFcn',  @setCoolXYLim_OutputFcn, ...
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

function setCoolXYLim_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setCoolXYLim (see VARARGIN)

% Choose default command line output for setCoolXYLim
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

handles.cancel = 0;
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = setCoolXYLim_OutputFcn(hObject, eventdata, handles)  %#ok<*STOUT>

if handles.cancel==0
varargout{1}=handles.checkbox1.Value;
varargout{2}=str2double(regexp(handles.XLIM.String,'\s+','split'));
varargout{3}=str2double(regexp(handles.YLIM.String,'\s+','split'));
else
varargout{1}=handles.value0;
varargout{2}=handles.XLIM0;
varargout{3}=handles.YLIM0;
end
delete(handles.figure1)



function OKbutton_Callback(hObject, eventdata, handles) 
close(handles.figure1);

function cancelButton_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
handles.cancel=1;
guidata(hObject,handles);
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
