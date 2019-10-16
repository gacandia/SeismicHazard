function varargout = SelectLocationOptions(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SelectLocationOptions_OpeningFcn, ...
    'gui_OutputFcn',  @SelectLocationOptions_OutputFcn, ...
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

function SelectLocationOptions_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
handles.up1.CData = double(imread('UpOneLevel.jpg'))/255;
handles.up2.CData = double(imread('UpOneLevel.jpg'))/255;
handles.up3.CData = double(imread('UpOneLevel.jpg'))/255;

if nargin==3
    fname  = what('platform_earth');      handles.path1 = fname.path;
    fname  = what('platform_shapefiles'); handles.path2 = fname.path;
    fname  = what('platform_shapefiles'); handles.path3 = fname.path;
else
    handles.path1 = varargin{1}{1};
    handles.path2 = varargin{1}{2};
    handles.path3 = varargin{1}{3};
    opt  = varargin{2};
end

D1       = dir(handles.path1);
D1(1:2)  = []; D1(~vertcat(D1.isdir))=[];
matfiles = mapdir([handles.path1,'\*.mat']);
handles.listbox1.String= {D1.name,matfiles.name};

if nargin>3 && ~isempty(opt.Image)
    [~,B]=intersect(fullfile(handles.path1,{matfiles.name}),opt.Image);
    if ~isempty(B)
        handles.listbox1.Value = B;
    end
end

D2       = dir(handles.path2);
D2(1:2)  = []; D2(~vertcat(D2.isdir))=[];
shpfiles = dir([handles.path2,'\*.shp']);
handles.listbox2.String= {D2.name,shpfiles.name};

if nargin>3 && ~isempty(opt.Boundary)
    [~,B]=intersect(fullfile(handles.path2,{shpfiles.name}),opt.Boundary);
    if ~isempty(B)
        handles.listbox2.Value = B;
    end
end

D3       = dir(handles.path3);
D3(1:2)  = []; D3(~vertcat(D3.isdir))=[];
shpfiles = dir([handles.path3,'\*.shp']);
handles.listbox3.String= {D3.name,shpfiles.name};

if nargin>3  && ~isempty(opt.Layer)
    [~,B]=intersect(fullfile(handles.path3,{shpfiles.name}),opt.Layer);
    if ~isempty(B)
        handles.listbox3.Value = B;
    end
end


guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = SelectLocationOptions_OutputFcn(hObject, eventdata, handles)

% base image
varargout{1} = '';
if ~isempty(handles.listbox1.String)
    file1 = handles.listbox1.String(handles.listbox1.Value,:);
    file1 = fullfile(handles.path1,file1{1});
    fshp  = strfind(file1,'.mat');
    if ~isempty(fshp)
        varargout{1} = file1;
    end
end

% boundary
varargout{2} = {''};
if ~isempty(handles.listbox2.String)
    file2 = handles.listbox2.String(handles.listbox2.Value,:);
    for i=1:size(file2,1)
        file2{i}=fullfile(handles.path2,file2{i});
    end
    fshp=strfind(file2,'.shp');
    for i=1:length(fshp)
        if isempty(fshp{i})
            fshp{i}=false;
        else
            fshp{i}=true;
        end
    end
    file2=file2(cell2mat(fshp));
    if ~isempty(file2)
        varargout{2} = file2;
    end
end

% layers
varargout{3} = {''};
if ~isempty(handles.listbox3.String)
    file3 = handles.listbox3.String(handles.listbox3.Value,:);
    for i=1:size(file3,1)
        file3{i}=fullfile(handles.path3,file3{i});
    end
    fshp=strfind(file3,'.shp');
    for i=1:length(fshp)
        if isempty(fshp{i})
            fshp{i}=false;
        else
            fshp{i}=true;
        end
    end
    file3=file3(cell2mat(fshp));
    if ~isempty(file3)
        varargout{3} = file3;
    end
end

varargout{4}={handles.path1;handles.path2;handles.path3};
delete(handles.figure1)

function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<*DEFNU>
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function listbox1_Callback(hObject, eventdata, handles)

switch handles.figure1.SelectionType
    case 'normal'
    case 'open'
        subdir=eventdata.Source.String{eventdata.Source.Value};
        if isempty(strfind(subdir,'.mat'))
            handles.path1 = [handles.path1,'\',subdir];
            D1       = dir(handles.path1);
            D1(1:2)  = []; D1(~vertcat(D1.isdir))=[];
            matfiles = mapdir([handles.path1,'\*.mat']);
            handles.listbox1.Value=1;
            handles.listbox1.String= {D1.name,matfiles.name};
        end
end
guidata(hObject,handles);

function listbox2_Callback(hObject, eventdata, handles)

switch handles.figure1.SelectionType
    case 'normal'
    case 'open'
        subdir=eventdata.Source.String{eventdata.Source.Value};
        if isempty(strfind(subdir,'.shp'))
            handles.path2 = [handles.path2,'\',subdir];
            D2       = dir(handles.path2);
            D2(1:2)  = []; D2(~vertcat(D2.isdir))=[];
            shpfiles = dir([handles.path2,'\*.shp']);
            handles.listbox2.Value=1;
            handles.listbox2.String= {D2.name,shpfiles.name};
        end
end
guidata(hObject,handles);

function listbox3_Callback(hObject, eventdata, handles)

switch handles.figure1.SelectionType
    case 'normal'
    case 'open'
        subdir=eventdata.Source.String{eventdata.Source.Value};
        if isempty(strfind(subdir,'.shp')) %#ok<*STREMP>
            handles.path3 = [handles.path3,'\',subdir];
            D3       = dir(handles.path3);
            D3(1:2)  = []; D3(~vertcat(D3.isdir))=[];
            shpfiles = dir([handles.path3,'\*.shp']);
            handles.listbox3.Value=1;
            handles.listbox3.String= {D3.name,shpfiles.name};
        end
end
guidata(hObject,handles);

function up1_Callback(hObject, eventdata, handles)

handles.path1 = fileparts(handles.path1);
D1       = dir(handles.path1);
D1(1:2)  = []; D1(~vertcat(D1.isdir))=[];
matfiles = mapdir([handles.path1,'\*.mat']);
handles.listbox1.Value=1;
handles.listbox1.String= {D1.name,matfiles.name};
guidata(hObject,handles);

function up2_Callback(hObject, eventdata, handles)
handles.path2 = fileparts(handles.path2);
D2       = dir(handles.path2);
D2(1:2)  = []; D2(~vertcat(D2.isdir))=[];
shpfiles = dir([handles.path2,'\*.shp']);
handles.listbox2.Value=1;
handles.listbox2.String= {D2.name,shpfiles.name};
guidata(hObject,handles);

function up3_Callback(hObject, eventdata, handles)
handles.path3 = fileparts(handles.path3);
D3       = dir(handles.path3);
D3(1:2)  = []; D3(~vertcat(D3.isdir))=[];
shpfiles = dir([handles.path3,'\*.shp']);
handles.listbox3.Value=1;
handles.listbox3.String= {D3.name,shpfiles.name};
guidata(hObject,handles);

