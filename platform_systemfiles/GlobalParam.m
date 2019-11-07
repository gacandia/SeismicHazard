function varargout = GlobalParam(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GlobalParam_OpeningFcn, ...
    'gui_OutputFcn',  @GlobalParam_OutputFcn, ...
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

function GlobalParam_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;

if nargin==3
    load pshatoolbox_RealValues opt
else
    opt = varargin{1};
end

methods = pshatoolbox_methods(3); handles.pop_spatial.String  ={methods.label};
methods = pshatoolbox_methods(4); handles.pop_spectral.String ={methods.label};

handles.imdisplayed = 1;
handles = popfields(handles,opt);
handles.im = opt.im;
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = GlobalParam_OutputFcn(hObject, eventdata, handles)

opt.Projection       = handles.Projection.String{handles.Projection.Value};
switch opt.Projection
    case 'ECEF'
        opt.ellipsoid=struct('Code',0);
    otherwise
        opt.ellipsoid=referenceEllipsoid(opt.Projection,'km');
end
opt.Image            = handles.Image.String;
opt.Boundary         = handles.Boundary.String;
opt.Layer            = handles.Layer.String;
opt.ShearModulus     = str2double(handles.ShearModulus.String);
opt.IM               = str2IM(handles.IM.String);
opt.im               = handles.im;
opt.MaxDistance      = str2double(handles.MaxDistance.String);

switch handles.check1.Value
    case 1, opt.MagDiscrete     = {'gauss'  ,str2double(handles.pop2.String{handles.pop2.Value})};
    case 0, opt.MagDiscrete     = {'uniform',str2double(handles.txt10.String)};
end

switch handles.check5.Value
    case 1, rngtype ='shuffle';
    case 0, rngtype ='default';
end

switch handles.check3.Value
    case 1, opt.CGMM = {rngtype,'PC',str2double(handles.SimPCE.String)};
    case 0, opt.CGMM = {rngtype,'MC',str2double(handles.SimPCE.String)};
end

method1      = pshatoolbox_methods(3); 
method2      = pshatoolbox_methods(4); 
opt.IM1      = str2IM(handles.primaryIM.String);
opt.IM2      = str2IM(handles.secondaryIM.String); opt.IM2=opt.IM2(:);
opt.Spatial  = method1(handles.pop_spatial.Value).func;
opt.Spectral = method2(handles.pop_spectral.Value).func;

switch handles.LiteModeCheck.Value
    case 0,opt.LiteMode='off';
    case 1,opt.LiteMode='on';
end

opt.Clusters = cell(1,2);
switch handles.UseClusters.Value
    case 0,opt.Clusters{1}='off';
    case 1,opt.Clusters{1}='on';
end
opt.Clusters{2}=[str2double(handles.numclusters.String) str2double(handles.numreplicates.String)];

varargout{1} = opt;
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
[~,handles.Projection.Value] = intersect(lower(handles.Projection.String),lower(opt.Projection));
handles.Image.String         = opt.Image;
handles.Boundary.String      = opt.Boundary;
handles.Layer.String         = opt.Layer;
handles.ShearModulus.String  = sprintf('%4.2e',opt.ShearModulus);

switch opt.LiteMode
    case 'off'
        handles.LiteModeCheck.Value=0;
    case 'on'
        handles.LiteModeCheck.Value=1;
end

switch opt.Clusters{1}
    case 'off'
        handles.UseClusters.Value=0; 
        handles.numclusters.Enable   = 'off';
        handles.numreplicates.Enable = 'off';        
    case 'on'
        handles.UseClusters.Value=1;
        handles.numclusters.Enable   = 'on';
        handles.numreplicates.Enable = 'on';        
end

handles.numclusters.String   = sprintf('%g',opt.Clusters{2}(1));
handles.numreplicates.String = sprintf('%g',opt.Clusters{2}(2));

% psha parameters
handles.IM.String           = IM2str(opt.IM);
imdisplayed                 = handles.imdisplayed;
handles.imvalues.Data       = num2cell(opt.im(:,imdisplayed));
handles.imvalues.ColumnName = IM2str(opt.IM(imdisplayed));
handles.MaxDistance.String  = num2str(opt.MaxDistance);
handles.SimPCE.String       = num2str(max(opt.CGMM{3},20));

% CGMM Parametetr
handles.check3.Value = strcmpi(opt.CGMM{2},'PC');
handles.check4.Value = strcmpi(opt.CGMM{2},'MC');
handles.check5.Value = strcmpi(opt.CGMM{1},'shuffle');
handles.check6.Value = strcmpi(opt.CGMM{1},'default');

% dsha parameters
handles.primaryIM.String    = IM2str(opt.IM1);
handles.secondaryIM.String  = IM2str(opt.IM2);

method1  = pshatoolbox_methods(3); 
method2  = pshatoolbox_methods(4); 
str1     = func2str(opt.Spatial);
str2     = func2str(opt.Spectral);

[~,handles.pop_spatial.Value]  = intersect({method1.str},str1);
[~,handles.pop_spectral.Value] = intersect({method2.str},str2);

% magnitude integration
handles.check1.Value = strcmpi(opt.MagDiscrete{1},'gauss');
handles.check2.Value = strcmpi(opt.MagDiscrete{1},'uniform');

if handles.check1.Value
    str  = handles.pop2.String;
    stri = num2str(opt.MagDiscrete{2});
    [~,handles.pop2.Value]=intersect(str,stri);
    handles.pop2.Enable='on';
    handles.txt10.Enable='off';
end

if handles.check2.Value
    handles.txt10.String = num2str(opt.MagDiscrete{2});
    handles.pop2.Enable='off';
    handles.txt10.Enable='on';
end

function Projection_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>

function ShearModulus_Callback(hObject, eventdata, handles)

function MeshType_Callback(hObject, eventdata, handles)

function popupmenu4_Callback(hObject, eventdata, handles)

function MaxDistance_Callback(hObject, eventdata, handles)
Nc = str2double(hObject.String);
Nc = max(Nc,0.1);
hObject.String=sprintf('%g',Nc);

function popupmenu5_Callback(hObject, eventdata, handles)

function IM_Callback(hObject, eventdata, handles)
hObject.String  = field2str(hObject.String);

Nim   = size(handles.im,1);
NIM   = length(hObject.String);
newim = repmat(logsp(0.01,3,Nim)',1,NIM);
handles.imvalues.Data=num2cell(newim(:,1));
handles.imvalues.ColumnName=hObject.String{1};
handles.im = newim;
warndlg('im values have been reset');
guidata(hObject,handles)

function imvalues_Callback(hObject, eventdata, handles)

function File_Callback(hObject, eventdata, handles)

function Exit_Callback(hObject, eventdata, handles)
close(handles.figure1)

function Image_Callback(hObject, eventdata, handles)

function Boundary_Callback(hObject, eventdata, handles)

function Layer_Callback(hObject, eventdata, handles)

function RestoreDefault_Callback(hObject, eventdata, handles)

opt.Projection   = 'WGS84';
opt.ellipsoid    = referenceEllipsoid(opt.Projection,'km');
opt.Image        = '';
opt.Boundary     = '';
opt.Layer        = '';
opt.ShearModulus = 3.0000e+11;
opt.IM           = 0;
opt.im           = [0.0010 0.01 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.70 0.80 0.90 1.00]';
opt.MaxDistance  = 500;
opt.MagDiscrete  = {'gauss',10};
opt.CGMM         = {'shuffle','MC',500};
opt.IM1          = 0.0100;
opt.IM2          = [1 2]';
opt.Spatial      = @none_spatial;
opt.Spectral     = @none_spectral;
opt.LiteMode     = 'off';
opt.Clusters     = {'off',[100 1]};
D = what('platform_realvalues');
save([D.path,'\','pshatoolbox_RealValues'],'opt');
handles=popfields(handles,opt);
guidata(hObject,handles)

function Image_ButtonDownFcn(hObject, eventdata, handles)

D = what('platform_earth');
[filename,pathname]=uigetfile([D.path,'\*.mat'], 'Select file');
if isnumeric(filename)
    return
end
addpath(pathname);
handles.Image.String=filename;
guidata(hObject,handles)

function Boundary_ButtonDownFcn(hObject, eventdata, handles)

D = what('platform_shapefiles');
[filename,pathname]=uigetfile([D.path,'\*.shp'], 'Select file');
if isnumeric(filename)
    return
end
addpath(pathname);
handles.Boundary.String=filename;
guidata(hObject,handles)

function Layer_ButtonDownFcn(hObject, eventdata, handles)

D = what('platform_shapefiles');
[filename,pathname]=uigetfile([D.path,'\*.shp'], 'Select file');
if isnumeric(filename)
    return
end
addpath(pathname);
handles.Layer.String=filename;
guidata(hObject,handles)

function check1_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 0, handles.check2.Value=1;handles.pop2.Enable='off'; handles.txt10.Enable='on';
    case 1, handles.check2.Value=0;handles.pop2.Enable='on';  handles.txt10.Enable='off';
end

function pop2_Callback(hObject, eventdata, handles)

function check2_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 1, handles.check1.Value=0;handles.pop2.Enable='off'; handles.txt10.Enable='on';
    case 0, handles.check1.Value=1;handles.pop2.Enable='on';  handles.txt10.Enable='off';
end

function txt10_Callback(hObject, eventdata, handles)

function primaryIM_Callback(hObject, eventdata, handles)
hObject.String  = field2str(hObject.String,'single');
guidata(hObject,handles)

function edit15_Callback(hObject, eventdata, handles)

function pop_spatial_Callback(hObject, eventdata, handles)

function pop_spectral_Callback(hObject, eventdata, handles)

function NumSimul_Callback(hObject, eventdata, handles)

function secondaryIM_Callback(hObject, eventdata, handles)
hObject.String  = field2str(hObject.String);
guidata(hObject,handles)

function imvalues_ButtonDownFcn(hObject, eventdata, handles)
str = handles.IM.String;
Nim = length(str);
if handles.imdisplayed<Nim
    handles.imdisplayed  = handles.imdisplayed+1;
else
    handles.imdisplayed  = 1;
end
handles.imvalues.Data       = num2cell(handles.im(:,handles.imdisplayed));
handles.imvalues.ColumnName = str{handles.imdisplayed};
guidata(hObject,handles)

function Edit_Callback(hObject, eventdata, handles)

function overwriteim_Callback(hObject, eventdata, handles)

val = handles.imvalues.Data;
label = handles.imvalues.ColumnName;
if iscell(label)
    label=label{1};
end
str1 = sprintf('min %s',label);
str2 = sprintf('max %s',label);
val1 = num2str(val{1});
val2 = num2str(val{end});
answer = inputdlg({str1,str2},'im values',1,{val1,val2});
if isempty(answer)
    return
end
Nim = length(val);
val = logsp(str2double(answer{1}),str2double(answer{2}),Nim)';
handles.imvalues.Data=num2cell(val);
[~,imptr] = intersect(handles.IM.String,label);
handles.im(:,imptr)=val;
guidata(hObject,handles)

function SimPCE_Callback(hObject, eventdata, handles)
Nc = str2double(hObject.String);
Nc = max(round(Nc),20);
hObject.String=sprintf('%i',Nc);

function numclusters_Callback(hObject, eventdata, handles)
Nc = str2double(hObject.String);
Nc = max(round(Nc),1);
hObject.String=sprintf('%i',Nc);

function numreplicates_Callback(hObject, eventdata, handles)
Nc = str2double(hObject.String);
Nc = max(round(Nc),1);
hObject.String=sprintf('%i',Nc);

function LiteModeCheck_Callback(hObject, eventdata, handles)

function UseClusters_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 0
        handles.numclusters.Enable   = 'off';
        handles.numreplicates.Enable = 'off';
    case 1
        handles.numclusters.Enable   = 'on';
        handles.numreplicates.Enable = 'on';
end
