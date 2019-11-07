function varargout = scenWizard(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @scenWizard_OpeningFcn, ...
    'gui_OutputFcn',  @scenWizard_OutputFcn, ...
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

function scenWizard_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
handles.model  = varargin{1};
handles.t.Data = cell(0,4);
handles.pushbutton1.CData = double(imread('form1.jpg'))/255;
handles.modelpop.String   = {handles.model.id};
handles.sourcelist.String = {handles.model(1).source.label};

datasource = handles.model(1).source(1).datasource;
if ~isempty(datasource) && contains (datasource,'.mat')
    handles.t.ColumnName{4}='Used Mesh(%)';
end

guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = scenWizard_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.t.Data;
delete(hObject);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function sourcelist_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function modelpop_Callback(hObject, eventdata, handles)

val = hObject.Value;
handles.sourcelist.Value=1;
handles.sourcelist.String = {handles.model(val).source.label};

function pushbutton1_Callback(hObject, eventdata, handles)

model_ptr   = handles.modelpop.Value;
source_ptr  = handles.sourcelist.Value;
Nsources    = length(source_ptr);
model       = handles.model(model_ptr);

col1     = cell(Nsources,1);
col2     = {model.source(source_ptr).label}';
col3     = cell(Nsources,1);
col4     = cell(Nsources,1);
for i=1:Nsources
    j     = source_ptr(i);
    col1{i}=num2str(model_ptr);
    col3{i}=length(model.source(j).mscl.M);
    col4{i}=50; % default
end
handles.t.Data=[col1,col2,col3,col4];
guidata(hObject,handles);
