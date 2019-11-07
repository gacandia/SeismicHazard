function varargout = Vs30Source(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Vs30Source_OpeningFcn, ...
    'gui_OutputFcn',  @Vs30Source_OutputFcn, ...
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

function Vs30Source_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

handles.up.CData      = double(imread('up.jpg'))/255;
handles.down.CData    = double(imread('down.jpg'))/255;
handles.delete.CData  = double(imread('selection_delete.jpg'))/255;

if nargin==4
    iout = varargin{1};
    handles.baseline.String = num2str(iout.baseline);
    handles.listbox1.String = iout.source;
end

guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = Vs30Source_OutputFcn(hObject, eventdata, handles)

out.baseline = str2double(handles.baseline.String);
out.source   = handles.listbox1.String;
if ~iscell(out.source) && strcmp(out.source,' ')
    out.source = {' '};
end
varargout{1} = out;
delete(handles.figure1)

function baseline_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>

function listbox1_Callback(hObject, eventdata, handles)

function listbox1_ButtonDownFcn(hObject, eventdata, handles)

[filename,pathname,FILTERINDEX]=uigetfile({'*.kml;*.mat','Source (*.kml,*.mat)'},'Select a File','MultiSelect','on');

if FILTERINDEX==0
    return
end
if ischar(filename)
   filename = {filename}; 
end

if strcmp(handles.listbox1.String,' ')
    handles.listbox1.String = cell(1,length(filename));
    for i=1:length(filename)
        handles.listbox1.String{i}=fullfile(pathname,filename{i});
    end
else
    newString = cell(1,length(filename));
    for i=1:length(filename)
        newString{i}=fullfile(pathname,filename{i});
    end
    handles.listbox1.String=[handles.listbox1.String;newString];
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function up_Callback(hObject, eventdata, handles)

move = handles.listbox1.Value;
str  = handles.listbox1.String;
list = 1:length(str);
if move>1
    list(move)=move-1;
    list(move-1)=move;
    handles.listbox1.String=str(list);
end
guidata(hObject,handles)

function down_Callback(hObject, eventdata, handles)
move = handles.listbox1.Value;
str  = handles.listbox1.String;
list = 1:length(str);
if move<length(str)
    list(move)=move+1;
    list(move+1)=move;
    handles.listbox1.String=str(list);
end
guidata(hObject,handles)

function delete_Callback(hObject, eventdata, handles)

del  = handles.listbox1.Value;
str  = handles.listbox1.String;
list = 1:length(str);
list(del)=[];
handles.listbox1.Value=1;
handles.listbox1.String=str(list);

if isempty(str(list))
    handles.listbox1.String=' ';
    handles.listbox1.Value=1;
end
guidata(hObject,handles)
