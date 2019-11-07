function varargout = GMStationSelect(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GMStationSelect_OpeningFcn, ...
    'gui_OutputFcn',  @GMStationSelect_OutputFcn, ...
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

function GMStationSelect_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

handles.GoogleEarthOpt        = GEOptions('default');
handles.opt.ellipsoid         = referenceEllipsoid('WGS84','km');
handles.Exit_button.CData     = double(imread('exit.jpg'))/255;
handles.setXYLimits.CData     = double(imresize(imread('Ruler.jpg'),[16 16]))/255;
handles.Distance_button.CData = double(imread('Scale.jpg'))/255;
handles.po_refresh_GE.CData   = double(imread('Refresh.jpg'))/255;
handles.draw_square.CData   = double(imread('Square.jpg'))/255;
handles.draw_polygone.CData = double(imread('Polygone.jpg'))/255;
handles.SetGrid.CData = double(imread('Grid.jpg'))/255;

ihandles = varargin{1};
station  = ihandles.station;
Nsta = length(station);
p = cell(Nsta,4);
for i=1:Nsta
    p{i,1}=sprintf('%-4i.- %s',i,station(i).label);
    p{i,2}=station(i).gps(1);
    p{i,3}=station(i).gps(2);
    p{i,4}=station(i).gps(3);
end
handles.p  = p;
handles.listbox1.String = handles.p(:,1);
if isempty(ihandles.site_selection)
    handles.listbox1.Value  = 1:size(handles.p,1);
else
    handles.listbox1.Value  = ihandles.site_selection;
    full_list = length(ihandles.site_selection)==length(1:size(handles.p,1));
    if full_list
        handles.uibuttongroup3.SelectedObject = handles.radiobutton4;
        handles.listbox1.Value  = ihandles.site_selection;
    else
        handles.uibuttongroup3.SelectedObject = handles.radiobutton5;
    end
end

% graphics
gps=vertcat(station.gps);
c = repmat([0      0.44706      0.74118],Nsta,1);
scatter(handles.ax1,gps(:,2),gps(:,1),[],c,'filled','markeredgecolor','k','tag','siteplot');
DATA=load('chile.mat');
handles.ax1.XLim = DATA.XLIM;
handles.ax1.YLim = DATA.YLIM;
gmap             = image(DATA.xx,DATA.yy,DATA.cc, 'Parent', handles.ax1);
gmap.Tag         = 'gmap';
gmap.Visible     = 'on';
handles.ax1.YDir = 'normal';
uistack(gmap,'bottom');
handles.ax1.Layer='top';

akZoom(handles.ax1)
guidata(hObject, handles);
uiwait(handles.GMselectsta);

function varargout = GMStationSelect_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.listbox1.Value;
delete(handles.GMselectsta)

function listbox1_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
handles.selection=hObject.Value;
handles.uibuttongroup3.SelectedObject = handles.radiobutton5;
guidata(hObject,handles)

function listbox1_CreateFcn(hObject, eventdata, handles) %#ok<INUSD>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uibuttongroup3_SelectionChangedFcn(hObject, eventdata, handles)

switch hObject.String
    case 'All'
        handles.listbox1.Value =  1:size(handles.p,1);
        
    case 'From List'

    case 'Within Map Limits'
        x         = cell2mat(handles.p(:,3));
        y         = cell2mat(handles.p(:,2));
        xv        = handles.ax1.XLim([1,2,2,1])';
        yv        = handles.ax1.YLim([1 1 2 2])';
        handles.listbox1.Value = find(inpolygon(x,y,xv,yv));
end

guidata(hObject,handles)

function GMselectsta_CloseRequestFcn(hObject, ~, ~)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

% --- Executes on button press in Exit_button.
function Exit_button_Callback(hObject, eventdata, handles)
close(handles.GMselectsta)

function setXYLimits_Callback(hObject, eventdata, handles)
handles.XLIM=handles.ax1.XLim;
handles.YLIM=handles.ax1.YLim;
akZoom(handles.ax1)
guidata(hObject,handles)

function Distance_button_Callback(hObject, eventdata, handles)
ch1=findall(handles.ax1,'tag','patchselect');
ch2=findall(handles.ax1,'tag','patchtxt');
if isempty(ch1) && isempty(ch2)
    ch1=findall(handles.GMselectsta,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
    ch2=findall(handles.GMselectsta,'type','uimenu','Enable','on'); set(ch2,'Enable','off');
    
    XYLIM1 = get(handles.ax1,{'xlim','ylim'});
    if isempty(handles.opt.ellipsoid.Code)
        show_distanceECEF(handles.ax1,'line');
    else
        show_distance(handles.ax1,'line');
    end
    XYLIM2 = get(handles.ax1,{'xlim','ylim'});
    set(handles.ax1,{'xlim','ylim'},XYLIM1);
    akZoom(handles.ax1);
    set(handles.ax1,{'xlim','ylim'},XYLIM2);
    set(ch1,'Enable','on')
    set(ch2,'Enable','on')
else
    delete(ch1);
    delete(ch2);
end
guidata(hObject, handles);

function po_refresh_GE_Callback(hObject, eventdata, handles)

if ispc
    a=system('ping -n 1 www.google.com');
elseif isunix
    a=system('ping -c 1 www.google.com');
end
if a==1
    warndlg('No Internet Access found','Background');
    return
end

opt=handles.GoogleEarthOpt;
caxis(handles.ax1);
gmap=plot_google_map(...
    'Axis',handles.ax1,...
    'Height',640,...
    'Width',640,...
    'Scale',opt.Scale,...
    'MapType',opt.MapType,...
    'Alpha',opt.Alpha,...
    'ShowLabels',opt.ShowLabels,...
    'autoAxis',0,...
    'refresh',0);
gmap.Tag='gmap';
ch = findall(handles.ax1,'Tag','gmap');
if length(ch)>1
    delete(ch(1))
    ch(1)=[]; %#ok<*NASGU>
end
try %#ok<TRYNC>
    uistack(gmap,'bottom');
    handles.ax1.Layer='top';
end
guidata(hObject,handles)

function draw_square_Callback(hObject, eventdata, handles)

ch1=findall(handles.GMselectsta,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
ch2=findall(handles.GMselectsta,'type','uimenu','Enable','on'); set(ch2,'Enable','off');

XYLIM1 = get(handles.ax1,{'xlim','ylim'});
p      = grid2C(handles.ax1,'square');
XYLIM2 = get(handles.ax1,{'xlim','ylim'});
set(handles.ax1,{'xlim','ylim'},XYLIM1);
akZoom(handles.ax1);
set(handles.ax1,{'xlim','ylim'},XYLIM2);
latlon = p.Vertices(:,[2,1]);
handles.tempBox = latlon(:,[2,1]);
set(ch1,'Enable','on')
set(ch2,'Enable','on')
guidata(hObject, handles);

function draw_polygone_Callback(hObject, eventdata, handles) %#ok<*INUSL>
ch1=findall(handles.GMselectsta,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
ch2=findall(handles.GMselectsta,'type','uimenu','Enable','on'); set(ch2,'Enable','off');

p      = gridNC(handles.ax1,'polygone');
latlon = get(p,'vertices');
if size(latlon,1)<=1
    ch     = findall(handles.GMselectsta,'tag','patchselect');delete(ch);
    return;
end
handles.tempBox = latlon(:,[2,1]);
set(ch1,'Enable','on')
set(ch2,'Enable','on')
guidata(hObject, handles);

function SetGrid_Callback(hObject, eventdata, handles)

switch handles.ax1.XGrid
    case 'off', handles.ax1.XGrid='on';  handles.ax1.YGrid='on';
    case 'on' , handles.ax1.XGrid='off'; handles.ax1.YGrid='off';
end

function replace_Stations_Callback(hObject, eventdata, handles)
handles.uibuttongroup3.SelectedObject = handles.radiobutton5;
ch = findall(handles.ax1,'tag','patchselect');delete(ch);
x         = cell2mat(handles.p(:,3));
y         = cell2mat(handles.p(:,2));
xv        = handles.tempBox(:,1);
yv        = handles.tempBox(:,2);
new_sta   = find(inpolygon(x,y,xv,yv));
handles.listbox1.Value = new_sta;

guidata(hObject,handles)

function stack_stations_Callback(hObject, eventdata, handles)
handles.uibuttongroup3.SelectedObject = handles.radiobutton5;
ch = findall(handles.ax1,'tag','patchselect');delete(ch);
x         = cell2mat(handles.p(:,3));
y         = cell2mat(handles.p(:,2));
xv        = handles.tempBox(:,1);
yv        = handles.tempBox(:,2);
new_sta   = find(inpolygon(x,y,xv,yv));
old_sta   = handles.listbox1.Value;
new_sta   = unique([new_sta(:);old_sta(:)])';
new_sta   = sort(new_sta); %#ok<*TRSRT>
handles.listbox1.Value = new_sta;
