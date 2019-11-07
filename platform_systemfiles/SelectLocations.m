function varargout = SelectLocations(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SelectLocations_OpeningFcn, ...
    'gui_OutputFcn',  @SelectLocations_OutputFcn, ...
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

function SelectLocations_OpeningFcn(hObject, eventdata, handles, varargin)
sprintf('Select Site Toolbox');
handles.output        = hObject;
handles.Vs30.baseline = 760;
handles.Vs30.source   = {' '};
% ----------------  variable initialization--------------------------------
handles.ElevModel = 1;
handles.lmax      = 50;
guidata(hObject, handles);

handles.siteclick           = plot(handles.ax1,NaN,NaN,'.','color',[ 0.8500    0.3250    0.0980],'linestyle','none');
handles.gridplot            = plot(handles.ax1,NaN,NaN,'.:','color',[ 0.8500    0.3250    0.0980]);
handles.Exit_button.CData   = double(imread('Exit.jpg'))/255;
handles.gr.CData            = double(imread('Grid.jpg'))/255;
handles.po_Refresh.CData    = double(imread('Refresh.jpg'))/255;
handles.draw_point.CData    = double(imread('Point.jpg'))/255;
handles.draw_square.CData   = double(imread('Square.jpg'))/255;
handles.draw_polygone.CData = double(imread('Polygone.jpg'))/255;
handles.draw_line.CData     = double(imread('Line.jpg'))/255;
handles.draw_path.CData     = double(imread('Path.jpg'))/255;
handles.Distance_button.CData     = double(imread('Scale.jpg'))/255;


fname1  = what('platform_earth');
fname2  = what('platform_shapefiles');
fname3  = what('platform_shapefiles');

handles.defaultpaths = {fname1.path;fname2.path;fname3.path};
handles.GoogleEarthOpt=GEOptions('default');

% ------------------- sets Model Projection -------------------------------
if isempty(varargin)
    str = {'Cartesian','WGS84'};
    base=2;
    if isempty(base)
        return
    elseif base==1
        handles.opt.ellipsoid.Code= [];
    elseif base==2
        handles.opt.ellipsoid= referenceEllipsoid(str{base},'km');
    end
    handles.opt.Image     ='';
    handles.opt.Boundary  ='';
    handles.opt.Layer     ='';
else
    handin             = varargin{1};
    
    % convert elevation from km to m
    handin.h.p(:,3)    = handin.h.p(:,3)*1000;
    handles.opt        = handin.opt;
    handles.shape1.String = {handles.opt.Boundary};
    handles.shape2.String = {handles.opt.Layer};
    handles.Vs30      = handin.Vs30;
    plotVs30sources(handles)
end

if isempty(handles.opt.ellipsoid.Code)
    xlabel(handles.ax1,'X (km)','fontsize',8,'fontname','arial');
    ylabel(handles.ax1,'Y (km)','fontsize',8,'fontname','arial')
    handles.p.ColumnName(2:3)={'Y(km)';'X(km)'};
    handles.grid_data.ColumnName(1:2)={'Y(km)';'X(km)'};
else
    xlabel(handles.ax1,'Lon','fontsize',8,'fontname','arial');
    ylabel(handles.ax1,'Lat','fontsize',8,'fontname','arial')
    handles.p.ColumnName(2:3)={'Lat';'Lon'};
    handles.grid_data.ColumnName(1:2)={'Lat';'Lon'};
end

% ----------------- PLOTS BOUNDARY AND GOOGLE EARTH IMAGE------------------
handles.Boundary_check.Enable='on';
if isempty(varargin)
    handles.shape1.Value=1;
    handles.shape2.Value=1;
    [handles.opt.Image,handles.shape1.String,handles.shape2.String,handles.defaultpaths]=SelectLocationOptions(handles.defaultpaths,handles.opt);
    handles.opt.Boundary = handles.shape1.String{1};
    handles.opt.Layer    = handles.shape2.String{1};
    default_maps(handles,handles.ax1);
else
    ax      = handin.ax;
    mapdata = findall(ax,'tag','shape1');
    GEimage = findall(ax,'tag','gmap');uistack(GEimage,'bottom');
    GEimage = GEimage(1);
    copyobj(mapdata , handles.ax1);
    copyobj(GEimage , handles.ax1);
    handles.ax1.XLim            = ax.XLim;
    handles.ax1.YLim            = ax.YLim;
    handles.ax1.Position        = ax.Position;
    handles.ax1.DataAspectRatio = ax.DataAspectRatio;
    handles.ax1.XTick           = ax.XTick;
    handles.ax1.XTickLabel      = ax.XTickLabel;
    handles.ax1.YTick           = ax.YTick;
    handles.ax1.YTickLabel      = ax.YTickLabel;
    if ~isempty(mapdata) && strcmp(mapdata.Visible,'off')
        handles.Boundary_check.Value=0;
    end
    if ~isempty(GEimage) && strcmp(GEimage.Visible,'off')
        handles.show_terrain.Value=0;
    end
end

handles.ax1.Layer='top';

% ------ Initiaties site vector--------------------------------------------
if isempty(varargin)
    handles.p.Data= cell(0,5);
    handles.t     = cell(0,2);
    handles.shape = [];
    handles.smtable.Data=cell(0,2);
    handles.smtable.Visible='off';
    handles.smplot = patch(NaN,NaN,'w','parent',handles.ax1);
    handles.smplot.Visible='off';
else
    handles.p.Data= [handin.h.id(:),num2cell([handin.h.p,handin.h.Vs30])];
    handles.t     = handin.h.t;
    handles.shape = handin.h.shape;
    
    % initiates table
    shape = handles.shape;
    Ng = size(shape,1);
    smtable = cell(Ng,2);
    for i=1:Ng
        smtable{i,1}=['shape_',num2str(i)];
        if shape(i).active==1
            smtable{i,2}=true;
        else
            smtable{i,2}=false;
        end
    end
    if isempty(smtable)
        handles.smtable.Data=smtable;
        handles.smtable.Visible='off';
    else
        handles.smtable.Data=smtable;
        handles.smtable.Visible='on';
    end
    
    % initiates smplot objects
    handles.smplot = patch(NaN,NaN,'w','parent',handles.ax1);
    for i=1:length(shape)
        x  = shape(i).Lon;
        y  = shape(i).Lat;
        isN = find(isnan(x));
        x(isN(1):end)=[];
        y(isN(1):end)=[];
        handles.smplot(i) = patch(x,y,'w','parent',handles.ax1);
        if shape(i).active==1
            set(handles.smplot(i),'visible','on','edgecolor','none','facecolor',[0.8 1 0.7]);
        else
            set(handles.smplot(i),'visible','off','edgecolor','none','facecolor',[0.8 1 0.7]);
        end
        
    end
    set(handles.ax1,'children',flipud(get(handles.ax1,'children')))
end

% Update handles structure
if ~isempty(varargin)
    plotsiteselect(handles)
end
akZoom(handles.ax1)
guidata(hObject, handles) ;
uiwait(handles.figure2);

function varargout = SelectLocations_OutputFcn(hObject, eventdata, handles)

if ~isfield(handles,'t')
    handout.id    = cell(0,1);
    handout.p     = zeros(0,3);
    handles.Vs30  = [];
    handout.t     = cell(0,2);
    handout.shape = [];
else
    handout.id      = handles.p.Data(:,1);
    handout.p       = cell2mat(handles.p.Data(:,2:4))*diag([1 1 1/1000]);
    handout.Vs30    = cell2mat(handles.p.Data(:,5));
    handout.t       = handles.t;
    handout.shape   = handles.shape;
    
end
varargout{1}    = handout;
varargout{2}    = handles.Vs30;
if isfield(handles,'index')
    varargout{3} = handles.index;
else
    varargout{3} = [];
end
delete(handles.figure2)

% ----------------- FILE MENU ---------------------------------------
function File_Callback(hObject, eventdata, handles)

function SaveMenu_Callback(hObject, eventdata, handles)

function Save2txt_Callback(hObject, eventdata, handles)
p = handles.p.Data;

[FileName,PathName,FILTERINDEX] =  uiputfile('*.txt','Sites');
if FILTERINDEX==0
    return
end
FNAME = [PathName,FileName];
fileID = fopen(FNAME,'w');
[row,col]=size(char(p(:,1)));
fprintf(fileID,'Site Selection Tool\n');
fprintf(fileID,'Sites %d\n',row);
for i=1:row
    fprintf(fileID,['%-',num2str(col),'s %-8.4f %-8.4f %-8.4f Vs30 %-8.4f\n'],p{i,1},p{i,2},p{i,3},p{i,4},p{i,5});
end
t = handles.t;
Ngrid = size(t,1);
fprintf(fileID,'\nGrids %d\n',Ngrid);
for i=1:Ngrid
    conn = handles.t{i,2};
    [vertices,nnodes] = size(conn);
    fprintf(fileID,'%s Vertices %g\n',t{i,1},vertices);
    str=[repmat('%4d ',1,nnodes),'\n'];
    for j=1:size(conn,1)
        fprintf(fileID,str,conn(j,:));
    end
end

shape  = handles.shape;
Nshape = length(shape);
fprintf(fileID,'ShapeFile : %-8s \n'  ,handles.shape1.String{1});
fprintf(fileID,'Shapes    : %-d \n',Nshape);
for i=1:Nshape
    fprintf(fileID,'\nGeometry %-d: %-s \n',i,shape(i).Geometry);
    fprintf(fileID,'BoundingBox: \n');
    fprintf(fileID,'%-7.4f %-7.4f \n',shape(i).BoundingBox');
    fprintf(fileID,'FID: %-d \n',     shape(i).FID);
    fprintf(fileID,'active: %-d \n',  shape(i).active);
end

fclose(fileID);

function Save2Shape_Callback(hObject, eventdata, handles)
[FileName,PathName,FILTERINDEX] =  uiputfile('*.shp','Sites');
if FILTERINDEX==0
    return
end
FNAME = [PathName,FileName];
Nsites = size(handles.p.Data,1);
SH(1:Nsites,1)=struct('ID',handles.p.Data(:,1),'Geometry','Multipoint','X',handles.p.Data(:,3),'Y',handles.p.Data(:,2),'Z',handles.p.Data(:,4),'Vs30',handles.p.Data(:,5));
shapewrite(SH,FNAME)

function Load_Callback(hObject, eventdata, handles)

if isfield(handles,'defaultpath_load')
    [filename, pathname,FILTERINDEX] = uigetfile(fullfile(handles.defaultpath_load,'*.txt;*.shp'),'select file');
else
    [filename, pathname,FILTERINDEX] = uigetfile(fullfile(pwd,'*.txt;*.shp'),'select file');
end
handles.defaultpath_load=pathname;
if FILTERINDEX==0
    return
end
[~,~,EXT] = fileparts(filename);
switch EXT
    case '.txt', handles = ss_readtxt(handles,filename,pathname);
    case '.shp', [handles.p.Data,handles.index] = shape_import(0,pathname,filename);
        plotsiteselect(handles)
        Ngrid     = 0;
        handles.t = cell(Ngrid,2);
end

guidata(hObject, handles);

function Reset_Callback(hObject, eventdata, handles)
handles=reset_all(handles);
guidata(hObject, handles);

function handles=reset_all(handles)
delete(findall(handles.ax1,'tag','siteplot'))
delete(findall(handles.figure2,'Tag','Colorbar'));

handles.gridplot.XData=[]; handles.gridplot.YData=[];
handles.siteclick.XData=[]; handles.siteclick.YData=[];
handles.latitude_single.String='';
handles.longitude_single.String='';
handles.elevation_single.String='';
handles.p.Data=cell(0,5);
handles.grid_data.Data=cell(0,3);

handles.grid_spacing.String='40';
handles.type_of_spacing.String='Max Spacing (km)';
handles.t     = cell(0,2);
handles.shape = cell(0,1);
delete(handles.smplot)
handles.smplot = patch(NaN,NaN,'w');
set(handles.smplot,'parent',handles.ax1,'visible','off');
set(handles.smtable,'data',cell(0,4),'visible','off');

function Exit_button_Callback(hObject, eventdata, handles)
close(handles.figure2)

function Exit_menu_Callback(hObject, eventdata, handles)
close(handles.figure2)

function figure2_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

% ----------------EDIT ----------------------------------------------------
function Edit_Callback(hObject, eventdata, handles)

function BuildDEM_Callback(hObject, eventdata, handles)

if ~exist('api_Key.mat','file')
    warndlg('You must use an API key to authenticate each request to Google Maps Platform APIs. For additional information, please refer to http://g.co/dev/maps-no-account')
    return
end

s  = listdlg('PromptString','Select a Grid or Path:',...
    'SelectionMode','single',...
    'ListString',handles.t(:,1));
if isempty(s)
    return
end
Data= handles.p.Data;
t   = handles.t;
vptr=regexp(Data(:,1),t{s,1});
for j=1:length(vptr)
    if isempty(vptr{j})
        vptr{j}=0;
    end
end
vptr     = cell2mat(vptr);
vertices = cell2mat(Data(vptr==1,[3,2,4]));
faces    = t{s,2};
elevation=vertices(:,3);
plotDEM(vertices,faces,elevation,handles.opt.ellipsoid);

function ElevModel_Callback(hObject, eventdata, handles)

if ~exist('api_Key.mat','file')
    warndlg('You must use an API key to authenticate each request to Google Maps Platform APIs. For additional information, please refer to http://g.co/dev/maps-no-account')
    return
end

oldModel = handles.ElevModel;
handles.ElevModel=OptionsElevation(handles.ElevModel);

if oldModel~=handles.ElevModel
    data=handles.p.Data;
    if ~isempty(data)
        choice = questdlg('Update site coordinates', ...
            'Elevation model', ...
            'Yes','No','Yes');
        if strcmp(choice,'Yes')
            
            if ispc
                a=system('ping -n 1 www.google.com');
            elseif isunix
                a=system('ping -c 1 www.google.com');
            end
            if a==1
                warndlg('No Internet Access found','Background');
                return
            end
            
            data=cell2mat(data(:,2:4));
            switch handles.ElevModel
                case 1
                    data(:,3)=0;
                case 2
                    Npoints = size(data,1);
                    if Npoints>400
                        GCP  = gcp;
                        NW   = GCP.NumWorkers;
                        ind  = round(linspace(1,Npoints,NW+1));
                        ind1 = ind(1:end-1);
                        ind2 = ind(2:end);ind2(1:NW-1)=ind2(1:NW-1)-1;
                        elev = cell(NW,1);
                        parfor i=1:NW
                            fprintf('%g\n',i)
                            II = ind1(i):ind2(i);
                            elev{i}=getElevations(data(II,1),data(II,2));
                        end
                        data(:,3)=vertcat(elev{:});
                    else
                        data(:,3)=getElevations(data(:,1),data(:,2));
                    end
            end
            handles.p.Data(:,4)=num2cell(data(:,3));
        end
    end
end

guidata(hObject,handles)

function GoogleEarthMaps_Callback(hObject, eventdata, handles)

handles.GoogleEarthOpt=GEOptions(handles.GoogleEarthOpt);
guidata(hObject, handles);

% PANEL 1: ADD SITE COORDINATES -----------------------------------------
function city_list_Callback(hObject, eventdata, handles)
str  = hObject.String;
val  = hObject.Value;

if val==1
    handles.site_id_single.String='';
    handles.latitude_single.String='';
    handles.longitude_single.String='';
    handles.elevation_single.String='';
else
    id   = str{val};
    gps  = handles.Ciudades(val-1,:);
    handles.site_id_single.String=id;
    handles.latitude_single.String=num2str(gps(1),6);
    handles.longitude_single.String=num2str(gps(2),6);
    
    
    switch handles.ElevModel
        case 1,handles.elevation_single.String='0';
        case 2,handles.elevation_single.String=num2str(gps(3),6);
    end
end
guidata(hObject, handles);

function site_id_single_Callback(hObject, eventdata, handles)

function latitude_single_Callback(hObject, eventdata, handles)

function longitude_single_Callback(hObject, eventdata, handles)

function elevation_single_Callback(hObject, eventdata, handles)

function Add_single_site_Callback(hObject, eventdata, handles)
id  = handles.site_id_single.String;
ch  = findall(handles.figure2,'tag','patchselect');delete(ch);
if isempty(id)
    snum = size(handles.p.Data,1);
    id   = ['site',num2str(snum+1)] ;
end

Lat  = handles.latitude_single.String;
Lon  = handles.longitude_single.String;
Elev = handles.elevation_single.String;

if isempty(Lat) || isempty(Lon)
    return
end

Lat  = str2double(Lat);
Lon  = str2double(Lon);
Elev = str2double(Elev);

if isnan(Lat) || isnan(Lon) || isnan(Elev)
    return
end

Vs30   = getVs30([Lat Lon],handles.Vs30);
p      = [handles.p.Data;{id,Lat,Lon,Elev,Vs30}];
handles.p.Data=p;

% Empties fields
handles.site_id_single.String   = [];
handles.latitude_single.String  = [];
handles.longitude_single.String = [];
handles.elevation_single.String = [];

% Plots sites
plotsiteselect(handles)
handles.siteclick.XData=NaN;
handles.siteclick.YData=NaN;
handles.siteclick.LineStyle='none';
guidata(hObject, handles);



% PANEL 2: ADD GRID -------------------------------------------------------
function grid_spacing_Callback(hObject, eventdata, handles)  %#ok<*DEFNU,*INUSD>
value = str2double(hObject.String);
if isnan(value) || value<=0
    hObject.String='40';
end
guidata(hObject,handles)

function draw_point_Callback(hObject, eventdata, handles)
XYLIM1 = get(handles.ax1,{'xlim','ylim'});
p      = grid2C(handles.ax1,'point');
set(p,'marker','o','markeredgecolor',[0      0.44706      0.74118],'markerfacecolor',[0      0.44706      0.74118],'markersize',3)
XYLIM2 = get(handles.ax1,{'xlim','ylim'});
set(handles.ax1,{'xlim','ylim'},XYLIM1);
akZoom(handles.ax1);
set(handles.ax1,{'xlim','ylim'},XYLIM2);
latlon = p.Vertices(:,[2,1]);

switch handles.ElevModel
    case 1, elev=zeros(size(latlon,1),1);
    case 2, elev=getElevations(latlon(:,1),latlon(:,2));
end

handles.latitude_single.String=num2str(latlon(1));
handles.longitude_single.String=num2str(latlon(2));
handles.elevation_single.String=num2str(elev);

guidata(hObject, handles);

function draw_line_Callback(hObject, eventdata, handles)
ch1=findall(handles.figure2,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
ch2=findall(handles.figure2,'type','uimenu','Enable','on'); set(ch2,'Enable','off');

XYLIM1 = get(handles.ax1,{'xlim','ylim'});
p      = grid2C(handles.ax1,'line');
XYLIM2 = get(handles.ax1,{'xlim','ylim'});
set(handles.ax1,{'xlim','ylim'},XYLIM1);
akZoom(handles.ax1);
set(handles.ax1,{'xlim','ylim'},XYLIM2);
latlon = get(p,'vertices');
latlon = latlon(:,[2,1]);


switch handles.ElevModel
    case 1, elev=zeros(size(latlon,1),1);
    case 2, elev=getElevations(latlon(:,1),latlon(:,2));
end
handles.grid_data.Data=num2cell([latlon,elev]);
set(ch1,'Enable','on')
set(ch2,'Enable','on')
guidata(hObject, handles);

function draw_square_Callback(hObject, eventdata, handles)

ch1=findall(handles.figure2,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
ch2=findall(handles.figure2,'type','uimenu','Enable','on'); set(ch2,'Enable','off');

XYLIM1 = get(handles.ax1,{'xlim','ylim'});
p      = grid2C(handles.ax1,'square');

XYLIM2 = get(handles.ax1,{'xlim','ylim'});
set(handles.ax1,{'xlim','ylim'},XYLIM1);
akZoom(handles.ax1);
set(handles.ax1,{'xlim','ylim'},XYLIM2);
latlon = p.Vertices(:,[2,1]);

switch handles.ElevModel
    case 1, elev=zeros(size(latlon,1),1);
    case 2, elev=getElevations(latlon(:,1),latlon(:,2));
end
handles.grid_data.Data=num2cell([latlon,elev]);
set(ch1,'Enable','on')
set(ch2,'Enable','on')
guidata(hObject, handles);

function draw_polygone_Callback(hObject, eventdata, handles) %#ok<*INUSL>
ch1=findall(handles.figure2,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
ch2=findall(handles.figure2,'type','uimenu','Enable','on'); set(ch2,'Enable','off');

p      = gridNC(handles.ax1,'polygone');
latlon = get(p,'vertices');
if size(latlon,1)<=1
    ch     = findall(handles.figure2,'tag','patchselect');delete(ch);
    return;
end
latlon = latlon(:,[2,1]);

switch handles.ElevModel
    case 1, elev=zeros(size(latlon,1),1);
    case 2, elev=getElevations(latlon(:,1),latlon(:,2));
end
handles.grid_data.Data=num2cell([latlon,elev]);
set(ch1,'Enable','on')
set(ch2,'Enable','on')
guidata(hObject, handles);

function draw_path_Callback(hObject, eventdata, handles)
ch1=findall(handles.figure2,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
ch2=findall(handles.figure2,'type','uimenu','Enable','on'); set(ch2,'Enable','off');

p      = gridNC(handles.ax1,'polyline');
latlon = [p.XData',p.YData'];
if size(latlon,1)<=1
    ch     = findall(handles.figure2,'tag','patchselect');delete(ch);
    return;
end
latlon = latlon(:,[2,1]);

switch handles.ElevModel
    case 1, elev=zeros(size(latlon,1),1);
    case 2, elev=getElevations(latlon(:,1),latlon(:,2));
end
handles.grid_data.Data=num2cell([latlon,elev]);
set(ch1,'Enable','on')
set(ch2,'Enable','on')
guidata(hObject, handles);

function DeleteG_Callback(hObject, eventdata, handles)
ch  = findall(handles.figure2,'tag','patchselect');delete(ch);
handles.grid_data.Data=cell(0,4);
guidata(hObject,handles)

function Add_grid_Callback(hObject, eventdata, handles)
ch = findall(handles.ax1,'tag','patchselect');delete(ch);
lmax = str2double(get(handles.grid_spacing,'string'));
data = handles.grid_data.Data;

if all(cell2mat(data(1,:))==cell2mat(data(end,:)))
    data(end,:)=[];
end

if isempty(data) || isempty(data{1})
    return
end
gps      = cell2mat(data);
Npoints  = size(gps,1);
pv       = gps*diag([1 1 0]);
if isempty(handles.opt.ellipsoid.Code)
    thmax = lmax;
else
    switch handles.type_of_spacing.String
        case 'Max Spacing (km)'
            mean_lat = mean(gps(:,1));
            thmax    = (lmax/EarthRadius(mean_lat,handles.opt.ellipsoid))*180/pi;
        case 'Max Spacing (deg)'
            thmax = lmax;
    end
end

switch Npoints
    case 2,    [gps,conn] = mesh_line(pv,thmax,0);
    case 4,    [gps,conn] = mesh_quad(pv,thmax,0);
    otherwise, [gps,conn] = mesh_tria(pv,thmax,0);
end

handles.t{end+1,2}=conn;
Npoints = size(gps,1);
Ngrid   = size(handles.t,1);
id      = ['grid_',num2str(Ngrid)];
handles.t{end,1}=id;
p = handles.p.Data;

if handles.opt.ellipsoid.Code~=0
    switch handles.ElevModel
        case 1 % do nothing
        case 2
            if Npoints>400
                GCP  = gcp;
                NW   = GCP.NumWorkers;
                ind  = round(linspace(1,Npoints,NW+1));
                ind1 = ind(1:end-1);
                ind2 = ind(2:end);ind2(1:NW-1)=ind2(1:NW-1)-1;
                elev = cell(NW,1);
                parfor i=1:NW
                    fprintf('%g\n',i)
                    II = ind1(i):ind2(i);
                    elev{i}=getElevations(gps(II,1),gps(II,2));
                end
                gps(:,3)=vertcat(elev{:});
            else
                gps(:,3)=getElevations(gps(:,1),gps(:,2));
            end
    end
end

p0=p;
p = cell(Npoints,5);
for i=1:Npoints
    p{i,1} = sprintf('%s-P%g',id,i);
end
p(:,2:4)= num2cell(gps);
p(:,5)  = num2cell(getVs30(gps(:,1:2),handles.Vs30));
handles.p.Data=[p0;p];
plotsiteselect(handles)
handles.grid_data.Data=cell(0,4);
handles.BuildDEM.Enable='on';
guidata(hObject, handles);

function Add_path_Callback(hObject, eventdata, handles)
ch = findall(handles.ax1,'tag','patchselect');delete(ch);
lmax = str2double(handles.grid_spacing.String);
data = handles.grid_data.Data;

if isempty(data) || isempty(data{1})
    return
end
gps      = cell2mat(data);
pv       = gps*diag([1 1 0]);

switch handles.opt.ellipsoid.Code
    case 0
        [gps,conn] = mesh_polyline(pv,lmax,0);
    otherwise
        switch handles.type_of_spacing.String
            case 'Max Spacing (km)'
                mean_lat = mean(gps(:,1));
                thmax    = (lmax/EarthRadius(mean_lat,handles.opt.ellipsoid))*180/pi;
            case 'Max Spacing (deg)'
                thmax = lmax;
        end
        [gps,conn] = mesh_polyline(pv,thmax,0);
end

handles.t{end+1,2}=conn;
Npoints = size(gps,1);
Ngrid   = size(handles.t,1);
id      = ['path_',num2str(Ngrid)];
handles.t{end,1}=id;
p = handles.p.Data;

if handles.opt.ellipsoid.Code~=0
    switch handles.ElevModel
        case 1
            % do nothing
        case 2
            if Npoints>400
                GCP  = gcp;
                NW   = GCP.NumWorkers;
                ind  = round(linspace(1,Npoints,NW+1));
                ind1 = ind(1:end-1);
                ind2 = ind(2:end);ind2(1:NW-1)=ind2(1:NW-1)-1;
                elev = cell(NW,1);
                parfor i=1:NW
                    fprintf('%g\n',i)
                    II = ind1(i):ind2(i);
                    elev{i}=getElevations(gps(II,1),gps(II,2))/1000;
                end
                gps(:,3)=vertcat(elev{:});
            else
                gps(:,3)=getElevations(gps(:,1),gps(:,2))/1000;
            end
    end
end

Vs30 = getVs30(gps(:,1:2),handles.Vs30);
for i=1:Npoints
    id_g = [id,'-P',num2str(i)];
    Lat  = gps(i,1);
    Lon  = gps(i,2);
    Elev = gps(i,3);
    Vs   = Vs30(i);
    p(end+1,:) = {id_g,Lat,Lon,Elev,Vs}; %#ok<AGROW>
end
handles.p.Data=p;
plotsiteselect(handles)
handles.gridplot.XData=[];
handles.gridplot.YData=[];
handles.grid_data.Data=cell(0,4);
handles.BuildDEM.Enable='on';
akZoom(handles.ax1)
guidata(hObject, handles);

% --------- CELL EDIT CALLBACKS ----------------------------------

function p_CellEditCallback(hObject, eventdata, handles)

data = handles.p.Data;

if isnan(eventdata.NewData)
    ind=eventdata.Indices;
    data{ind(1),ind(2)}=eventdata.PreviousData;
    handles.p.Data=data;
end
plotsiteselect(handles)
guidata(hObject, handles);

function grid_data_CellEditCallback(hObject, eventdata, handles)
data=handles.grid_data.Data;

if isnan(eventdata.NewData)
    ind=eventdata.Indices;
    data{ind(1),ind(2)}=eventdata.PreviousData;
    handles.grid_data.Data=data;
end

data = cell2mat(data);
data = data([1:end,1],:);
handles.gridplot.XData=data(:,2);
handles.gridplot.YData=data(:,1);
guidata(hObject, handles);

function shape1_Callback(hObject, eventdata, handles)
val   = hObject.Value;
str   = hObject.String{val};
ch     = findall(handles.ax1,'tag','shape1');
if isempty(ch)
    return
end
data  = shaperead(str, 'UseGeoCoords', true);
ch.XData=horzcat(data.Lon);
ch.YData=horzcat(data.Lat);
guidata(hObject,handles);

function shape2_Callback(hObject, eventdata, handles)

val   = hObject.Value;
str   = hObject.String{val};
ch    = findall(handles.ax1,'tag','shape2');
if isempty(ch)
    return
end
data  = shaperead(str, 'UseGeoCoords', true);
ch.XData=horzcat(data.Lon);
ch.YData=horzcat(data.Lat);
guidata(hObject,handles);

% --------------- SMART GRID SELECTION  -----------------------------
function SmartGrid_Callback(hObject, eventdata, handles)

function Createsmartgrid_Callback(hObject, eventdata, handles)
str = handles.shape1.String;
val = handles.shape1.Value;
handles.fname = str{val};
handles = create_shape_select(handles,handles.fname,handles.lmax);
guidata(hObject, handles);

function smtable_CellEditCallback(hObject, eventdata, handles)
data = handles.smtable.Data;

for i=1:size(data,1)
    ind = data{i,2};
    if ind==1
        handles.smplot(i).Visible='on';
        handles.shape(i).active=1;
    else
        handles.smplot(i).Visible='off';
        handles.shape(i).active=0;
    end
end
handles=create_mesh_select(handles);
if size(handles.t,1)>=1
    handles.BuildDEM.Enable='on';
else
    handles.BuildDEM.Enable='off';
end
guidata(hObject, handles);

% --------------- AUXILIARY  -----------------------------
function SmartMeshOpt_Callback(hObject, eventdata, handles)

prompt       = {'Maximum Node Spacing (km)'};
name         = 'Smart Grid Options';
defaultans   = {num2str(handles.lmax)};
answer       = inputdlg(prompt,name,[1,40],defaultans);
if isempty(answer)
    return
end
handles.lmax = str2double(answer{1});
if isempty(handles.shape)
    guidata(hObject, handles);
    return
end

handles=create_mesh_select(handles);
guidata(hObject, handles);

function smtable_CellSelectionCallback(hObject, eventdata, handles)

function smtable_ButtonDownFcn(hObject, eventdata, handles)

function po_Refresh_Callback(hObject, eventdata, handles)

if ~exist('api_Key.mat','file')
    warndlg('You must use an API key to authenticate each request to Google Maps Platform APIs. For additional information, please refer to http://g.co/dev/maps-no-account')
    return
end

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
plot_google_map(...
    'Axis',handles.ax1,...
    'Height',640,...
    'Width',640,...
    'Scale',2,...
    'MapType',opt.MapType,...
    'Alpha',opt.Alpha,...
    'ShowLabels',opt.ShowLabels,...
    'autoAxis',0,...
    'refresh',0,...
    'Color',opt.Color);
guidata(hObject,handles)

function Boundary_check_Callback(hObject, eventdata, handles)
ch=findall(handles.ax1,'tag','shape1'); if isempty(ch), return; end
switch hObject.Value
    case 0, ch.Visible='off';
    case 1, ch.Visible='on';
end

function show_terrain_Callback(hObject, eventdata, handles)
ch=findall(handles.ax1,'tag','gmap');
if length(ch)>1
    ch=ch(2);
end
switch hObject.Value
    case 0, ch.Visible='off';
    case 1, ch.Visible='on';
end

function type_of_spacing_ButtonDownFcn(hObject, eventdata, handles)
switch hObject.String
    case 'Max Spacing (km)'
        hObject.String='Max Spacing (deg)';
        handles.grid_spacing.String='0.5';
    case 'Max Spacing (deg)'
        hObject.String='Max Spacing (km)';
        handles.grid_spacing.String='40';
end

guidata(hObject,handles)

function smtable_KeyPressFcn(hObject, eventdata, handles)

function Layers_check_Callback(hObject, eventdata, handles)

ch=findall(handles.ax1,'tag','shape2'); if isempty(ch), return; end
switch hObject.Value
    case 0, ch.Visible='off';
    case 1, ch.Visible='on';
end

function ShapeLibrary_Callback(hObject, eventdata, handles)

handles.shape1.Value=1;
handles.shape2.Value=1;
[handles.opt.Image,handles.shape1.String,handles.shape2.String,handles.defaultpaths]=SelectLocationOptions(handles.defaultpaths,handles.opt);
handles.opt.Boundary = handles.shape1.String{1};
handles.opt.Layer    = handles.shape2.String{1};
default_maps(handles,handles.ax1);
guidata(hObject,handles)

function gr_Callback(hObject, eventdata, handles)

switch handles.ax1.XGrid
    case 'off', handles.ax1.XGrid='on'; handles.ax1.YGrid='on';
    case 'on',  handles.ax1.XGrid='off';handles.ax1.YGrid='off';
end

function city_list_ButtonDownFcn(hObject, eventdata, handles)

W=what('platform_cities');
[fname,pathname,FILTERINDEX]=uigetfile([W.path,'\*.txt']);
if FILTERINDEX==0, return; end
fid = fopen([pathname,fname]);
str        = cell(0,1);
LatLonElev = zeros(0,3);
newline = fgetl(fid);
while newline~=-1
    linea        = regexp(deblank(newline),'\s+','split');
    str{end+1,1} = strjoin(linea(1:end-3),' '); %#ok<AGROW>
    Lat        = str2double(linea{end-2});
    Lon        = str2double(linea{end-1});
    Elev       = str2double(linea{end-0});
    LatLonElev(end+1,:)  = [Lat,Lon,Elev]; %#ok<AGROW>
    newline    = fgetl(fid);
end

hObject.Value=1;
hObject.String=['...';str];
handles.Ciudades=LatLonElev;
guidata(hObject,handles)

function Distance_button_Callback(hObject, eventdata, handles)

ch1=findall(handles.ax1,'tag','patchselect');
ch2=findall(handles.ax1,'tag','patchtxt');
if isempty(ch1) && isempty(ch2)
    ch1=findall(handles.figure2,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
    ch2=findall(handles.figure2,'type','uimenu','Enable','on'); set(ch2,'Enable','off');
    
    XYLIM1 = get(handles.ax1,{'xlim','ylim'});
    if isempty(handles.opt.ellipsoid.Code)
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

function DeleteSites_Callback(hObject, eventdata, handles)

ind1=strfind(handles.p.Data(:,1),'grid_');
ind2=strfind(handles.p.Data(:,1),'path_');
for i=1:length(ind1)
    if isempty(ind1{i})
        ind1{i}=0;
    else
        ind1{i}=1;
    end
    if isempty(ind2{i})
        ind2{i}=0;
    else
        ind2{i}=1;
    end
end
ind1 = cell2mat(ind1)==1;
ind2 = cell2mat(ind2)==1;
ind  = (ind1+ind2)==0;
handles.p.Data(ind,:)=[];
plotsiteselect(handles)
guidata(hObject,handles)

function DeleteGrids_Callback(hObject, eventdata, handles)

handles.t=cell(0,2);
ind=strfind(handles.p.Data(:,1),'grid_');
if isempty(ind),return,end
for i=1:length(ind)
    if isempty(ind{i})
        ind{i}=0;
    else
        ind{i}=1;
    end
end
ind = cell2mat(ind)==1;
handles.p.Data(ind,:)=[];
plotsiteselect(handles)
guidata(hObject,handles)

function DeletePaths_Callback(hObject, eventdata, handles)

handles.t=cell(0,2);
ind=strfind(handles.p.Data(:,1),'path_');
if isempty(ind),return,end
for i=1:length(ind)
    if isempty(ind{i})
        ind{i}=0;
    else
        ind{i}=1;
    end
end
ind = cell2mat(ind)==1;
handles.p.Data(ind,:)=[];
plotsiteselect(handles)
guidata(hObject,handles)

function Vs30autofill_Callback(hObject, eventdata, handles)

handles.Vs30 = Vs30Source(handles.Vs30);
plotVs30sources(handles)

if ~isempty(handles.p.Data)
    answer   = inputdlg('Update All Vs30 (Y/N)','Vs30',[1,40],{'Y'});
    if isempty(answer)
        return
    end
    if strcmpi(answer{1},'Y')
        data = cell2mat(handles.p.Data(:,2:5));
        data(:,4)=getVs30(data(:,1:2),handles.Vs30);
        handles.p.Data(:,2:5)=num2cell(data);
        plotsiteselect(handles)
    end
end
guidata(hObject,handles)

function Microzonation_Callback(hObject, eventdata, handles)

ch = findall(handles.ax1,'tag','microzone');
if ~isempty(ch)
    switch hObject.Value
        case 0,set(ch,'Visible','off')
        case 1,set(ch,'Visible','on')
    end
end

function Vs30rasters_Callback(hObject, eventdata, handles)

ch = findall(handles.ax1,'tag','raster');
if ~isempty(ch)
    switch hObject.Value
        case 0,set(ch,'Visible','off')
        case 1,set(ch,'Visible','on')
    end
end
