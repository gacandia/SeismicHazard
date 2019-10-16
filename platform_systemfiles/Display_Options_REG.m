function varargout = Display_Options_REG(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Display_Options_REG_OpeningFcn, ...
    'gui_OutputFcn',  @Display_Options_REG_OutputFcn, ...
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

function Display_Options_REG_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

handles.LCH = [handles.L1;...
       handles.L2;...
       handles.L3;...
       handles.L4;...
       handles.L5;...
       handles.L6;...
       handles.L7];

handles.RCH = [handles.R1;...
       handles.R2;...
       handles.R3];
   
   
if nargin==5
    handles.R1.String=varargin{1};
    haz = varargin{2};
    
    switch haz.L0
        case 1
            set(handles.LCH,'Enable','on')
            set(handles.RCH,'Enable','off')
        case 0
            set(handles.LCH,'Enable','off')
            set(handles.RCH,'Enable','on')
    end
    
    handles.L0.Value=haz.L0;
    handles.L1.Value=haz.L1;
    handles.L2.Value=haz.L2;
    handles.L3.Value=haz.L3;
    handles.L4.Value=haz.L4;
    handles.L5.String=compose('%g',haz.L5);
    handles.L6.Value=haz.L6;
    handles.L7.Value=haz.L7;
    
    handles.R0.Value=haz.R0;
    handles.R1.Value=haz.R1;
    handles.R2.Value=haz.R2;
    handles.R3.Value=haz.R3;

end

switch handles.L0.Value
    case 0
        set(handles.LCH,'Enable','off')
        set(handles.RCH,'Enable','on')
    case 1
        set(handles.LCH,'Enable','on')
        set(handles.RCH,'Enable','off')
end

guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = Display_Options_REG_OutputFcn(hObject, eventdata, handles)

haz.L0=handles.L0.Value;
haz.L1=handles.L1.Value;
haz.L2=handles.L2.Value;
haz.L3=handles.L3.Value;
haz.L4=handles.L4.Value;
haz.L5=str2double(handles.L5.String);
haz.L6=handles.L6.Value;
haz.L7=handles.L7.Value;

haz.R0=handles.R0.Value;
haz.R1=handles.R1.Value;
haz.R2=handles.R2.Value;
haz.R3=handles.R3.Value;


Nbranches = length(handles.R1.String);
rnd = rand(Nbranches,1); rnd = rnd/sum(rnd);
haz.rnd = rnd;
varargout{1} = haz;
delete(handles.figure1)

function L1_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function L2_Callback(hObject, eventdata, handles)

function L4_Callback(hObject, eventdata, handles)

function L5_Callback(hObject, eventdata, handles)

val = str2double(hObject.String);
val = min(max(val,0),100);
hObject.String=compose('%g',val);
guidata(hObject,handles)

function pan1_5_Callback(hObject, eventdata, handles)

function R2_Callback(hObject, eventdata, handles)

function R3_Callback(hObject, eventdata, handles)

function L0_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 0
        handles.R0.Value=1;
        set(handles.LCH,'Enable','off')
        set(handles.RCH,'Enable','on')
    case 1
        handles.R0.Value=0;
        set(handles.LCH,'Enable','on')
        set(handles.RCH,'Enable','off')
end

guidata(hObject,handles)

function R0_Callback(hObject, eventdata, handles)
switch hObject.Value
    case 0
        handles.L0.Value=1;
        set(handles.LCH,'Enable','on')
        set(handles.RCH,'Enable','off')
    case 1
        handles.L0.Value=0;
        set(handles.LCH,'Enable','off')
        set(handles.RCH,'Enable','on')       
end

guidata(hObject,handles)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function L3_Callback(hObject, eventdata, handles)

function pan1_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Pannel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pannel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in pan1.
function pan1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in pan1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
