function varargout = PSHA_Logic_Tree(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PSHA_Logic_Tree_OpeningFcn, ...
    'gui_OutputFcn',  @PSHA_Logic_Tree_OutputFcn, ...
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

function PSHA_Logic_Tree_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

sys= varargin{1};
handles.sys = sys;

% seismic hazard
id1 = {sys.GEOM.id};
W1  = unique([sys.BRANCH(:,1),sys.WEIGHT(:,1)],'rows');
W1  = num2cell(W1(:,2));
handles.table1.Data=[id1(:),W1];

% GMM
id2 = {sys.GMPE.id};
W2  = unique([sys.BRANCH(:,2),sys.WEIGHT(:,2)],'rows');
W2  = num2cell(W2(:,2));
handles.table2.Data=[id2(:),W2];

% MR
id3 = {sys.MSCL.id};
W3  = unique([sys.BRANCH(:,3),sys.WEIGHT(:,3)],'rows');
W3  = num2cell(W3(:,2));
handles.table3.Data=[id3(:),W3];
% 

handles.current1=zeros(0,2);
handles.current2=zeros(0,2);
handles.current3=zeros(0,2);

% axis properties
axis(handles.ax1,'off');
handles.ax1.Box='on';
handles.ax1.XLim=[0 9];
handles.ax1.YLim=[-1.1 1.3];
handles.ax1.NextPlot='add';
text(handles.ax1,2,1.3,'Seismic Source','horizontalalignment','right')
text(handles.ax1,4.5,1.3,'GMM','horizontalalignment','right')
text(handles.ax1,7,1.3,'MR','horizontalalignment','right')
plotPSHALogicTree(handles);
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = PSHA_Logic_Tree_OutputFcn(hObject, eventdata, handles)

branch = handles.sys.BRANCH;
geom_weight=cell2mat(handles.table1.Data(:,2));
gmpe_weight=cell2mat(handles.table2.Data(:,2));
mscl_weight=cell2mat(handles.table3.Data(:,2));
weight = [
    geom_weight(branch(:,1)),...
    gmpe_weight(branch(:,2)),...
    mscl_weight(branch(:,3))];
handles.sys.WEIGHT= [weight,prod(weight,2)];
varargout{1}=handles.sys;
delete(handles.figure1)

function plotPSHALogicTree(handles)
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

guidata(hObject,handles)

function Normalize1_Callback(hObject, eventdata, handles)

w = handles.table1.Data(:,2);
w = cell2mat(w);
handles.table1.Data(:,2)=num2cell(w/sum(w));
guidata(hObject,handles)

function Normalize2_Callback(hObject, eventdata, handles) %#ok<*INUSD>

w = handles.table2.Data(:,2);
w = cell2mat(w);
handles.table2.Data(:,2)=num2cell(w/sum(w));
guidata(hObject,handles)

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

w = handles.table3.Data(:,2);
wsum = sum(cell2mat(w));
for i=1:length(w)
    if ~isempty(w{i})
        w{i}=w{i}/wsum;
    end
end
handles.table3.Data(1:length(w),2)=w;
guidata(hObject,handles)

function table3_CellSelectionCallback(hObject, eventdata, handles)
handles.current3=eventdata.Indices;
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

function model_t2_ButtonDownFcn(hObject, eventdata, handles)
