function varargout = GRD(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GRD_OpeningFcn, ...
    'gui_OutputFcn',  @GRD_OutputFcn, ...
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

function GRD_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

% only once
load grdbuttons c1 c2 c3 c4
handles.Exit_button.CData     = c1;
handles.Distance_button.CData = c2;
handles.po_refresh_GE.CData   = c3;
handles.undock.CData          = c4;

handin        = varargin{1};
handles.sys   = handin.sys;
handles.opt   = handin.opt;
handles.h     = handin.h;
handles.model = handin.model;
handles.GoogleEarthOpt     = handin.GoogleEarthOpt;
handles.branch_menu.String = {handles.model.id};
handles.site_menu.String   = handles.h.id;
handles.IM_menu.String     = IM2str(handles.opt.IM);

xlab    = findall(handin.ax,'tag','xlabel'); xlabel(handles.ax1,xlab.String);
ylab    = findall(handin.ax,'tag','ylabel'); ylabel(handles.ax1,ylab.String);
mapdata = findall(handin.ax,'tag','shape1'); copyobj(mapdata    , handles.ax1);
GEimage = findall(handin.ax,'tag','gmap');   copyobj(GEimage(1) , handles.ax1);
areas   = findall(handin.ax,'tag','areas');  copyobj(areas      , handles.ax1);
lines   = findall(handin.ax,'tag','lines');  copyobj(lines      , handles.ax1);
points  = findall(handin.ax,'tag','points'); copyobj(points     , handles.ax1);
handles.ax1.XLim            = handin.ax.XLim;
handles.ax1.YLim            = handin.ax.YLim;
handles.ax1.DataAspectRatio = handin.ax.DataAspectRatio;
uistack(GEimage(1),'bottom'); handles.ax1.Layer='top';
handles.ax1.ButtonDownFcn={@clear_grdxt;handles.ax1};
ch = findall(handles.ax1,'tag','gmap');
ch.ButtonDownFcn={@clear_grdxt;handles.ax1};
site = handles.h.p(1,:);
plot  (handles.ax1,site(2),site(1),'rs','tag','siteplot','markerfacecolor','k')

% computes Tmax
Tmax = [];
for i=1:length(handles.model)
    for j=1:length(handles.model(i).source)
        str  = func2str(handles.model(i).source(j).gmpe.handle);
        T    = mGMPE_info(str);
        Tmax = [Tmax;max(T)];
    end
end
Tmax = min(Tmax);
handles.Tmax = Tmax;

% state variables
ch=findall(handles.ax1,'tag','shape1'); handles.display_boundaries.Value = convert(ch.Visible);
ch=findall(handles.ax1,'tag','areas');  handles.display_sources.Value    = convert(ch.Visible);
ch=findall(handles.ax1,'tag','gmap');   handles.display_terrain.Value    = convert(ch.Visible);

guidata(hObject, handles);
setTickLabel(handles.ax1)
akZoom(handles.ax1)
% uiwait(handles.figure1);

function varargout = GRD_OutputFcn(hObject, eventdata, handles)
varargout{1} = [];

% ----------------------  Main Pannel -------------------------------------
function val=convert(str)

switch str
    case 'on',  val=1;
    case 'off', val=0;
end

function branch_menu_Callback(hObject, eventdata, handles)

function site_menu_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function IM_menu_Callback(hObject, eventdata, handles)

function select_IM_Callback(hObject, eventdata, handles)
ch=findall(handles.ax1,'tag','grdtext');delete(ch);
val = hObject.Value;
tit = hObject.String{val};
if val==1
    u = handles.data.MapTs;
else
    modo = handles.uibuttongroup1.SelectedObject.String;
    u    = getGRDfield(handles,modo);
end
ptype = handles.display_contours.Value;
plot_GRD_data(handles.ax1,handles.p,handles.t,u,tit,ptype)

function retperiod_Callback(hObject, eventdata, handles)

if handles.select_IM.Value>1
    ch=findall(handles.ax1,'tag','grdtext');delete(ch);
    modo = handles.uibuttongroup1.SelectedObject.String;
    u   = getGRDfield(handles,modo);
    tit = handles.select_IM.String{handles.select_IM.Value};
    ptype = handles.display_contours.Value;
    plot_GRD_data(handles.ax1,handles.p,handles.t,u,tit,ptype)
end

function browse_grd_Callback(hObject, eventdata, handles)
W=what('platform_grd_sources');
[fname,pathname,FILTERINDEX]=uigetfile([W.path,'\*.mat']);
if FILTERINDEX==0, return; end
handles.grd_file.String=fname;
handles.data = load(fullfile(pathname,fname),'mapIM');
handles.data = handles.data.mapIM;
ind  = find(handles.data.T>handles.Tmax);
handles.data.T(ind)=[];
handles.data.MapRSR(:,:,ind)=[];
[x,y] = meshgrid(handles.data.Long,handles.data.Lat);
handles.p = [x(:),y(:)];
handles.t = delaunayn(handles.p);
handles.select_IM.String=['T(s)',IM2str(handles.data.T)];
handles.select_IM.Enable='on';
handles.retperiod.Enable='on';
tit = handles.select_IM.String{1};
ptype = handles.display_contours.Value;
plot_GRD_data(handles.ax1,handles.p,handles.t,handles.data.MapTs,tit,ptype)

% freezes logic tree, site, and Primary IM menus
handles.branch_menu.Enable='off';
handles.site_menu.Enable  ='off';
handles.IM_menu.Enable    ='off';
handles.source1.Enable    = 'on';
handles.source1.Value     = 1;
handles.retperiod.Enable  ='on';
guidata(hObject,handles)

function browse_UHS_Callback(hObject, eventdata, handles)
W=what('platform_grd_sources');
[fname,pathname,FILTERINDEX]=uigetfile([W.path,'\*.txt']);
if FILTERINDEX==0, return; end
handles.uhs_file.String=fname;

% loads and process file
fid = fopen(fullfile(pathname,fname));
if fid==-1
    return
end
data = textscan(fid,'%s','delimiter','\n');
data = data{1};
fclose(fid);

% removes comments and trailing blank spaces
ind=strfind(data,'#');
for i=1:size(data,1)
    if ~isempty(ind{i})
        II = ind{i}(1);
        data{i}(II:end)=[];
    end
    data{i}=deblank(data{i});
end

% removes empty lines
emptylist= [];
for i=1:size(data,1)
    if isempty(data{i,1})
        emptylist=[emptylist,i]; %#ok<*AGROW>
    end
end
data(emptylist,:)=[];

% removes multiple spaces
data=regexprep(data,' +',' ');
data=regexp(data,'\ ','split');
handles.uhs = str2double(vertcat(data{:}));
handles.source2.Enable = 'on';
handles.source2.Value  = 1;
handles.retperiod.Enable='off';
guidata(hObject,handles)

function grd_file_Callback(hObject, eventdata, handles)

function uhs_file_Callback(hObject, eventdata, handles)


% ----------------- display options ---------------------------------------
function display_grid_Callback(hObject, eventdata, handles)
switch hObject.Value
    case 0, grid(handles.ax1,'off');
    case 1, grid(handles.ax1,'on');
end

function display_boundaries_Callback(hObject, eventdata, handles)
ch=findall(handles.ax1,'tag','shape1');
if ~isempty(ch)
    switch hObject.Value
        case 0, ch.Visible='off';
        case 1, ch.Visible='on';
    end
end

function display_sources_Callback(hObject, eventdata, handles)
ch1=findall(handles.ax1,'tag','areas');
ch2=findall(handles.ax1,'tag','lines');
ch3=findall(handles.ax1,'tag','points');
if ~isempty(ch1)
    switch hObject.Value
        case 0, ch1.Visible='off';ch2.Visible='off';ch3.Visible='off';
        case 1, ch1.Visible='on'; ch2.Visible='on'; ch3.Visible='on';
    end
end

function display_site_Callback(hObject, eventdata, handles)
ch=findall(handles.ax1,'tag','siteplot');
if ~isempty(ch)
    switch hObject.Value
        case 0, ch.Visible='off';
        case 1, ch.Visible='on';
    end
end

function display_contours_Callback(hObject, eventdata, handles)
ch1=findall(handles.ax1,'tag','fill');
ch2=findall(handles.ax1,'tag','contour');
if ~isempty(ch1)
    switch hObject.Value
        case 0, ch1.Visible='on';   ch2.Visible='off'; 
        case 1, ch1.Visible='off';  ch2.Visible='on';  
    end
end

function display_terrain_Callback(hObject, eventdata, handles)

ch=findall(handles.ax1,'tag','gmap');
if ~isempty(ch)
    switch hObject.Value
        case 0, ch.Visible='off';
        case 1, ch.Visible='on';
    end
end

% ---------------  corner buttons for ax1 ---------------------------------

function po_refresh_GE_Callback(hObject, eventdata, handles)
if handles.opt.ellipsoid.Code==0
    return
end

if ~exist('api_Key.mat','file')
    warndlg('You must use an API key to authenticate each request to Google Maps Platform APIs. For additional information, please refer to http://g.co/dev/maps-no-account')
    return
end

a=1;
if ispc
    a=system('ping -n 1 www.google.com');
elseif isunix
    a=system('ping -c 1 www.google.com');
end
if a==1
    fprintf('Warning: No Internet Access found\n');
    return
end

opt=handles.GoogleEarthOpt;
caxis(handles.ax1);
gmap=plot_google_map(...
    'Axis',handles.ax1,...
    'Height',640,...
    'Width',640,...
    'Scale',2,...
    'MapType',opt.MapType,...
    'Alpha',opt.Alpha,...
    'ShowLabels',opt.ShowLabels,...
    'autoAxis',0,...
    'refresh',0,...
    'color',opt.Color);
gmap.Tag='gmap';
ch = findall(handles.ax1,'Tag','gmap');
if length(ch)>1
    delete(ch(1))
    ch(1)=[];
end
try %#ok<TRYNC>
    uistack(gmap,'bottom');
    handles.ax1.Layer='top';
end
guidata(hObject,handles)

function Distance_button_Callback(hObject, eventdata, handles)
ch1=findall(handles.ax1,'tag','patchselect');
ch2=findall(handles.ax1,'tag','patchtxt');
if isempty(ch1) && isempty(ch2)
    ch1=findall(handles.figure1,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
    ch2=findall(handles.figure1,'type','uimenu','Enable','on'); set(ch2,'Enable','off');
    XYLIM1 = get(handles.ax1,{'xlim','ylim'});
    if handles.opt.ellipsoid.Code==0
        show_distanceECEF(handles.ax1,'line');
    else
        show_distance(handles.ax1,'line');
    end
    XYLIM2 = get(handles.ax1,{'xlim','ylim'});
    set(handles.ax1,{'xlim','ylim'},XYLIM1);
    set(handles.ax1,{'xlim','ylim'},XYLIM2);
    set(ch1,'Enable','on')
    set(ch2,'Enable','on')
else
    delete(ch1);
    delete(ch2);
end
guidata(hObject, handles);

function Exit_button_Callback(hObject, eventdata, handles)
close(handles.figure1)

% ---------------  miscelaneous -------------------------------------------
function clear_grdxt(hObject,eventdata,h) %#ok<*INUSL,*INUSD>
ch=findall(h,'Tag','grdtext');delete(ch);

function ResetButton_Callback(hObject, eventdata, handles)
handles.branch_menu.Enable='on'; handles.branch_menu.Value = 1;
handles.site_menu.Enable  ='on'; handles.site_menu.Value   = 1;
handles.IM_menu.Enable    ='on'; handles.IM_menu.Value     = 1;
handles.select_IM.Value   = 1;
handles.select_IM.String  = {' '}; handles.select_IM.Enable = 'inactive';
handles.retperiod.String  = '250'; handles.retperiod.Enable = 'inactive';
delete(findall(handles.ax1,'Tag','grdtext'));

% freezes logic tree, site, and Primary IM menus
if isfield(handles,'data')
    handles = rmfield(handles,{'data','p','t'});
end
if isfield(handles,'uhs')
    handles = rmfield(handles,{'uhs'});
end
handles.source1.Value=1;
handles.source1.Enable='off';
handles.source2.Enable='off';
handles.retperiod.Enable='on';
handles.grd_file.String = '';
handles.uhs_file.String = '';
delete(findall(handles.ax1,'tag','fill'))
delete(findall(handles.ax1,'tag','contour'))
delete(findall(handles.figure1,'type','colorbar'))
guidata(hObject,handles)

function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
val  = handles.select_IM.Value;
tit  = handles.select_IM.String{val};
modo = handles.uibuttongroup1.SelectedObject.String;

if val==1
    ptype = handles.display_contours.Value;
    plot_GRD_data(handles.ax1,handles.p,handles.t,handles.data.MapTs,tit,ptype)
else
    u     = getGRDfield(handles,modo);
    ptype = handles.display_contours.Value;
    plot_GRD_data(handles.ax1,handles.p,handles.t,u,tit,ptype)
end

switch modo
    case 'PSHA'
        handles.retperiod.Enable='on';
    case 'Event'
        handles.retperiod.Enable='off';
end

function undock_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax1)
