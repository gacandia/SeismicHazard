function varargout = OptionsElevation(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OptionsElevation_OpeningFcn, ...
                   'gui_OutputFcn',  @OptionsElevation_OutputFcn, ...
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

function OptionsElevation_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;

val = varargin{1};
ch1=findall(handles.uibuttongroup1,'tag','radiobutton1');
ch2=findall(handles.uibuttongroup1,'tag','radiobutton2');

switch val
    case 1,set(ch1,'value',1);set(ch2,'value',0);
    case 2,set(ch1,'value',0);set(ch2,'value',1);
end
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = OptionsElevation_OutputFcn(hObject, eventdata, handles) 

ch(1)=findall(handles.uibuttongroup1,'tag','radiobutton1');
ch(2)=findall(handles.uibuttongroup1,'tag','radiobutton2');
varargout{1} = find(cell2mat(get(ch,'value')));
delete(handles.figure1)

function pushbutton1_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
close(handles.figure1)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);
