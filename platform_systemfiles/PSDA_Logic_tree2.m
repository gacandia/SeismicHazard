function varargout = PSDA_Logic_tree2(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PSDA_Logic_tree2_OpeningFcn, ...
    'gui_OutputFcn',  @PSDA_Logic_tree2_OutputFcn, ...
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

function PSDA_Logic_tree2_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = [];
handles.model  = varargin{1};
handles.sys    = varargin{2};
Ts_param       = varargin{3};
ky_param       = varargin{4};
T1             = varargin{5};
T2             = varargin{6};
T3             = varargin{7};
AnalysisType   = varargin{8};

switch AnalysisType
    case 'PBPA'  , handles.radiobutton1.Value=1;
    case 'FPBPA' , handles.radiobutton2.Value=1;
end

label    = {handles.sys.SMLIB.id};
isGMMReg = horzcat(handles.sys.SMLIB.isregular);

handles.table3.ColumnFormat{2}= label(isGMMReg);
handles.table3.ColumnFormat{3}= label(isGMMReg);
handles.table3.ColumnFormat{4}= label(isGMMReg);
handles.table3.ColumnFormat{5}= label(isGMMReg);

% seismic hazard
handles.model_t1.String=handles.model(1).id1;
handles.model_t2.String=handles.model(1).id2;
handles.model_t3.String=handles.model(1).id3;
handles.table1.Data=T1;

% slope parameters
handles.Ts_mean.String = sprintf('%g',Ts_param(1));
handles.Ts_cov.String  = sprintf('%g',Ts_param(2));
handles.Ts_nsta.String = sprintf('%g',Ts_param(3));

handles.ky_mean.String = sprintf('%g',ky_param(1));
handles.ky_cov.String  = sprintf('%g',ky_param(2));
handles.ky_nsta.String = sprintf('%g',ky_param(3));

handles.table2.Data    = T2;

% displacement model
handles.table3.Data = T3;
handles.current1    = zeros(0,2);
handles.current2    = zeros(0,2);
handles.current3    = zeros(0,2);

% axis properties
handles.ax1.Box='off';
handles.ax1.XTick=[];
handles.ax1.YTick=[];
handles.ax1.XLim=[0 9];
handles.ax1.YLim=[-1.1 1.3];
handles.ax1.NextPlot='add';
text(handles.ax1,2,1.3,'Seismic Hazard','horizontalalignment','right')
text(handles.ax1,5,1.3,'Slope Parameters','horizontalalignment','right')
text(handles.ax1,8,1.3,'Displacement Model','horizontalalignment','right')

switch handles.radiobutton1.Value
    case 1, plotPSDALogicTree(handles);
    case 0, plotPSDALogicTree(handles);
end
axis(handles.ax1,'off')
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = PSDA_Logic_tree2_OutputFcn(hObject, eventdata, handles)

% normalizacion de los pesos, just in case...
% -------------------------------------------------------------------------
w1 = cell2mat(handles.table1.Data(:,2)); w1 = w1/sum(w1); handles.table1.Data(:,2)=num2cell(w1);
w2 = cell2mat(handles.table2.Data(:,4)); w2 = w2/sum(w2); handles.table2.Data(:,4)=num2cell(w2);
w3 = cell2mat(handles.table3.Data(:,6)); w3 = w3/sum(w3); handles.table3.Data(:,6)=num2cell(w3);
% -------------------------------------------------------------------------

switch handles.radiobutton1.Value
    case 1
        varargout{1}={'Branch0',1};
    case 0
        varargout{1}=handles.table1.Data;
end
varargout{2}=handles.table2.Data;
varargout{3}=handles.table3.Data;
varargout{4}=str2double({handles.Ts_mean.String,handles.Ts_cov.String,handles.Ts_nsta.String});
varargout{5}=str2double({handles.ky_mean.String,handles.ky_cov.String,handles.ky_nsta.String});
varargout{6}=handles.uibuttongroup2.SelectedObject.String;
delete(handles.figure1)

function plotPSDALogicTree(handles)
delete(findall(handles.ax1,'tag','logic'));
handles.ax1.ColorOrderIndex=1;
N1 = size(handles.table1.Data,1);
N2 = size(handles.table2.Data,1);
N3 = size(handles.table3.Data,1);

x1  = [0 1 2];  LT1 = buildLTLine(x1,N1);
x2  = x1+3;     LT2 = buildLTLine(x2,N2);
x3  = x1+6;     LT3 = buildLTLine(x3,N3);

plot(handles.ax1,LT1(:,1),LT1(:,2),'.-','tag','logic'),handles.ax1.ColorOrderIndex=1;
plot(handles.ax1,LT2(:,1),LT2(:,2),'.-','tag','logic'),handles.ax1.ColorOrderIndex=1;
plot(handles.ax1,LT3(:,1),LT3(:,2),'.-','tag','logic'),handles.ax1.ColorOrderIndex=1;

% c    = uicontextmenu;
% uimenu(c,'Label','Undock','Callback',           {@figure2clipboard_uimenu,handles.ax1,''});
% set(handles.ax1,'uicontextmenu',c);

function LT = buildLTLine(x,N)
if N==1
    y  = 0;
else
    y  = linspace(-1,1,N);
end
LT = [x(1) 0;NaN NaN];
for i=1:N
    nLT = [x(1) 0;x(2) y(i);x(3) y(i);NaN NaN];
    LT  = [LT;nLT]; %#ok<*AGROW>
end

function table1_CellSelectionCallback(hObject, eventdata, handles) %#ok<*DEFNU>

if ~isempty(eventdata.Indices)
    ind = eventdata.Indices(1);
    handles.model_t1.String=handles.model(ind).id1;
    handles.model_t2.String=handles.model(ind).id2;
    handles.model_t3.String=handles.model(ind).id3;
end
guidata(hObject,handles)

function Normalize1_Callback(hObject, eventdata, handles)

w = handles.table1.Data(:,2);
w = cell2mat(w);
handles.table1.Data(:,2)=num2cell(w/sum(w));
guidata(hObject,handles)

function Normalize2_Callback(hObject, eventdata, handles) %#ok<*INUSD>

w = handles.table2.Data(:,4);
w = cell2mat(w);
handles.table2.Data(:,4)=num2cell(w/sum(w));
guidata(hObject,handles)

function Ts_mean_Callback(hObject, eventdata, handles)
updatet2(handles)
guidata(hObject,handles)

function Ts_cov_Callback(hObject, eventdata, handles)
updatet2(handles)
guidata(hObject,handles)

function Ts_nsta_Callback(hObject, eventdata, handles)
updatet2(handles)
plotPSDALogicTree(handles)
guidata(hObject,handles)

function ky_mean_Callback(hObject, eventdata, handles)
updatet2(handles)
guidata(hObject,handles)

function ky_cov_Callback(hObject, eventdata, handles)
updatet2(handles)
guidata(hObject,handles)

function ky_nsta_Callback(hObject, eventdata, handles)
updatet2(handles)
plotPSDALogicTree(handles)
guidata(hObject,handles)

function updatet1(handles)
whaz        = handles.sys.WEIGHT(:,4);

Tm_param=[str2double(handles.Tm_mean.String),...
    str2double(handles.Tm_cov.String),...
    str2double(handles.Tm_nsta.String)];

[Tm,~,dPTm] = trlognpdf_psda(Tm_param);
[ind1,ind2] = meshgrid(1:length(whaz),1:length(Tm)); ind1 = ind1(:); ind2 = ind2(:);
id          = strrep({handles.model(ind1).id}','Branch','haz');
Tm          = Tm(ind2);
w1          = whaz(ind1);
w2          = dPTm(ind2);
handles.table1.Data  = [id,num2cell([Tm w1.*w2])];

function updatet2(handles)
Ts_param=[str2double(handles.Ts_mean.String),...
    str2double(handles.Ts_cov.String),...
    str2double(handles.Ts_nsta.String)];

ky_param=[str2double(handles.ky_mean.String),...
    str2double(handles.ky_cov.String),...
    str2double(handles.ky_nsta.String)];

[Ts,~,dPTs] = trlognpdf_psda(Ts_param);
[ky,~,dPky] = trlognpdf_psda(ky_param);

Ts          = round(Ts*1e10)/1e10;
[ind1,ind2] = meshgrid(1:length(Ts),1:length(ky));
ind1   = ind1(:);
ind2   = ind2(:);
props  = [Ts(ind1),ky(ind2),dPTs(ind1).*dPky(ind2)];
ss     = cell(size(props,1),1) ;
for i=1:size(props,1)
    ss{i}=sprintf('set%g',i);
end
handles.table2.Data=[ss,num2cell(props)];

function Normalize3_Callback(hObject, eventdata, handles)

w = handles.table3.Data(:,6);
wsum = sum(cell2mat(w));
for i=1:length(w)
    if ~isempty(w{i})
        w{i}=w{i}/wsum;
    end
end
handles.table3.Data(1:length(w),6)=w;
guidata(hObject,handles)

function New_Disp_Callback(hObject, eventdata, handles)
handles.table3.Data(end+1,:)=cell(1,6);
handles.T3add(end+1,:)=cell(1,4);
handles.current3=size(handles.table3.Data);

for i=1:size(handles.table3.Data,1)
    handles.table3.Data{i,1}=sprintf('slope%g',i);
end
plotPSDALogicTree(handles)
guidata(hObject,handles)

function Copy_Disp_Callback(hObject, eventdata, handles)
if ~isempty(handles.current3)
    ind = handles.current3(1);
    handles.table3.Data=handles.table3.Data([1:end,ind],:);
    handles.T3add = handles.T3add([1:end,ind],:);
    plotPSDALogicTree(handles)
    handles.current3=zeros(0,2);
    
    for i=1:size(handles.table3.Data,1)
        handles.table3.Data{i,1}=sprintf('disp%g',i);
    end
end
guidata(hObject,handles)

function Delete_Disp_Callback(hObject, eventdata, handles)

if ~isempty(handles.current3)
    if size(handles.table3.Data,1)>1
        ind = handles.current3(1);
        handles.table3.Data(ind,:)=[];
        handles.T3add(ind,:)=[];
        plotPSDALogicTree(handles)
        handles.current3=zeros(0,2);
    end
end

for i=1:size(handles.table3.Data,1)
    handles.table3.Data{i,1}=sprintf('disp%g',i);
end

guidata(hObject,handles)

function table1_CellEditCallback(hObject, eventdata, handles)
handles.current1=eventdata.Indices;
guidata(hObject,handles);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)

switch hObject.String
    case 'PBPA'  
        handles.table1.Data={'Branch0',1};
        plotPSDALogicTree(handles)
    case 'FPBPA' 
        W = handles.sys.WEIGHT(:,end);
        Nb = length(W);
        handles.table1.Data=[compose('Branch%i',(1:Nb)'),num2cell(W(:))];
        plotPSDALogicTree(handles)
end
