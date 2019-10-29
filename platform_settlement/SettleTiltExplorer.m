function varargout = SettleTiltExplorer(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SettleTiltExplorer_OpeningFcn, ...
    'gui_OutputFcn',  @SettleTiltExplorer_OutputFcn, ...
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

function SettleTiltExplorer_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
load All_Scenario_Buttons DiscretizeMButtonbutton
handles.DiscretizeMButtonbutton.CData = DiscretizeMButtonbutton;
handles.undock1.CData = double(imread('Undock.jpg'))/255;
handles.undock2.CData = double(imread('Undock.jpg'))/255;
handles.Book.CData = double(imread('book_open.jpg'))/255;

methods = pshatoolbox_methods(6);
handles.func = {methods.func};
handles.STpop.String = {methods.label};
handles.STpop.Value  = 1;

% Write xlabel and ylabel
handles.plotmodeax2='ccdf';
handles.ax1XLABEL=xlabel(handles.ax1,'CAV (cm/s)');
handles.ax1YLABEL=ylabel(handles.ax1,'S (mm)');
handles.ax2XLABEL=xlabel(handles.ax2,'s (mm)');
handles.ax2YLABEL=ylabel(handles.ax2,'ccdf');

% fills Mass and contact pressure
update_Mst(handles)
popSettleModel(handles)
handles.t.Data=num2cell([9,0,0,0,0,0,0,0,0,0;6,0,0,0,0,0,0,0,0,0;3.5,0,0,0,0,0,0,0,0,0]');
plotSettle(handles)

guidata(hObject, handles);
% uiwait(handles.figure1);

function varargout = SettleTiltExplorer_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% ---------------------- building properties ------------------------------
function []=popSettleModel(handles)
handles.t1.Visible='off'; handles.e1.Visible='off';
handles.t2.Visible='off'; handles.e2.Visible='off';
handles.t3.Visible='off'; handles.e3.Visible='off';

switch handles.STpop.Value
    case 1
        handles.t1.Visible='on'; handles.t1.String='CAV (cm/s)';
        handles.e1.Visible='on'; handles.e1.String=240.89;
    case 2
        handles.t1.Visible='on'; handles.t1.String='CAV (cm/s)';
        handles.e1.Visible='on'; handles.e1.String=240.89;
    case 3
        handles.t1.Visible='on'; handles.t1.String='CAV (cm/s)';
        handles.e1.Visible='on'; handles.e1.String=240.89;
    case 4
        handles.t1.Visible='on'; handles.t1.String='CAV (cm/s)';
        handles.e1.Visible='on'; handles.e1.String=240.89;
        handles.t2.Visible='on'; handles.t2.String='VGI (cm/s)';
        handles.e2.Visible='on'; handles.e2.String=14.39;
end

function []=update_Mst(handles)

B          = str2double(handles.B.String);
L          = str2double(handles.L.String);
numStories = str2double(handles.numStories.String);
h          = str2double(handles.h.String);
if h < 0 || isnan(h)
    h = 3.41*numStories;
end
bType      = handles.bType.String{handles.bType.Value};

switch bType
    case 'Masonry',             Mst = 455*B*L*h; q = 455*h*9.81/1000; % Foundation bearing pressure, q (kPa)
    case 'Reinforced-Concrete', Mst = 455*B*L*h; q = 455*h*9.81/1000;
    case 'Timber',              Mst =  51*B*L*h; q =  51*h*9.81/1000;
    case 'Steel',               Mst = 242*B*L*h; q = 242*h*9.81/1000;
end

handles.Mst.String = sprintf('%g',Mst);
handles.q.String   = sprintf('%.3g',q);

function []=plotSettle(handles)

build.B           = str2double(handles.B.String);
build.L           = str2double(handles.L.String);
build.Df          = str2double(handles.Df.String);
build.bType       = handles.bType.String{handles.bType.Value};
build.numStories  = str2double(handles.numStories.String);
build.h           = str2double(handles.h.String);
soil.LPC          = handles.LPC.String{handles.LPC.Value};
soil.th1          = str2double(handles.th1.String);
soil.th2          = str2double(handles.th2.String);
soil.N1           = str2double(handles.N1.String);
soil.N2           = str2double(handles.N2.String);
soil.Method       = handles.Method.String{handles.Method.Value};
Tab               = cell2mat(handles.t.Data)';
soil.N            = Tab(1,:);
soil.Hs           = Tab(2,:);
soil.Ds           = Tab(3,:);
func              = handles.func{handles.STpop.Value};

switch handles.STpop.Value
    case 1
        x0          = logsp(1,1000,200);
        [lny0,sig0] = func(soil,build,x0);
        cav         = str2double(handles.e1.String);
        [mu,sig]    = func(soil,build,cav);
        x           = logsp(1,1000,200);
        handles.ax1XLABEL.String='CAV (cm/s)';
        handles.ax1YLABEL.String='S (mm)';
        handles.ax2XLABEL.String='s (mm)';
    case 2
        x0          = logsp(1,1000,200);
        [lny0,sig0] = func(soil,build,x0);
        cav         = str2double(handles.e1.String);
        [mu,sig]    = func(soil,build,cav);
        x           = logsp(1,1000,200);
        handles.ax1XLABEL.String='CAV (cm/s)';
        handles.ax1YLABEL.String='S (mm)';
        handles.ax2XLABEL.String='s (mm)';
    case 3
        x0          = logsp(0.01,10,200);
        [lny0,sig0] = func(soil,build,x0);
        cav         = str2double(handles.e1.String);
        [mu,sig]    = func(soil,build,cav);
        x           = logsp(0.01,10,100);
        handles.ax1XLABEL.String='CAV (cm/s)';
        handles.ax1YLABEL.String='\theta (°)';
        handles.ax2XLABEL.String='\theta (°)';
    case 4
        x0          = logsp(0.01,10,200);
        [lny0,sig0] = B18_TE(soil,build,x0);
        cav         = str2double(handles.e1.String);
        vgi         = str2double(handles.e2.String);
        [mu,sig]    = B18_TSE(soil,build,cav,vgi);
        x           = logsp(0.01,10,100);
        handles.ax1XLABEL.String='CAV (cm/s)';
        handles.ax1YLABEL.String='\theta (°)';
        handles.ax2XLABEL.String='\theta (°)';
end

switch handles.plotmodeax2
    case 'pdf'  , Y   =   normpdf(log(x),mu,sig);  handles.ax2YLABEL.String='pdf';
    case 'cdf'  , Y   =   normcdf(log(x),mu,sig);  handles.ax2YLABEL.String='cdf';
    case 'ccdf' , Y   = 1-normcdf(log(x),mu,sig);  handles.ax2YLABEL.String='ccdf';
end

delete(findall(handles.ax1,'tag','curves'))
handles.ax1.ColorOrderIndex=1; plot(handles.ax1,x0,exp(lny0)     ,'','tag','curves','DisplayName','\mu')
handles.ax1.ColorOrderIndex=1; plot(handles.ax1,x0,exp(lny0-sig0),'--','tag','curves','DisplayName','\mu\pm\sigma')
handles.ax1.ColorOrderIndex=1; plot(handles.ax1,x0,exp(lny0+sig0),'--','tag','curves','HandleVisibility','off')
Leg=legend(handles.ax1);
Leg.Box      = 'off';
Leg.Location = 'NorthWest';

c2 = uicontextmenu;
uimenu(c2,'Label','Copy data','Callback'  ,{@data2clipboard_uimenu,num2cell([x0(:),exp([lny0-sig0;lny0;lny0+sig0])'])});
set(handles.ax1,'uicontextmenu',c2);

delete(findall(handles.ax2,'tag','curves'))
handles.ax2.ColorOrderIndex=1;
plot(handles.ax2,x,Y,'tag','curves','HandleVisibility','off')

c2 = uicontextmenu;
uimenu(c2,'Label','Copy data','Callback'  ,{@data2clipboard_uimenu,num2cell([x(:),Y(:)])});
set(handles.ax2,'uicontextmenu',c2);

function B_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
update_Mst(handles)
plotSettle(handles)

function L_Callback(hObject, eventdata, handles)
update_Mst(handles)
plotSettle(handles)

function Df_Callback(hObject, eventdata, handles)
plotSettle(handles)

function bType_Callback(hObject, eventdata, handles)
update_Mst(handles)
plotSettle(handles)

function numStories_Callback(hObject, eventdata, handles) %#ok<*INUSD>
numSt = max(1,str2double(hObject.String));
hObject.String=sprintf('%g',numSt);
update_Mst(handles)

function h_Callback(hObject, eventdata, handles)
if isempty(hObject.String)
    handles.numStories.Enable='on';
else
    handles.numStories.Enable='off';
end
update_Mst(handles)
plotSettle(handles)

function Mst_Callback(hObject, eventdata, handles)

function q_Callback(hObject, eventdata, handles)

% ------------------------ soil deposit parameters ------------------------
function psource_Callback(hObject, eventdata, handles)

function LPC_Callback(hObject, eventdata, handles)
plotSettle(handles)

function th1_Callback(hObject, eventdata, handles)
plotSettle(handles)

function th2_Callback(hObject, eventdata, handles)
plotSettle(handles)

function N1_Callback(hObject, eventdata, handles)
plotSettle(handles)

function Method_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 1, handles.t.ColumnName{1}='N1_60';
    case 2, handles.t.ColumnName{1}='qc1N';
end
plotSettle(handles)

function N2_Callback(hObject, eventdata, handles)
plotSettle(handles)

% --------------- Settlement / Tilt Model ---------------------------------
function STpop_Callback(hObject, eventdata, handles)
popSettleModel(handles)
plotSettle(handles)

function e1_Callback(hObject, eventdata, handles)
plotSettle(handles)

function e2_Callback(hObject, eventdata, handles)
plotSettle(handles)

function e3_Callback(hObject, eventdata, handles)
plotSettle(handles)

% --------------- Other ---------------------------------------------------
function DiscretizeMButtonbutton_Callback(hObject, eventdata, handles)
switch handles.plotmodeax2
    case 'pdf'  , handles.plotmodeax2='cdf';
    case 'cdf'  , handles.plotmodeax2='ccdf';
    case 'ccdf' , handles.plotmodeax2='pdf';
end
plotSettle(handles)
guidata(hObject,handles)

function undock1_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax1)

function undock2_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax2)

function Book_Callback(hObject, eventdata, handles)
val     = handles.STpop.Value;
methods = pshatoolbox_methods(6,val);
if ~isempty(methods.ref)
    try
        web(methods.ref,'-browser')
    catch
    end
end
