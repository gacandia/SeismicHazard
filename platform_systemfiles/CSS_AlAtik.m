function varargout = CSS_AlAtik(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CSS_AlAtik_OpeningFcn, ...
                   'gui_OutputFcn',  @CSS_AlAtik_OutputFcn, ...
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

function CSS_AlAtik_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

load CSSbuttons c3 c5
handles.undock.CData    = c3;
handles.ax2Limits.CData = c5;


methods = pshatoolbox_methods(4);
handles.correlationmodel.String={methods.label};

%% populate fields
handles.default_Tcss  = [0.010;0.050;0.075;0.100;0.150;0.200;0.250;0.300;0.400;0.500;0.750;1.000;1.500;2.000];
handles.default_AEP   = [0.01;0.0045;0.002;0.001;0.00025;0.0001;4e-05;6e-06;1e-06;1e-07;1e-08];
if nargin>4
    param = varargin{1};
    Tcss  = varargin{2};
    AEP   = varargin{3};
    corrV = varargin{4};
    flatfile = varargin{5};
    handles.Nper.String=sprintf('%g',length(Tcss));
    handles.Nhaz.String=sprintf('%g',length(AEP));
    handles.tb1.Data=num2cell(Tcss);
    handles.tb2.Data=num2cell(AEP);
    handles.correlationmodel.Value = corrV;
    handles.locate_flatfile.String = flatfile;
else
    param = {2,'1','0.01 - 2','0.04 - 0.4','2 - 8',1,'0 - 1000','150 - 3000','5 - 150','0 - 3000','0 - 1000','32','1000','700 - 0.01','100'};
    handles.Nper.String=sprintf('%g',length(handles.default_Tcss));
    handles.Nhaz.String=sprintf('%g',length(handles.default_AEP));
    handles.tb1.Data=num2cell(handles.default_Tcss);
    handles.tb2.Data=num2cell(handles.default_AEP);
    handles.correlationmodel.Value = 7;
end
handles.op1.Value   = param{1};
handles.op2.String  = param{2};
handles.op3.String  = param{3};
handles.op4.String  = param{4};
handles.op5.String  = param{5};
handles.op6.Value   = param{6};
handles.op7.String  = param{7};
handles.op8.String  = param{8};
handles.op9.String  = param{9};
handles.op10.String = param{10};
handles.op11.String = param{11};
handles.op12.String = param{12};
handles.op13.String = param{13};
handles.op14.String = param{14};
handles.op15.String = param{15};

if nargin>=4 && ~isempty(handles.locate_flatfile.String)
    handles.alldata=readDatabase(handles.locate_flatfile.String);
    
    Nall  = size(handles.alldata,1);
    handles.AllRecords.String      = sprintf('%i', Nall);
    
    Nfilt = fdata(handles);
    handles.Candidates.String = sprintf('%i', Nfilt);
end

%% ax setup
handles.ax4.YLim=[0 1];
xlabel(handles.ax4,'T (s)','fontsize',8)
ylabel(handles.ax4,'\rho (T*,T)','fontsize',8)
updateax4(handles)
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = CSS_AlAtik_OutputFcn(hObject, eventdata, handles) 
param    = cell(1,15);
param{1} = handles.op1.Value;
param{2} = handles.op2.String;
param{3} = handles.op3.String;
param{4} = handles.op4.String;
param{5} = handles.op5.String;
param{6} = handles.op6.Value;
param{7} = handles.op7.String;
param{8} = handles.op8.String;
param{9} = handles.op9.String;
param{10}= handles.op10.String;
param{11}= handles.op11.String;
param{12}= handles.op12.String;
param{13}= handles.op13.String;
param{14}= handles.op14.String;
param{15}= handles.op15.String;
varargout{1} = param;
varargout{2} = cell2mat(handles.tb1.Data);
varargout{3} = cell2mat(handles.tb2.Data);
varargout{4} = handles.correlationmodel.Value;
varargout{5} = handles.locate_flatfile.String;
varargout{6} = str2double(handles.Candidates.String);
delete(handles.figure1)

function updateax4(handles)
delete(findall(handles.ax4,'tag','rho'))
handles.ax4.ColorOrderIndex=1;
Tcond   = str2double(handles.op2.String);
Tlim    = str2double(regexp(handles.op3.String,'\-','split'));
T       = unique([logsp(Tlim(1),Tlim(2),50),Tcond,Tcond-eps,Tcond+eps]);
methods = pshatoolbox_methods(4,handles.correlationmodel.Value);
Cond_param = struct('opp',0,'mechanism','interface','M',7,'residual','tau','direction','horizontal');
plot(handles.ax4,T,methods.func(Tcond,T,Cond_param),'tag','rho')

Ta = cell2mat(handles.tb1.Data);
plot(handles.ax4,Ta,methods.func(Tcond,Ta,Cond_param),'.','tag','rho')

plot(handles.ax4,Tcond*[1 1],[0 1],'k--','tag','rho')
handles.ax4.XLim(2)=Tlim(2);

function op1_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function op2_Callback(hObject, eventdata, handles)
updateax4(handles)

function op3_Callback(hObject, eventdata, handles)
updateax4(handles)

function op4_Callback(hObject, eventdata, handles)

function op5_Callback(hObject, eventdata, handles)
Nfilt = fdata(handles);
handles.Candidates.String = sprintf('%i', Nfilt);

function op6_Callback(hObject, eventdata, handles)
Nfilt = fdata(handles);
handles.Candidates.String = sprintf('%i', Nfilt);

function op7_Callback(hObject, eventdata, handles)
Nfilt = fdata(handles);
handles.Candidates.String = sprintf('%i', Nfilt);

function op8_Callback(hObject, eventdata, handles)
Nfilt = fdata(handles);
handles.Candidates.String = sprintf('%i', Nfilt);

function op9_Callback(hObject, eventdata, handles)
Nfilt = fdata(handles);
handles.Candidates.String = sprintf('%i', Nfilt);

function op10_Callback(hObject, eventdata, handles)
Nfilt = fdata(handles);
handles.Candidates.String = sprintf('%i', Nfilt);

function op11_Callback(hObject, eventdata, handles)
Nfilt = fdata(handles);
handles.Candidates.String = sprintf('%i', Nfilt);

function op12_Callback(hObject, eventdata, handles)

function op13_Callback(hObject, eventdata, handles)

function op14_Callback(hObject, eventdata, handles)

function op15_Callback(hObject, eventdata, handles)

function correlationmodel_Callback(hObject, eventdata, handles)
updateax4(handles)

function ax2Limits_Callback(hObject, eventdata, handles)
handles.ax4=ax2Control(handles.ax4);

function Nper_Callback(hObject, eventdata, handles)
Told    = cell2mat(handles.tb1.Data);
Nold    = length(Told);
Nnew    = str2double(hObject.String);
if Nnew<Nold
    handles.tb1.Data=handles.tb1.Data(1:Nnew);
elseif Nnew>Nold
    handles.tb1.Data=num2cell(interp1(1:Nold,Told,1:Nnew,'linear','extrap')');
end
updateax4(handles)

function Nhaz_Callback(hObject, eventdata, handles)

Hazold    = cell2mat(handles.tb2.Data);
Nold    = length(Hazold);
Nnew    = str2double(hObject.String);
if Nnew<Nold
    handles.tb2.Data=handles.tb2.Data(1:Nnew);
elseif Nnew>Nold
    handles.tb2.Data=num2cell(exp(interp1(1:Nold,log(Hazold),1:Nnew,'linear','extrap'))');
end

function File_Callback(hObject, eventdata, handles)

function RestoreDef_Callback(hObject, eventdata, handles)

function tb1_CellEditCallback(hObject, eventdata, handles)
updateax4(handles)

function restore1_Callback(hObject, eventdata, handles)

handles.Nper.String=sprintf('%g',length(handles.default_Tcss));
handles.tb1.Data= num2cell(handles.default_Tcss);
updateax4(handles)

function restore2_Callback(hObject, eventdata, handles)
handles.Nhaz.String=sprintf('%g',length(handles.default_AEP));
handles.tb2.Data= num2cell(handles.default_AEP);

function undock_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax4)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function locate_flatfile_ButtonDownFcn(hObject, eventdata, handles)

[filename,filepath,indx] = uigetfile('*.csv');
if indx
    handles.locate_flatfile.String=fullfile(filepath,filename);
    handles.alldata = readDatabase(handles.locate_flatfile.String);
    Nall  = size(handles.alldata,1);
    handles.AllRecords.String      = sprintf('%g', Nall);
    
    Nfilt = fdata(handles);
    handles.Candidates.String = sprintf('%g', Nfilt);
   
end
guidata(hObject,handles)

function [N]=fdata(handles)

data = handles.alldata;
switch handles.op6.Value
    case 1, data(:,3)=[]; % keeps Rrup
    case 2, data(:,2)=[]; % keeps Rjb
end

F  = zeros(6,2);
F(1,:) = str2double(regexp(handles.op5.String  , '\-','split')); % M
F(2,:) = str2double(regexp(handles.op7.String  , '\-','split')); % Dist
F(3,:) = str2double(regexp(handles.op8.String  , '\-','split')); % Vs30
F(4,:) = str2double(regexp(handles.op9.String  , '\-','split')); % Duration
F(5,:) = str2double(regexp(handles.op10.String , '\-','split')); % PGV
F(6,:) = str2double(regexp(handles.op11.String , '\-','split')); % Arias Intensity

data(data(:,4)==-999,4)=mean(F(4,:));
data(data(:,5)==99  ,5)=mean(F(5,:));
data(data(:,6)==99  ,6)=mean(F(6,:));


Nr    = size(data,1);
data1 = repmat(F(:,1)',Nr,1); 
data2 = repmat(F(:,2)',Nr,1);
ind   = prod((data>=data1).*(data<=data2),2);
N     = sum(ind);

function AllRecords_Callback(hObject, eventdata, handles)

function Candidates_Callback(hObject, eventdata, handles)

function locate_flatfile_Callback(hObject, eventdata, handles)

function tb1_ButtonDownFcn(hObject, eventdata, handles)

data = cell2mat(handles.tb1.Data);
data = logsp(min(data),max(data),length(data))';
handles.tb1.Data = num2cell(data);

function tb2_ButtonDownFcn(hObject, eventdata, handles)

data = cell2mat(handles.tb2.Data);
data = logsp(max(data),min(data),length(data))';
handles.tb2.Data = num2cell(data);
