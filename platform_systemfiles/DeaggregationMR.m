function varargout = DeaggregationMR(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DeaggregationMR_OpeningFcn, ...
    'gui_OutputFcn',  @DeaggregationMR_OutputFcn, ...
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

function DeaggregationMR_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.Exit_button.CData  = double(imread('exit.jpg'))/255;

handles.sys    = varargin{1};
handles.model  = varargin{2};
handles.opt    = varargin{3};
handles.h      = varargin{4};

% ------------ REMOVES PCE MODELS (AT LEAST FOR NOW) ----------------------
handles.isREGULAR = find(horzcat(handles.model.isregular)==1);
handles.isPCE     = find(horzcat(handles.model.isregular)==0);
isREGULAR = handles.isREGULAR;
handles.model = handles.model(isREGULAR); 
[~,B]=setdiff(handles.sys.BRANCH(:,2),isREGULAR);
if ~isempty(B)
    handles.sys.BRANCH(B,:)=[];
    handles.sys.WEIGHT(B,:)=[];
    handles.sys.WEIGHT(:,4)=handles.sys.WEIGHT(:,4)/sum(handles.sys.WEIGHT(:,4));
end
% -------------------------------------------------------------------------

% updates seismic
handles.opt.MagDiscrete = {'uniform',0.1};
handles.model  = process_model(handles.sys,handles.opt);

% Build interface to adjust this piece of code
%--------------------------------------------------------------------------
rmin  = 0;  rmax  = 180; dr    = 20;
handles.Rbin      = [(rmin:dr:rmax-dr)',(rmin:dr:rmax-dr)'+dr];
mmin  = 5; mmax  = 9.2; dm    = 0.2;
handles.Mbin      = [(mmin:dm:mmax-dm)',(mmin:dm:mmax-dm)'+dm];
handles.returnperiod = [30;43;72;108;144;224;336;475;712;975;1462;1950;2475;3712;4975;7462;9950;19900];
%--------------------------------------------------------------------------

handles.popreturn.String   = num2cell(handles.returnperiod);
handles.popreturn.Value    = 1;
handles.menu_branch.String = {handles.model.id};
handles.menu_branch.Value  = 1;
handles.menu_source.String = ['all sources',{handles.model(1).source.label}];
handles.menu_source.Value  = 1;
handles.menu_site.String   = handles.h.id;
handles.menu_site.Value    = 1;
handles.IM_menu.String     = IM2str(handles.opt.IM);
handles.poolsize           = 0;

handles = drawbars(handles);
xlabel(handles.ax,handles.IM_menu.String{1},'fontsize',10);
ylabel(handles.ax,'Exceedance Rate','fontsize',10);
str = sprintf('%s | %s | %s',handles.model(1).id1,handles.model(1).id2,handles.model(1).id3);
% title(handles.ax,str,'fontsize',9,'fontweight','normal','tag','axtitle')
set (handles.figure1, 'WindowButtonMotionFcn', {@mouseMove,handles});
handles.bartitle.String='';
handles.bartitle2.String='';
rotate3d(handles.ax1)

plot(handles.ax,nan*[1 1],handles.ax.YLim,'-','tag','haz1');
plot(handles.ax,nan*[1 1],handles.ax.YLim,'.' ,'tag','haz2');
plot(handles.ax,nan*[1 1],handles.ax.YLim,'k:','tag','line');

guidata(hObject, handles);

function varargout = DeaggregationMR_OutputFcn(hObject, eventdata, handles)
varargout{1} = [];

% -------- FILE MENU ------------------------------------------------------

function File_Callback(hObject, eventdata, handles)

function SaveChart_Callback(hObject, eventdata, handles)

if ~isfield(handles,'deagg2')
    return
end

[FileName,PathName] =  uiputfile('*.out','Save Hazard Deaggregation Analysis');
if isnumeric(FileName)
    return
end

fid      = fopen([PathName,FileName],'w');
fprintf(fid,'Hazard Deagregation\n');
fprintf(fid,'-------------------\n');

% lambda  = handles.lambda1;
% Sa      = handles.im1;
dchart  = handles.dchart;

Nperiods = size(dchart,3);
Mcenter  = mean(handles.Mbin,2);
Rcenter  = mean(handles.Rbin,2);
for i=1:Nperiods
    fprintf(fid,'return period %g\n',handles.returnperiod(i));
    fprintf(fid,'\n');
    data = [nan,     Mcenter';
        Rcenter,dchart(:,:,i)];
    strfmt1 = ['R(km) | Mw',repmat('%10.2g',1,size(data,2)-1),'\n'];
    strfmt2 = [repmat('%10.2g',1,size(data,2)),'\n'];
    fprintf(fid,strfmt1,data(1,2:end)');
    fprintf(fid,strfmt2,data(2:end,:)');
    fprintf(fid,'\n');
    
end
fclose(fid);
open([PathName,FileName])

function Exit_Callback(hObject, eventdata, handles)
close(handles.figure1)

function Exit_button_Callback(hObject, eventdata, handles)
close(handles.figure1)

% -------- EDIT MENU ------------------------------------------------------

function Edit_Callback(hObject, eventdata, handles)

% -------- PANNEL OPTIONS -------------------------------------------------

function menu_branch_Callback(hObject, eventdata, handles)
handles = runDeaggAnalysis(handles);
guidata(hObject,handles)

function menu_source_Callback(hObject, eventdata, handles)
handles = runDeaggAnalysis(handles);
guidata(hObject,handles)

function menu_site_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
handles = runDeaggAnalysis(handles);
guidata(hObject,handles)

function IM_menu_Callback(hObject, eventdata, handles)
handles = runDeaggAnalysis(handles);
guidata(hObject,handles)

% --------- AUXILIARY FUNCTIONS -------------------------------------------
function mouseMove(hObject,eventdata,handles)

if ~isfield(handles,'deagg2')
    return
end
[x,y] = getAbsCoords(handles.ax);
tf = coordsWithinLimits(handles.ax, x,y);

if tf
    ch=findall(handles.ax,'tag','haz2');
    if length(ch.XData)==2
        return
    end
    
    [~,B]=min(abs(handles.im2-x));
    dchart=handles.dchart(:,:,B);
    handles.bartitle.String={...
        sprintf('Deaggregation for %s'     , handles.IM_menu.String{handles.IM_menu.Value});...
        sprintf('Hazard Level   = %4.3e'   , ch.YData(B));...
        sprintf('Return Period  = %g yr'   , handles.returnperiod(B))};
    
    handles.bartitle2.String={...
        sprintf('Mean Distance and Magnitude:');...
        sprintf('R = %-4.3g km' , handles.Rbar(B));...
        sprintf('M = %-4.3g'    , handles.Mbar(B))};
    
    ch=findall(handles.ax,'tag','line');
    ch.XData = handles.im2(B)*[1 1];
    ch.YData = handles.ax.YLim;
    handles.popreturn.Value=B;
    for i=1:numel(handles.b)
        handles.b(i).ZData(2:6:end,2)=dchart(:,i);
        handles.b(i).ZData(3:6:end,2)=dchart(:,i);
        handles.b(i).ZData(:,3)=handles.b(i).ZData(:,2);
        
        handles.line.XData=[1 1]*handles.im2(B);
        handles.line.YData=handles.ax.YLim;
    end
end

function [x, y] = getAbsCoords(h_ax)
crd = get(h_ax, 'CurrentPoint');
x = crd(2,1);
y = crd(2,2);

function tf = coordsWithinLimits(h_ax, x, y)
XLim = get(h_ax, 'xlim');
YLim = get(h_ax, 'ylim');
tf = x>XLim(1) && x<XLim(2) && y>YLim(1) && y<YLim(2);

function handles = drawbars(handles,varargin)

switch nargin
    case 1
        Mwin      = 5.1:0.2:8.9;        NM = length(Mwin);
        Rwin      = linspace(0,600,10); NR = length(Rwin); dr = Rwin(2)-Rwin(1);
        handles.b=bar3(handles.ax1,Rwin,nan(NR,NM));
        set(handles.ax1,...
            'xtick',1:1:length(Mwin),...
            'xticklabel',Mwin,...
            'projection','perspective',...
            'fontsize',8,...
            'ylim',[0-dr/2,600+dr/2],...
            'zlim',[0 1])
    otherwise
end

function run_Callback(hObject, eventdata, handles)
handles = runDeaggAnalysis(handles);
guidata(hObject,handles)

function handles = runDeaggAnalysis(handles)
IM_ptr     = handles.IM_menu.Value;
ncols      = size(handles.opt.im,2);
if ncols==1
    im1 = handles.opt.im;
else
    im1 = handles.opt.im(:,IM_ptr);
end
model_ptr  = handles.menu_branch.Value;
source_ptr = handles.menu_source.Value;
site_ptr   = handles.menu_site.Value;
opt        = handles.opt;

if source_ptr == 1
    Nsource = length(handles.model(model_ptr).source);
    source_ptr = 1:Nsource;
else
    Nsource = 1;
    source_ptr  = source_ptr-1;
end

IM    = opt.IM(IM_ptr);
site  = handles.h.p(site_ptr,:);
Vs30  = handles.h.Vs30(site_ptr);
model = handles.model(model_ptr);
model.source = model.source(source_ptr);

% computes hazard curve
lambda1 = runhazard1(im1,IM,site,Vs30,opt,model,Nsource,1);
lambda1 = permute(lambda1,[2,1,3,4]);
lambda1 = nansum(lambda1,4);
if all(lambda1==0)
    ch=findall(handles.ax,'tag','haz1'); ch.XData = [nan;nan]; ch.YData = [nan;nan];
    ch=findall(handles.ax,'tag','haz2'); ch.XData = [nan;nan]; ch.YData = [nan;nan];
    handles.bartitle.String='';
    handles.bartitle2.String='';    
    return
end

% computes im values for deaggregation
lambda1(lambda1==0)=max(min(lambda1),1e-8);
logy    = log(lambda1);
logx    = log(im1);
xData = logy(~isinf(logy));
yData = logx(~isinf(logy));
[~,IND]=unique(xData,'stable');
xData=xData(IND);
yData=yData(IND);


handles.returnperiod      = [30;43;72;108;144;224;336;475;712;975;1462;1950;2475;3712;4975;7462;9950;19900];
handles.popreturn.String  = num2cell(handles.returnperiod);

ff = [find(handles.returnperiod<min(1./exp(xData)));
      find(handles.returnperiod>max(1./exp(xData)))];
if ~isempty(ff)
    handles.returnperiod(ff)=[];
    handles.popreturn.String(ff)=[];
end

logyy   = log(1./handles.returnperiod);
logxx   = interp1(xData,yData,logyy,'pchip');

Nim2    = length(logxx);
im2     = exp(logxx);
lambda2 = nan(1,Nim2,1,Nsource,1);
deagg2  = runhazard2(im2,IM,site,Vs30,opt,model,Nsource,1);
for i=1:numel(deagg2)
    if ~isempty(deagg2{i})
        lambda2(i)=sum(deagg2{i}(:,3));
    end
end
lambda2 = permute(lambda2,[2,1,3,4]);
lambda2 = nansum(lambda2,4);

% plots hazard curves 1 and 2
ch=findall(handles.ax,'tag','haz1'); ch.XData = im1(:); ch.YData = lambda1;
ch=findall(handles.ax,'tag','haz2'); ch.XData = im2; ch.YData = lambda2;
ch=findall(handles.ax,'tag','line'); ch.XData = im2(1)*[1 1]; ch.YData = handles.ax.YLim;

% computes dessagregation figure
handles.im1     = im1;
handles.im2     = im2;
handles.lambda1 = lambda1;
handles.lambda2 = lambda2;
handles.deagg2  = deagg2;
handles         = run_func(handles,model);

function handles=run_func(handles,model)

lambda2 = handles.lambda2;
deagg2  = handles.deagg2;
deagg   = cell(size(deagg2,2),1);
for ii=1:numel(deagg)
    deagg{ii}=vertcat(deagg2{1,ii,1,:});
end

sourceptr    = [];
Nsources = size(deagg2,4);
for i=1:Nsources
    dg      = deagg2{1,1,1,i};
    Nscen   = size(dg,1);
    sourceptr   = [sourceptr;i*ones(Nscen,1)]; %#ok<AGROW>
end

if isempty(deagg{1})
    return
end

% build deaggregation chart 'dchart'
rmin      = handles.Rbin(1); rmax    = handles.Rbin(end);
Rcenter   = mean(handles.Rbin,2);
Mcenter   = mean(handles.Mbin,2);
handles.dchart = deagghazard(deagg,lambda2,Mcenter,Rcenter);


Mbar = zeros(numel(deagg),1);
Rbar = zeros(numel(deagg),1);
for i=1:numel(deagg)
    Mbar(i)=sum(deagg{i}(:,1).*deagg{i}(:,3))/sum(deagg{i}(:,3));
    Rbar(i)=sum(deagg{i}(:,2).*deagg{i}(:,3))/sum(deagg{i}(:,3));
end

handles.b=bar3(handles.ax1,Rcenter,handles.dchart(:,:,1));
xlabel(handles.ax1,'Magnitude');
ylabel(handles.ax1,'R (km)');
zlabel(handles.ax1,'Hazzard Deagg')
set(handles.ax1,...
    'xtick',1:1:length(Mcenter),...
    'xticklabel',Mcenter,...
    'projection','perspective',...
    'fontsize',8,...
    'ylim',[rmin,rmax])

ch=findall(handles.ax,'tag','haz2');
B=1;
handles.bartitle.String={...
    sprintf('Deaggregation for %s'     , handles.IM_menu.String{handles.IM_menu.Value});...
    sprintf('Hazard Level   = %4.3e'   , ch.YData(B));...
    sprintf('Return Period  = %g yr'   , handles.returnperiod(B))};

handles.bartitle2.String={...
    sprintf('Mean Distance and Magnitude:');...
    sprintf('R = %-4.3g km' , Rbar(B));...
    sprintf('M = %-4.3g'    , Mbar(B))};

ch=findall(handles.ax,'tag','line');
ch.XData = handles.im2(B)*[1 1];
ch.YData = handles.ax.YLim;
handles.Mbar = Mbar;
handles.Rbar = Rbar;
handles.popreturn.Value=B;

set (handles.figure1, 'WindowButtonMotionFcn', {@mouseMove,handles});

function popreturn_Callback(hObject, eventdata, handles)
ch=findall(handles.ax,'tag','haz2');
B=hObject.Value;
dchart=handles.dchart(:,:,B);
handles.bartitle.String={...
    sprintf('Deaggregation for %s'     , handles.IM_menu.String{handles.IM_menu.Value});...
    sprintf('Hazard Level   = %4.3e'   , ch.YData(B));...
    sprintf('Return Period  = %g yr'   , handles.returnperiod(B))};

handles.bartitle2.String={...
    sprintf('Mean Distance and Magnitude:');...
    sprintf('R = %-4.3g km' , handles.Rbar(B));...
    sprintf('M = %-4.3g'    , handles.Mbar(B))};

ch=findall(handles.ax,'tag','line');
ch.XData = handles.im2(B)*[1 1];
ch.YData = handles.ax.YLim;
handles.popreturn.Value=B;
for i=1:numel(handles.b)
    handles.b(i).ZData(2:6:end,2)=dchart(:,i);
    handles.b(i).ZData(3:6:end,2)=dchart(:,i);
    handles.b(i).ZData(:,3)=handles.b(i).ZData(:,2);
    handles.line.XData=[1 1]*handles.im2(B);
    handles.line.YData=handles.ax.YLim;
end


function defineBins_Callback(hObject, eventdata, handles)

[handles.Rbin,handles.Mbin]=setMRebins(handles.Rbin,handles.Mbin);
guidata(hObject,handles)
