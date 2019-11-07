function varargout = Display_Options_CDM(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Display_Options_CDM_OpeningFcn, ...
    'gui_OutputFcn',  @Display_Options_CDM_OutputFcn, ...
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

function Display_Options_CDM_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

handles.LCH = [handles.L1;...
       handles.L2;...
       handles.L3;...
       handles.L4;...
       handles.L5];

handles.RCH = [
       handles.R1;...
       handles.R2];
   
   
if nargin==5
    handles.mptr.String=varargin{1};
    haz = varargin{2};
    
    switch haz.L0
        case 1
            set(handles.LCH,'Enable','on')
            set(handles.RCH,'Enable','off')
        case 0
            set(handles.LCH,'Enable','off')
            set(handles.RCH,'Enable','on')
    end

    handles.mptr.Value = haz.mptr;
    handles.L0.Value=haz.L0;
    handles.L1.Value=haz.L1;
    handles.L2.Value=haz.L2;
    handles.L3.String=compose('%g',haz.L3);
    handles.L4.Value=haz.L4;
    handles.L5.Value=haz.L5;
    
    handles.R0.Value=haz.R0;
    handles.R1.Value=haz.R1;
    handles.R2.Value=haz.R2;

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

function varargout = Display_Options_CDM_OutputFcn(hObject, eventdata, handles)


haz.mptr=handles.mptr.Value;
haz.L0=handles.L0.Value;
haz.L1=handles.L1.Value;
haz.L2=handles.L2.Value;
haz.L3=str2double(handles.L3.String);
haz.L4=handles.L4.Value;
haz.L5=handles.L5.Value;

haz.R0=handles.R0.Value;
haz.R1=handles.R1.Value;
haz.R2=handles.R2.Value;

Nbranches = length(handles.mptr.String);
rnd = rand(Nbranches,1); rnd = rnd/sum(rnd);
haz.rnd = rnd;
varargout{1} = haz;
delete(handles.figure1)

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

function L1_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function L2_Callback(hObject, eventdata, handles)

function L3_Callback(hObject, eventdata, handles)

function L4_Callback(hObject, eventdata, handles)

function L5_Callback(hObject, eventdata, handles)

val = str2double(hObject.String);
val = min(max(val,0),100);
hObject.String=compose('%g',val);
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

function R1_Callback(hObject, eventdata, handles)

function R2_Callback(hObject, eventdata, handles)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);
