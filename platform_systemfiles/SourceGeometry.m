function varargout = SourceGeometry(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SourceGeometry_OpeningFcn, ...
    'gui_OutputFcn',  @SourceGeometry_OutputFcn, ...
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

function SourceGeometry_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output    = hObject;
ihandles          = varargin{1};

icon = double(imread('exit.jpg'))/255; set(handles.Exit_button,   'CData',icon);
icon = double(imresize(imread('Closed_Lock.jpg')  ,0.7))/255; set(handles.Unlock  , 'CData',icon);
icon = double(imresize(imread('Ruler.jpg'),[16 16]))/255;     set(handles.setXYLimits,'CData',icon);

handles.opt       = ihandles.opt;
handles.model     = ihandles.model;
handles.sys       = ihandles.sys;
handles.ax1=copyobj(ihandles.ax1, handles.figure1);

delete(findall(handles.ax1,'tag','siteplot'));
delete(findall(handles.ax1,'tag','areas'));
delete(findall(handles.ax1,'tag','lines'));
delete(findall(handles.ax1,'tag','points'));

if isempty(handles.opt.ellipsoid.Code)
    xlabel(handles.ax1,'X (km)','fontsize',8,'fontname','arial');
    ylabel(handles.ax1,'Y (km)','fontsize',8,'fontname','arial')
    handles.tabla.ColumnName(1:2)={'Y(km)';'X(km)'};
else
    xlabel(handles.ax1,'Lon','fontsize',8,'fontname','arial');
    ylabel(handles.ax1,'Lat','fontsize',8,'fontname','arial')
    handles.tabla.ColumnName(1:3)={'Lat';'Lon';'Depth'};
end

[~,geomlist] = unique(handles.sys.BRANCH(:,1));
set(handles.source_pop,'string',{handles.model(geomlist).id1}','value',1,'enable','on')
model = handles.model(geomlist);
set(handles.source_list,'string',{model(1).source.label}','value',1,'enable','on');

handles.tabla.Data=num2cell(model(1).source(1).vertices);
handles.model = model;
plotsources(handles);
source_param(handles);
akZoom(handles.ax1);

view(handles.ax2,[34 40])
% rotate3d(handles.ax2); % rhis line creates congflict with akZoom on ax1
guidata(hObject, handles);
grid(handles.ax2,'off');
uiwait(handles.figure1);

function varargout = SourceGeometry_OutputFcn(hObject, eventdata, handles)

varargout{1}=[];
delete(handles.figure1)

function source_pop_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
ch = findall(handles.ax1,'Tag','sourcepoint');delete(ch);
val = get(hObject,'value');
model = handles.model;
set(handles.source_list,'string',{model(val).source.label}','enable','on','value',1);
plotsources(handles);
source_param(handles);
guidata(hObject, handles);

function source_pop_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function source_list_Callback(hObject, eventdata, handles)
plotsources(handles);
source_param(handles);
guidata(hObject, handles);

function source_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Exit_button_Callback(hObject, eventdata, handles)
close(handles.figure1)

function Exit_Callback(hObject, eventdata, handles)
close(handles.figure1);

function plotsources(handles)
facecolor  = [0.8 0.6 0.6];
edgecolor  = [1 0.6 0.6];
delete(findall(handles.ax1,'Tag','Sources'));
delete(findall(handles.ax2,'Tag','Sources'));
pop   = get(handles.source_pop,'value');
val   = get(handles.source_list,'value');
model = handles.model(pop);

vertices = model.source(val).vertices;
if size(model.source(val).geom.conn,2)>2
    patch('parent',handles.ax1,...
        'vertices',vertices(:,[2,1]),...
        'faces',1:size(vertices,1),...
        'facecolor',facecolor,...
        'edgecol',edgecolor,...
        'facealpha',0.5,...
        'tag','Sources',...
        'visible','on');
end
xlabel(handles.ax2,'Lon°','fontsize',10);
ylabel(handles.ax2,'Lat°','fontsize',10);
zlabel(handles.ax2,'z (km)','fontsize',10);


Area  = model.source(val).geom.Area;
Lchar = sqrt(Area);
zscale = max(Lchar,100);
handles.ax2.DataAspectRatio = [1 1 zscale];

%vert  = vertices(:,[2,1,3]);
vert   = xyz2gps(model.source(val).geom.xyzm,handles.opt.ellipsoid);vert=vert(:,[2,1,3]);

handles.ax2.NextPlot='add';
axis(handles.ax2,'auto');

patch('parent',handles.ax2,...
    'vertices',vert,...
    'faces',model.source(val).geom.conn,...
    'facecolor',facecolor,...
    'edgecol',edgecolor,...
    'facealpha',0.5,...
    'tag','Sources',...
    'visible','on');

handles.ax2.Layer='top';
vertices = zeros(0,3);NAN3 = NaN(1,3);
for j=1:length(model.source)
    vertices_j =model.source(j).vertices;
    vertices =[vertices;vertices_j;vertices_j(1,:);NAN3]; %#ok<AGROW>
end
conn = 1:size(vertices,1);
patch('parent',handles.ax1,...
    'vertices',vertices(:,[2,1]),...
    'faces',conn,...
    'facecolor','none',...
    'edgecol',edgecolor,...
    'tag','Sources',...
    'visible','on');

axis(handles.ax2,'auto');

function source_param(handles)
pop   = get(handles.source_pop,'value');
val   = get(handles.source_list,'value');
source = handles.model(pop).source;
set(handles.tabla,'data',source(val).vertices);

function tabla_CellSelectionCallback(hObject, eventdata, handles)
delete(findall(handles.ax1,'Tag','sourcepoint'));
delete(findall(handles.ax2,'Tag','sourcepoint'));
if isempty(eventdata.Indices)
    return
end
vertices = get(hObject,'data');
ind = eventdata.Indices(1);
plot(handles.ax1,vertices(ind,2),vertices(ind,1),'ko','markersize',5,'Tag','sourcepoint','markerfacecolor',[0.85 0.325 0.098]);

handles.ax2.NextPlot='add';
plot3(handles.ax2,vertices(ind,2),vertices(ind,1),vertices(ind,3),'ko','markersize',5,'Tag','sourcepoint','markerfacecolor',[0.85 0.325 0.098]);
guidata(hObject, handles);

function Unlock_Callback(hObject, eventdata, handles)
return % temporarily disbled

% switch get(hObject,'TooltipString')
%     case 'Unlocked'
%         set(hObject,'TooltipString','Locked')
%         icon2 = double(imresize(imread('Closed_Lock.jpg')  ,0.7))/255; set(handles.Unlock  , 'CData',icon2);
%         col = [    1.0000    1.0000    1.0000;0.9608    0.9608    0.9608];
%         set(handles.tabla,'ColumnEditable',false(1,3),'backgroundcolor',col)
%         set(handles.source_list,'enable','on')
%         set(handles.source_pop,'enable','on')
%     case 'Locked'
%         set(hObject,'TooltipString','Unlocked')
%         icon2 = double(imresize(imread('Open_Lock.jpg')  ,0.7))/255; set(handles.Unlock  , 'CData',icon2);
%         col = [1 1 0.7];
%         set(handles.tabla,'ColumnEditable',true(1,3),'backgroundcolor',col)
%         set(handles.source_list,'enable','off')
%         set(handles.source_pop,'enable','off')
% end
% guidata(hObject, handles);

function tabla_CellEditCallback(hObject, eventdata, handles)

% store changes
pop   = get(handles.source_pop,'value'); val   = get(handles.source_list,'value');
handles.model(pop).source(val).vertices=get(handles.tabla,'data');
plotsources(handles);

ch=findall(handles.ax1,'Tag','sourcepoint');
vertices = get(hObject,'data');
ind = eventdata.Indices;
ch.XData=vertices(ind(1),2);
ch.YData=vertices(ind(1),1);

ch=findall(handles.ax2,'Tag','sourcepoint');
ch.XData=vertices(ind(1),2);
ch.YData=vertices(ind(1),1);
ch.ZData=vertices(ind(1),3);

guidata(hObject,handles)

function [Vertices,Faces]=vertcat2(sources,Code)

Vertices = zeros(0,3);
for i=1:length(sources)
    Vertices=[Vertices;sources(i).vertices;nan(1,3)]; %#ok<AGROW>
end
Faces = 1:size(Vertices,1);

if Code==0
    Vertices=Vertices(:,[2,1]);
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function setXYLimits_Callback(hObject, eventdata, handles)
akZoom(handles.ax1)
guidata(hObject,handles)

function File_Callback(hObject, eventdata, handles)

function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)

switch eventdata.NewValue.String
    case 'Plan View', view(handles.ax2,[0 90]); rotate3d(handles.ax2,'off')
    case 'N-S'  ,     view(handles.ax2,[0 0]) ; rotate3d(handles.ax2,'off')
    case 'E-W'  ,     view(handles.ax2,[90 0]); rotate3d(handles.ax2,'off')
    case '3D'   ,     view(handles.ax2,[34 40]);rotate3d(handles.ax2,'on')
end

function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
