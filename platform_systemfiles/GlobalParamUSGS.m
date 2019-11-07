function varargout = GlobalParamUSGS(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GlobalParamUSGS_OpeningFcn, ...
    'gui_OutputFcn',  @GlobalParamUSGS_OutputFcn, ...
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

function GlobalParamUSGS_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;

if nargin==3
    load pshatoolbox_RealValuesUSGS opt
else
    opt = varargin{1};
end

handles=popfields(handles,opt);
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = GlobalParamUSGS_OutputFcn(hObject, eventdata, handles)

opt.Projection       = handles.Projection.String{handles.Projection.Value};
opt.ellipsoid        = referenceEllipsoid(opt.Projection,'km');
opt.Image            = handles.Image.String;
opt.Boundary         = handles.Boundary.String;
opt.Layer            = handles.Layer.String;
opt.ShearModulus     = str2double(handles.ShearModulus.String);

opt.Edition    = handles.Edition_pop.String{handles.Edition_pop.Value};
opt.Region     = handles.Region_pop.String{handles.Region_pop.Value};
opt.Vs30       = str2double(handles.Vs30_pop.String{handles.Vs30_pop.Value});
opt.IM         = {handles.IM_pop.String{handles.IM_pop.Value}};
opt.LiteMode   ='off';
opt.Clusters   ={'off',[100 1]};

% RP = handles.RPvalues.String;
% opt.returnperiods = zeros(size(RP,1),1);
% for i=1:size(RP,1)
%     opt.returnperiods(i)=str2double(RP(i,:));
% end
varargout{1}   = opt;
delete(handles.figure1)

function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function handles=popfields(handles,opt)
% global parameters
handles.Projection.Value    = 2;
handles.Image.String        = opt.Image;
handles.Boundary.String     = opt.Boundary;
handles.Layer.String        = opt.Layer;
handles.ShearModulus.String = sprintf('%4.2e',opt.ShearModulus);

% psha parameters
switch opt.Edition
    case 'E2008',handles.Edition_pop.Value=1;
    case 'E2014',handles.Edition_pop.Value=2;
end

switch opt.Region
    case 'COUS', handles.Region_pop.Value=1;
    case 'WUS' , handles.Region_pop.Value=2;
    case 'CEUS', handles.Region_pop.Value=3;
end

switch opt.Vs30
    case 180,  handles.Vs30_pop.Value=1;
    case 259,  handles.Vs30_pop.Value=2;
    case 360,  handles.Vs30_pop.Value=3;
    case 537,  handles.Vs30_pop.Value=4;
    case 760,  handles.Vs30_pop.Value=5;
    case 1150, handles.Vs30_pop.Value=6;
    case 2000, handles.Vs30_pop.Value=7;
end


Value = false(1,4);
for kk=1:length(opt.IM)
    switch opt.IM{kk}
        case 'PGA'       , Value(1)=true;
        case 'Sa(T=0.2)' , Value(2)=true; 
        case 'Sa(T=1.0)' , Value(3)=true; 
        case 'Sa(T=2.0)' , Value(4)=true; 
    end
end
handles.IM_pop.Value=find(Value);


% handles.RPvalues.String     = strtrim(sprintf('%-7.6g\n',opt.returnperiods));

function Projection_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>

function Projection_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ShearModulus_Callback(hObject, eventdata, handles)

function ShearModulus_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MeshType_Callback(hObject, eventdata, handles)

function MeshType_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu4_Callback(hObject, eventdata, handles)

function popupmenu4_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu5_Callback(hObject, eventdata, handles)

function popupmenu5_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function IM_pop_Callback(hObject, eventdata, handles)
hObject.String  = field2str(hObject.String);
guidata(hObject,handles)

function IM_pop_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% function RPvalues_Callback(hObject, eventdata, handles)
% 
% function RPvalues_CreateFcn(hObject, eventdata, handles)
% 
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end

function File_Callback(hObject, eventdata, handles)

function SetDefault_Callback(hObject, eventdata, handles)

% opt.Projection       = handles.Projection.String{handles.Projection.Value};
% opt.Image            = handles.Image.String;
% opt.Boundary         = handles.Boundary.String;
% opt.ShearModulus     = str2double(handles.ShearModulus.String);
% opt.IM_pop                = eval(['[',handles.IM_pop.String,']']);
% opt.im_pop               = eval(['[',handles.RPvalues.String,']']);
% opt.MaxDistance      = str2double(handles.MaxDistance.String);
% 
% switch opt.Projection
%     case 'Cartesian' ,
%         opt.ellipsoid=struct('Code',0);
%     otherwise,
%         opt.ellipsoid=referenceEllipsoid(opt.Projection,'km');
% end
% 
% D = what('pshatoolbox_RealValues');
% save([D.path,'\','pshatoolbox_RealValues'],'opt');

function Exit_Callback(hObject, eventdata, handles)
close(handles.figure1)

function Image_Callback(hObject, eventdata, handles)

function Image_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Boundary_Callback(hObject, eventdata, handles)

function Boundary_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Layer_Callback(hObject, eventdata, handles)

function Layer_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RestoreDefault_Callback(hObject, eventdata, handles)

opt.Projection    = 'WGS84';
opt.ellipsoid     = referenceEllipsoid(opt.Projection,'km');
opt.Image         = 'california.mat';
opt.Boundary      = 'CAL_adm1.shp';
opt.Layer         = '';
opt.ShearModulus  = 3.0000e+11;
opt.Edition       = 'E2008';
opt.Region        = 'WUS';
opt.Edition       = 'E2008';
opt.Vs30          = 760;
opt.IM            = {'PGA'};
% opt.returnperiods = [30;43;72;108;144;224;336;475;712;975;1462;1950;2475;3712;4975;7462;9950;19900];

D = what('pshatoolbox_RealValues');
save(fullfile(D.path,'pshatoolbox_RealValuesUSGS.mat'),'opt');
handles=popfields(handles,opt);
guidata(hObject,handles)

function Image_ButtonDownFcn(hObject, eventdata, handles)

D = what('pshatoolbox_GEimages');
[filename,pathname]=uigetfile([D.path,'\*.mat'], 'Select file');
if isnumeric(filename)
    return
end
addpath(pathname);
handles.Image.String=filename;
guidata(hObject,handles)

function Boundary_ButtonDownFcn(hObject, eventdata, handles)

D = what('pshatoolbox_ShapeFiles');
[filename,pathname]=uigetfile([D.path,'\*.shp'], 'Select file');
if isnumeric(filename)
    return
end
addpath(pathname);
handles.Boundary.String=filename;
guidata(hObject,handles)

function Layer_ButtonDownFcn(hObject, eventdata, handles)

D = what('pshatoolbox_ShapeFiles');
[filename,pathname]=uigetfile([D.path,'\*.shp'], 'Select file');
if isnumeric(filename)
    return
end
addpath(pathname);
handles.Layer.String=filename;
guidata(hObject,handles)

function Edition_pop_Callback(hObject, eventdata, handles)

function Edition_pop_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit15_Callback(hObject, eventdata, handles)

function edit15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Vs30_pop_Callback(hObject, eventdata, handles)

function Vs30_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vs30_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Region_pop_Callback(hObject, eventdata, handles)

function Region_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to region_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
