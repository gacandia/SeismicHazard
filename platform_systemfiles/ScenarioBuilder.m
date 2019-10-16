function varargout = ScenarioBuilder(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ScenarioBuilder_OpeningFcn, ...
    'gui_OutputFcn',  @ScenarioBuilder_OutputFcn, ...
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

function ScenarioBuilder_OpeningFcn(hObject, eventdata, handles, varargin)

load All_Scenario_Buttons %#ok<LOAD>
handles.Undock.CData            = Undockbutton;
handles.sumbutton.CData         = sumbuttonbutton;
handles.ExitButton.CData        = ExitButtonbutton;
handles.plotTessel.CData        = plotTesselbutton;
handles.GridManager.CData       = GridManagerbutton;
handles.ShowNodes.CData         = ShowNodesbutton;
handles.AddNewScenario.CData    = AddNewScenariobutton;
handles.DeleteButton.CData      = DeleteButtonbutton;
handles.DiscretizeMButton.CData = DiscretizeMButtonbutton;
handles.DiscretizeRButton.CData = DiscretizeRButtonbutton; 
handles.SortButton.CData        = SortButtonbutton;
handles.Ruler.CData             = Rulerbutton;
handles.invokeWiz.CData         = invokeWizbutton;
handles.output = hObject;

handles.sys     = varargin{1};
model           = varargin{2};
handles.opt     = varargin{3};
handles.t.Data  = varargin{4};
handles.tessel  = varargin{5};

% Simplify Polygons
for i=1:length(model)
    for j=1:length(model(i).source)
        p = model(i).source(j).geom.p;
        [lat,lon]=reducem(p(:,1),p(:,2));
        model(i).source(j).geom.p=[lat,lon];
    end
end
handles.model=model;

handles.sumtxt.String='Sum =       Count = ';
datasource = handles.model(1).source(1).datasource;

if ~isempty(datasource) && contains(datasource,'.mat')
    handles.mesh = 0; %user defined
    xlabel(handles.ax1,'Latitude')
    ylabel(handles.ax1,'Longitude')
    handles.t.ColumnName{7}='Lat';
    handles.t.ColumnName{8}='Lon';
else
    handles.mesh = 1; %auto
    xlabel(handles.ax1,'X(km)')
    ylabel(handles.ax1,'Y(km)')    
end

set(handles.ax1,'nextplot','add','box','on','dataaspectratio',[1 1 1]);
axis(handles.ax1,'equal');
axis(handles.ax1,'auto');
handles.ax1.XGrid='on';
handles.ax1.YGrid='on';
handles.current=[];

handles.voroni  = plot(handles.ax1,nan,nan,'color',[1 1 1]*0.76,'tag','voroni','vis','on');
handles.voroni2 = plot(handles.ax1,nan,nan,'color',[0 0.2 1],'tag','voroni','vis','on');
handles.area    = patch('parent',handles.ax1,'faces',[],'vertices',[],'facecolor',[0.8 0.6 0.6],'facealpha',0.5,'tag','area');
handles.RA      = patch('parent',handles.ax1,'faces',[],'vertices',[],'facecolor',[0.7 0.7 0.7],'facealpha',0.5,'tag','RA');
handles.meshR   = plot(handles.ax1,nan,nan,'+','markeredgecolor',[0.85 0.325 0.098],'tag','meshR','visible','on','markersize',6);
handles.hyp     = plot(handles.ax1,nan,nan,'ks','tag','area','visible','on','markersize',6,'markerfacecolor','r');

% POPULATE TABLE WITH DATA
Nbranch = length(handles.model);
Nbr=1:Nbranch;
handles.t.ColumnFormat{1} = sprintfc('%d',Nbr);
handles.t.ColumnFormat{2} = {model(1).source.label};
if ~isempty(handles.t.Data)
    handles.current=[1 1];
    mlib = handles.t.ColumnFormat{1};
    [~,ptr1] = intersect(mlib,handles.t.Data{1,1});
    handles.t.ColumnFormat{2}={handles.model(ptr1).source.label};
    slib = handles.t.ColumnFormat{2};
    [~,ptr2] = intersect(slib,handles.t.Data{1,2});
    source   = handles.model(ptr1).source(ptr2);
    DataR    = handles.t.Data(1,:);
    vorR     = handles.tessel{1,2};
    sSCEN_plotSource(handles,source,DataR,vorR);
    
else
    handles.t.Data = cell(1,12);
    handles.tessel = {[],zeros(0,2)};
end

akZoom(handles.ax1);

guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = ScenarioBuilder_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>

Data = handles.t.Data;
ind = [];
for i=1:size(Data,1)
    if isempty(Data{i,1})
        ind = [ind;i]; %#ok<*AGROW>
    end
end
Data(ind,:)=[];
varargout{1} = Data;
varargout{2} = handles.tessel;

delete(handles.figure1)

function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<*INUSD>
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

% ---------------- FILE MENU ---------------------------------------------
function File_Callback(hObject, eventdata, handles)

function Reset_Callback(hObject, eventdata, handles)
handles.sumtxt.String='Sum =       Count = ';
handles.current = [];
handles.t.Data  = cell(1,12);
handles.tessel  = {[],zeros(0,2)};
set(handles.voroni ,'XData',nan,'YData',nan);
set(handles.voroni2,'XData',nan,'YData',nan);
set(handles.area   ,'XData',nan,'YData',nan);
set(handles.RA     ,'XData',nan,'YData',nan);
set(handles.meshR  ,'XData',nan,'YData',nan);
set(handles.hyp    ,'XData',nan,'YData',nan);
clc
guidata(hObject,handles);

function Import_Callback(hObject, eventdata, handles)

function Exit_Callback(hObject, eventdata, handles)
close(handles.figure1)

function ExitButton_Callback(hObject, eventdata, handles)
close(handles.figure1)

% ------------ MANAGE SCENARIOS  -----------------------------------------

function ManageScenarios_Callback(hObject, eventdata, handles)

function AddNew_Callback(hObject, eventdata, handles)
handles=sSCENaddnew(handles);
guidata(hObject,handles);

function AddNewScenario_Callback(hObject, eventdata, handles)
handles=sSCENaddnew(handles);
guidata(hObject,handles);

function DeleteSelection_Callback(hObject, eventdata, handles)
handles=sSCEN_delete(handles);
guidata(hObject,handles);

function DeleteButton_Callback(hObject, eventdata, handles)
handles=sSCEN_delete(handles);
guidata(hObject,handles);

function DuplicateSelection_Callback(hObject, eventdata, handles)
current = handles.current;
if isempty(current),return;end

duplicate = handles.t.Data(current(1),:);
handles.t.Data(end+1,:)=duplicate;

duplicate = handles.tessel(current(1),:);
handles.tessel(end+1,:)=duplicate;

guidata(hObject,handles);

function DiscretizeMButton_Callback(hObject, eventdata, handles)
if isempty(handles.t.Data) || isempty(handles.current)
    return
end
handles=sSCEN_discM(handles);
guidata(hObject,handles);

function DiscretizeRButton_Callback(hObject, eventdata, handles)
if isempty(handles.t.Data) || isempty(handles.current)
    return
end
% ---------- this section will change ------------------------
current   = handles.current(:,1);
[~,inds]  = unique(cell2mat(handles.t.Data(current,2)),'rows');
unkdata   = handles.t.Data(current(inds),2);
[~,ptr1]  = intersect({handles.model(1).source.label},unkdata);

switch handles.mesh
    case 0
        answer=inputdlg({'Percentage of subareas used'},'Source Discretization',[1,50],{sprintf('%g',50)});
    case 1
        spacing = handles.model(1).source(ptr1(1)).rupt.spacing;
        answer=inputdlg({'Max. Distance Between Areas (km)'},'Source Discretization',[1,50],{sprintf('%g',spacing)});
end
if isempty(answer)
    return
end

spacing= str2double(answer{1});
% -----------------------------------------------------------

handles=sSCEN_discR(handles,spacing);

row      = handles.current(1);
DataR    = handles.t.Data(row,:);
vorR     = handles.tessel{row,2};
mlib     = handles.t.ColumnFormat{1};
[~,ptr1] = intersect(mlib,DataR{1});
slib     = handles.t.ColumnFormat{2};
[~,ptr2] = intersect(slib,DataR{2});
source   = handles.model(ptr1).source(ptr2);
sSCEN_plotSource(handles,source,DataR,vorR);
guidata(hObject,handles);

function ShowNodes_Callback(hObject, eventdata, handles)

switch handles.meshR.Visible
    case 'on'  , handles.meshR.Visible='off'; handles.voroni.Visible='off'; handles.voroni2.Visible='off';
    case 'off' , handles.meshR.Visible='on';  handles.voroni.Visible='on';  handles.voroni2.Visible='on';
end

function plotTessel_Callback(hObject, eventdata, handles)

switch handles.voroni.Visible
    case 'on'  , handles.voroni.Visible='off';handles.voroni2.Visible='off';
    case 'off' , handles.voroni.Visible='on'; handles.voroni2.Visible='on';
end

function SortButton_Callback(hObject, eventdata, handles)

rate = cell2mat(handles.t.Data(:,10:12));
rate = prod(rate,2);
[~,ind] = sort(rate,'descend');
handles.t.Data=handles.t.Data(ind,:);
handles.tessel=handles.tessel(ind,:);
guidata(hObject,handles)

function GridManager_Callback(hObject, eventdata, handles)
xg = handles.ax1.XGrid;
switch xg
    case 'on' , handles.ax1.XGrid='off';handles.ax1.YGrid='off';
    case 'off', handles.ax1.XGrid='on';handles.ax1.YGrid='on';
end

% ------------- OPTIONS MENU ----------------------------------------------

function Options_Callback(hObject, eventdata, handles)

function MSamplingMethod_Callback(hObject, eventdata, handles)

function UniformBins_Callback(hObject, eventdata, handles)

switch hObject.Checked
    case 'on' , hObject.Checked='off'; handles.GaussianSampling.Checked='on'; handles.ImportantSampling.Checked='off';
    case 'off', hObject.Checked='on';  handles.GaussianSampling.Checked='off'; handles.ImportantSampling.Checked='off';
end
guidata(hObject,handles)

function GaussianSampling_Callback(hObject, eventdata, handles)
switch hObject.Checked
    case 'on' , hObject.Checked='off'; handles.UniformBins.Checked='off'; handles.ImportantSampling.Checked='on';
    case 'off', hObject.Checked='on'; handles.UniformBins.Checked='off'; handles.ImportantSampling.Checked='off';
end

function ImportantSampling_Callback(hObject, eventdata, handles)

switch hObject.Checked
    case 'on' , hObject.Checked='off'; handles.UniformBins.Checked='on'; handles.GaussianSampling.Checked='off';
    case 'off', hObject.Checked='on'; handles.UniformBins.Checked='off'; handles.GaussianSampling.Checked='off';
end
guidata(hObject,handles)

% ------------- TABLE EDIT ------------------------------------------------
function t_CellEditCallback(hObject, eventdata, handles) %#ok<*DEFNU>
row     = eventdata.Indices(1);
col     = eventdata.Indices(2);
handles.current=eventdata.Indices;
handles.current
if col==1 % Select Model
    mlib = handles.t.ColumnFormat{1};
    [~,ptr1] = intersect(mlib,handles.t.Data{row,1});
    source  = handles.model(ptr1).source;
    handles.t.ColumnFormat{2}={source.label};
    handles.t.Data{row,2}=source(1).label;
    source = source(1);
    handles.t.Data{row,3}=func2str(source.gmpe.handle);
    handles.t.Data{row,4}=func2str(source.mscl.handle);
    handles.t.Data{row,5}=source.rupt.type;
    handles.t.Data{row,6}=7;
    switch handles.mesh
        case 0
            handles.t.Data{row,7}=source.vertices(1,1);
            handles.t.Data{row,8}=source.vertices(1,2);
        case 1
            handles.t.Data{row,7}=0;
            handles.t.Data{row,8}=0;
    end
    handles.t.Data{row,9}='No';
    handles.t.Data{row,10}=source.mscl.msparam.NMmin;
    handles.t.Data{row,11}=[];
    handles.t.Data{row,12}=[];
end

if col==2 % Select Source
    mlib = handles.t.ColumnFormat{1};
    [~,ptr1] = intersect(mlib,handles.t.Data{row,1});
    if isempty(ptr1)
        handles.t.Data{row,2}=eventdata.PreviousData;
        guidata(hObject,handles)
        return
    end
    slib = handles.t.ColumnFormat{2};
    [~,ptr2] = intersect(slib,handles.t.Data{row,2});
    source  = handles.model(ptr1).source(ptr2);
    
    handles.t.Data{row,3}=func2str(source.gmpe.handle);
    handles.t.Data{row,4}=func2str(source.mscl.handle);
    handles.t.Data{row,5}=source.rupt.type;
    handles.t.Data{row,6}=7;
    switch handles.mesh
        case 0
            handles.t.Data{row,7}=source.vertices(1,1);
            handles.t.Data{row,8}=source.vertices(1,2);
        case 1
            handles.t.Data{row,7}=0;
            handles.t.Data{row,8}=0;
    end
    handles.t.Data{row,10}=source.mscl.msparam.NMmin;
    handles.t.Data{row,11}=[];
    handles.t.Data{row,12}=[];
end

if col==6 && strcmp(handles.t.Data{row,9},'Yes')
    mlib = handles.t.ColumnFormat{1};
    [~,ptr1] = intersect(mlib,handles.t.Data{row,1});
    slib = handles.t.ColumnFormat{2};
    [~,ptr2] = intersect(slib,handles.t.Data{row,2});
    source  = handles.model(ptr1).source(ptr2);
    m    = handles.t.Data{row,6};
    X    = handles.t.Data{row,7};
    Y    = handles.t.Data{row,8};
    Mmax = getMMax(source,m,X,Y);
    handles.t.Data{row,6}=Mmax;
end

if col==8 % Select Taper Ends
    mlib = handles.t.ColumnFormat{1};
    [~,ptr1] = intersect(mlib,handles.t.Data{row,1});
    if isempty(ptr1)
        handles.t.Data{row,8}=eventdata.PreviousData;
        guidata(hObject,handles)
        return
    end
    
end

DataR    = handles.t.Data(row,:);
vorR     = handles.tessel{row,2};
mlib     = handles.t.ColumnFormat{1};
[~,ptr1] = intersect(mlib,handles.t.Data{row,1});
slib     = handles.t.ColumnFormat{2};
[~,ptr2] = intersect(slib,handles.t.Data{row,2});
source   = handles.model(ptr1).source(ptr2);
sSCEN_plotSource(handles,source,DataR,vorR);

guidata(hObject,handles)

function Ruler_Callback(hObject, eventdata, handles)

ch1=findall(handles.ax1,'tag','patchselect');
ch2=findall(handles.ax1,'tag','patchtxt');
if isempty(ch1) && isempty(ch2)
    ch1=findall(handles.figure1,'Style','pushbutton','Enable','on'); set(ch1,'Enable','inactive');
    ch2=findall(handles.figure1,'type','uimenu','Enable','on'); set(ch2,'Enable','off');
    XYLIM1 = get(handles.ax1,{'xlim','ylim'});
    show_distanceECEF(handles.ax1,'line');
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

function Undock_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax1)

function t_CellSelectionCallback(hObject, eventdata, handles)
if ~isempty(eventdata.Indices)
    try
        handles.current = eventdata.Indices;
        row      = eventdata.Indices(1);
        DataR    = handles.t.Data(row,:);
        vorR     = handles.tessel{row,2};
        mlib     = handles.t.ColumnFormat{1};
        [~,ptr1] = intersect(mlib,handles.t.Data{row,1});
        slib     = handles.t.ColumnFormat{2};
        [~,ptr2] = intersect(slib,handles.t.Data{row,2});
        source   = handles.model(ptr1).source(ptr2);
        sSCEN_plotSource(handles,source,DataR,vorR);
        
        selRow = unique(eventdata.Indices(:,1));
        NMmin = cell2mat(handles.t.Data(selRow,10));
        RateM = cell2mat(handles.t.Data(selRow,11));
        RateR = cell2mat(handles.t.Data(selRow,12));
        count    = length(NMmin);
        if isempty(RateM), RateM = zeros(count,1); end
        if isempty(RateR), RateR = zeros(count,1); end
        allrates = sum(NMmin.*RateM.*RateR);
        sumRateM = sum(RateM);
        sumRateR = sum(RateR);
        
        handles.sumtxt.String = sprintf('Allrate = %4.3g     SumRateM = %4.3g     SumRateR = %4.3g     Count = %g \n',allrates,sumRateM,sumRateR,count);
        guidata(hObject,handles)
    catch
    end
end

function SourceDisc_Callback(hObject, eventdata, handles)

function meshtype1_Callback(hObject, eventdata, handles)
switch hObject.Checked
    case 'on' , hObject.Checked='off'; handles.meshtype2.Checked='on';
    case 'off', hObject.Checked='on';  handles.meshtype2.Checked='off';
end

function meshtype2_Callback(hObject, eventdata, handles)
switch hObject.Checked
    case 'on' , hObject.Checked='off'; handles.meshtype1.Checked='on';
    case 'off', hObject.Checked='on';  handles.meshtype1.Checked='off';
end

function invokeWiz_Callback(hObject, eventdata, handles)

[twiz,optwis]=scenWizard(handles.model);
if isempty(twiz),return,end

% checks that twiz is appropriate
Nscen= size(twiz,1);
handles.t.Data = cell(Nscen,12);
handles.t.Data(:,1) = twiz(:,1);
handles.t.Data(:,2) = twiz(:,2);
handles.t.Data(:,9) = twiz(:,5);
handles.tessel      = repmat({[],zeros(0,2)},Nscen,1);

mlib = handles.t.ColumnFormat{1};
for i=1:Nscen
    [~,ptr1] = intersect(mlib,handles.t.Data{i,1});
    slib     = {handles.model(ptr1).source.label};
    [~,ptr2] = intersect(slib,handles.t.Data{i,2});
    source  = handles.model(ptr1).source(ptr2);
    handles.t.Data{i,3}=func2str(source.gmpe.handle);
    handles.t.Data{i,4}=func2str(source.mscl.handle);
    handles.t.Data{i,5}=source.rupt.type;
    handles.t.Data{i,6}=7;
    handles.t.Data{i,7}=0;
    handles.t.Data{i,8}=0;
    handles.t.Data{i,10}=source.mscl.msparam.NMmin;
    handles.t.Data{i,11}=[];
    handles.t.Data{i,12}=[];
end

handles.current = [(1:Nscen)',ones(Nscen,1)];
handles=sSCEN_discM(handles,twiz,optwis);

Nscen = size(handles.t.Data,1);
handles.current = [(1:Nscen)',ones(Nscen,1)];

spacing = [];
for i=1:size(twiz,1)
    newsp   = repmat(twiz{i,4},twiz{i,3},1);
    spacing = [spacing;newsp];
end

handles=sSCEN_discR(handles,spacing);

row      = handles.current(1);
DataR    = handles.t.Data(row,:);
vorR     = handles.tessel{row,2};
mlib     = handles.t.ColumnFormat{1};
[~,ptr1] = intersect(mlib,DataR{1});
slib     = handles.t.ColumnFormat{2};
[~,ptr2] = intersect(slib,DataR{2});
source   = handles.model(ptr1).source(ptr2);
sSCEN_plotSource(handles,source,DataR,vorR);

guidata(hObject,handles)
