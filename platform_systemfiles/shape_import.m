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
handles.exittype = 1;
fname = fullfile(varargin{2},varargin{3});
handles.info     = shapeinfo(fname);
attr             = {'',handles.info.Attributes.Name};
ind1 = ismember(lower(attr),{'id','name','label','tag'});          ind1 = find(ind1);
ind2 = ismember(lower(attr),{'elevation','elev','elevacion','z'}); ind2 = find(ind2);
ind3 = ismember(lower(attr),{'vs30','vs_30','vs'});                ind3 = find(ind3);

if isempty(ind1),ind1=1;end; handles.pop1.String=attr; handles.pop1.Value=ind1;
if isempty(ind2),ind2=1;end; handles.pop2.String=attr; handles.pop2.Value=ind2;
if isempty(ind3),ind3=1;end; handles.pop3.String=attr; handles.pop3.Value=ind3;

Nfeatures = handles.info.NumFeatures;
handles.ShapeType.String   = sprintf('%s',handles.info.ShapeType);
handles.NumFeatures.String = sprintf('%i',Nfeatures);
handles.NumClusters.String = sprintf('%i',min(round(0.1*Nfeatures),1000));

xlabel(handles.ax1,'Lon')
ylabel(handles.ax1,'Lat')

% raw data from shapefile
handles.id   = [];
handles.X    = [];
handles.Y    = [];
handles.Z    = [];
handles.Vs30 = [];

% clustered data from
handles.idc   = [];
handles.Xc    = [];
handles.Yc    = [];
handles.Zc    = [];
handles.Vs30c = [];

handles=DisplayShape(handles,fname);

akZoom(handles.ax1)
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = shape_import_OutputFcn(hObject, eventdata, handles)
varargout{1}=[]; %ID
varargout{2}=[]; %Lat,Lon,Elev,Vs30
varargout{3}=[]; %index

if handles.exittype==1
    varargout{1}=[handles.id,num2cell([handles.Y,handles.X,handles.Z,handles.Vs30])];
    varargout{2}=[];
end

if handles.exittype==2
    varargout{1}=[handles.idc,num2cell([handles.Yc,handles.Xc,handles.Zc,handles.Vs30c])];
    varargout{2}=handles.index;
end

delete(handles.figure1)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function pop1_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function pop2_Callback(hObject, eventdata, handles)

function pop3_Callback(hObject, eventdata, handles)

function ShapeType_Callback(hObject, eventdata, handles)

function NumFeatures_Callback(hObject, eventdata, handles)

function NumClusters_Callback(hObject, eventdata, handles)

function handles=DisplayShape(handles,fname)

data      = shaperead(fname);
Nfeatures = handles.info.NumFeatures;

% site id
handles.id = {data.ID}';

% lat long
if isfield(data,'X') && isfield(data,'Y')
    handles.X = horzcat(data.X)';
    handles.Y = horzcat(data.Y)';
end
if isfield(data,'Lat') && isfield(data,'Lon')
    handles.X = horzcat(data.Lon)';
    handles.Y = horzcat(data.Lat)';
end

% elevation
if handles.pop2.Value>1
    str       = handles.pop2.String{handles.pop2.Value};
    handles.Z = horzcat(data.(str))'; % in m
else
    handles.Z = zeros(length(handles.X),1);
end

% Vs30
if handles.pop3.Value>1
    str = handles.pop3.String{handles.pop3.Value};
    handles.Vs30 = horzcat(data.(str))';
    handles.Vs30 = idwm(handles.Vs30,handles.X,handles.Y);
else
    handles.Vs30 = zeros(length(handles.X),1);
end

% plot section
if strcmpi(handles.ShapeType.String,'PolyLine')
    data  = zeros(Nfeatures,4);
    ISNAN =[0;find(isnan(handles.X))];
    for j=1:Nfeatures
        xj = handles.X(ISNAN(j)+1:ISNAN(j+1)-1);
        yj = handles.Y(ISNAN(j)+1:ISNAN(j+1)-1);
        zj = handles.Z(ISNAN(j)+1:ISNAN(j+1)-1);
        vj = handles.Vs30(ISNAN(j)+1:ISNAN(j+1)-1);
        data(j,:)=mean([xj,yj,zj,vj],1);
    end
    handles.X    = data(:,1);
    handles.Y    = data(:,2);
    handles.Z    = data(:,3);
    handles.Vs30 = data(:,4);
    
end
delete(findall(handles.ax1,'type','patch'));
handles.ax1.ColorOrderIndex=1;
patch('parent',handles.ax1,...
    'vertices',[handles.X,handles.Y],...
    'faces',1:Nfeatures,...
    'facecolor','none',...
    'marker','o',...
    'markersize',3,...
    'markerfacecolor',[1 1 1],...
    'linestyle','none',...
    'edgecolor',[0 0.4470 0.7410],...
    'tag','XY')
handles.ax1.Layer='top';
setTickLabel(handles.ax1)

function RunButton_Callback(hObject, eventdata, handles)
handles.push2.Enable='on';
options = statset('UseParallel',1);

Nclusters = str2double(handles.NumClusters.String);
if handles.pop3.Value>1
    [handles.index,data]=kmeans([handles.X,handles.Y,handles.Vs30],Nclusters,'Options',options,'MaxIter',10000,'Display','off','Replicates',1);
else
    [handles.index,data]=kmeans([handles.X,handles.Y],Nclusters,'Options',options,'MaxIter',10000,'Display','off','Replicates',1);
end

delete(findall(handles.ax1,'tag','XYc'));
handles.ax1.ColorOrderIndex=2;
handles.idc   = compose('node%i',(1:Nclusters)');
handles.Xc    = data(:,1);
handles.Yc    = data(:,2);
handles.Zc    = zeros(Nclusters,1);
handles.Vs30c = zeros(Nclusters,1);

if handles.pop2.Value>1
    for i=1:Nclusters
        ind = handles.index==i;
        handles.Zc(i)=mean(handles.Z(ind));
    end
end

if handles.pop3.Value>1
    handles.Vs30c = data(:,3);
end

patch('parent',handles.ax1,...
    'vertices',[handles.Xc,handles.Yc],...
    'faces',1:length(handles.Xc),...
    'facecolor','none',...
    'marker','o',...
    'markersize',3,...
    'markerfacecolor',[1 1 1],...
    'linestyle','none',...
    'edgecolor',[0.8500    0.3250    0.0980],...
    'tag','XYc')

guidata(hObject,handles)

function push1_Callback(hObject, eventdata, handles)
handles.exittype = 1;
guidata(hObject,handles)
close(handles.figure1)

function push2_Callback(hObject, eventdata, handles)
handles.exittype = 2;
guidata(hObject,handles)
close(handles.figure1)

function push3_Callback(hObject, eventdata, handles)
handles.exittype = 3;
guidata(hObject,handles)
close(handles.figure1)

function Vs30 = idwm(Vs30,X,Y)

ind = find((Vs30<0));
for i=1:length(ind)
    ii=ind(i);
    [d,pos] = sort((X(ii)-X).^2+(Y(ii)-Y).^2);
    d(1)=[];
    pos(1)=[];
    vs=Vs30(pos);
    d(vs<0)=[];
    vs(vs<0)=[];
    w  = 1./d(1:10);
    vs = vs(1:10);
    Vs30(ii) = w'*vs/sum(w);
end
