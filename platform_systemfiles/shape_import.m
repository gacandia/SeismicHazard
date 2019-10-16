function varargout = shape_import(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @shape_import_OpeningFcn, ...
    'gui_OutputFcn',  @shape_import_OutputFcn, ...
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

function shape_import_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output   = hObject;
handles.exittype = true;
handles.filename = varargin{2};
handles.bbox1    = varargin{3};
handles.bbox2    = varargin{4};
handles.info     = shapeinfo(handles.filename);
handles.listbox1.String={handles.info.Attributes.Name};
handles.listbox1.Value=1;

switch handles.info.ShapeType
    case 'Point'
    case 'PolyLine'
        handles.listbox1.Enable='off';
end

% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = shape_import_OutputFcn(hObject, eventdata, handles)
p = cell(0,4);
if handles.exittype
    out_mode = [handles.info.ShapeType,'-',handles.uibuttongroup1.SelectedObject.String];
    switch out_mode
        case 'Point-Parent Axis'
            DATA = shaperead(handles.filename);
            DATA = convert2wsg(DATA);
            Npoints = length(DATA);
            if Npoints>0
                p = cell(Npoints,4);
                val = handles.listbox1.Value;
                fldname = handles.listbox1.String{val};
                p(:,1)={DATA.(fldname)}';
                if isfield(DATA,'Y')
                    p(:,2)={DATA.Y}';
                    p(:,3)={DATA.X}';
                else
                    p(:,2)={DATA.Lat}';
                    p(:,3)={DATA.Lon}';
                end
            end
            p(:,4)=num2cell(zeros(Npoints,1));
            xv = handles.bbox1([1 2 2 1],1);
            yv = handles.bbox1([1 1 2 2],2);
            in = inpolygon(cell2mat(p(:,3)),cell2mat(p(:,2)),xv,yv);
            p=p(in,:);            
            
        case 'Point-Polyline'
            DATA = shaperead(handles.filename);
            DATA = convert2wsg(DATA);
            Npoints = length(DATA);
            p = cell(Npoints,4);
            val = handles.listbox1.Value;
            fldname = handles.listbox1.String{val};
            p(:,1)={DATA.(fldname)}';
            if isfield(DATA,'Y')
                p(:,2)={DATA.Y}';
                p(:,3)={DATA.X}';
            else
                p(:,2)={DATA.Lat}';
                p(:,3)={DATA.Lon}';
            end
            p(:,4)=num2cell(zeros(Npoints,1));
            in = inpolygon(cell2mat(p(:,3)),cell2mat(p(:,2)),handles.bbox2(:,1),handles.bbox2(:,2));
            p=p(in,:);
            
        otherwise
            
    end
end
varargout{1} = p;
delete(handles.figure1)

function listbox1_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function listbox1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton1_Callback(hObject, eventdata, handles)
close(handles.figure1)

function pushbutton2_Callback(hObject, eventdata, handles)
handles.exittype = 0;
guidata(hObject,handles)
close(handles.figure1)

function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);
