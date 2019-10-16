function varargout = ColorManager(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ColorManager_OpeningFcn, ...
                   'gui_OutputFcn',  @ColorManager_OutputFcn, ...
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

function ColorManager_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

if nargin==4
    col        = varargin{1};
    handles.push1.BackgroundColor= col{1};
    handles.edit1.String = sprintf('%g',col{2});
    handles.radiobutton3.Value = col{3};
    handles.radiobutton4.Value = 1-col{3};
    handles.push2.BackgroundColor= col{4};
    
    [~,handles.pop1.Value]=intersect(handles.pop1.String,col{5});
    handles.edit2.String = sprintf('%g',col{6});
else
    handles.push1.BackgroundColor = [0  0.447 0.741];
    handles.edit1.String          = '2';
    handles.radiobutton3.Value    = 1;
    handles.radiobutton4.Value    = 0;
    handles.push2.BackgroundColor = [0.76 0.76 0.76];
    handles.pop1.Value            = 1;
    handles.edit2.String          = '0.5';
end

guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = ColorManager_OutputFcn(hObject, eventdata, handles) 
c1 = handles.push1.BackgroundColor;
w1 = str2double(handles.edit1.String);

c2type = handles.radiobutton3.Value;
c21    = handles.push2.BackgroundColor;
c22    = handles.pop1.String{handles.pop1.Value};
w2     = str2double(handles.edit2.String);
varargout{1} = {c1,w1,c2type,c21,c22,w2};
delete(handles.figure1)

% --- Executes on button press in push1.
function push1_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
handles.push1.BackgroundColor= uisetcolor(handles.push1.BackgroundColor);
guidata(hObject,handles)

function push2_Callback(hObject, eventdata, handles)
handles.push2.BackgroundColor= uisetcolor(handles.push2.BackgroundColor);
guidata(hObject,handles)


function pop1_Callback(hObject, eventdata, handles)

function edit1_Callback(hObject, eventdata, handles)

function edit2_Callback(hObject, eventdata, handles)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function radiobutton3_Callback(hObject, eventdata, handles)
