function varargout = DeaggregationMRe(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DeaggregationMRe_OpeningFcn, ...
    'gui_OutputFcn',  @DeaggregationMRe_OutputFcn, ...
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

function DeaggregationMRe_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.Exit_button.CData  = double(imread('exit.jpg'))/255;
handles.activateRot3D.CData  = double(imresize(imread('Rot3D.jpg'),[20 20]))/255;
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
rmin  = 0;  rmax  = 600; dr    = 60;
handles.Rbin      = [(rmin:dr:rmax-dr)',(rmin:dr:rmax-dr)'+dr];
mmin  = 5;  mmax  = 9; dm    = 0.2;
handles.Mbin      = [(mmin:dm:mmax-dm)',(mmin:dm:mmax-dm)'+dm];
emin  = -2; emax  = 2; de    = 1;
handles.Ebin      = [[-inf emin];(emin:de:emax-de)',(emin:de:emax-de)'+de;[emax,inf]];
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
handles = drawlegend(handles);
handles.bartitle.String='';
handles.bartitle2.String='';
xlabel(handles.ax,handles.IM_menu.String{1},'fontsize',10);
ylabel(handles.ax,'Exceedance Rate','fontsize',10);
% str = sprintf('%s | %s | %s',handles.model(1).id1,handles.model(1).id2,handles.model(1).id3);
% title(handles.ax,str,'fontsize',9,'fontweight','normal','tag','axtitle')

plot(handles.ax,nan*[1 1],handles.ax.YLim,'.-','tag','haz1');
plot(handles.ax,nan*[1 1],handles.ax.YLim,'o' ,'tag','haz3');
plot(handles.ax,nan*[1 1],handles.ax.YLim,'k:','tag','line');

guidata(hObject, handles);

function varargout = DeaggregationMRe_OutputFcn(hObject, eventdata, handles)
varargout{1} = [];

% -------- FILE MENU ------------------------------------------------------

function File_Callback(hObject, eventdata, handles)

function ExportRM_Callback(hObject, eventdata, handles)

if ~isfield(handles,'deagg1')
    return
end

[FileName,PathName] =  uiputfile('*.out','Save Hazard Deaggregation Analysis');
if isnumeric(FileName)
    return
end

fid      = fopen([PathName,FileName],'w');
fprintf(fid,'Hazard Deagregation\n');
fprintf(fid,'-------------------\n');
branch  = handles.menu_branch.Value;
site    = handles.menu_site.Value;
period  = handles.IM_menu.Value;
T       = str2double(handles.IM_menu.String(period,:));
lambda  = handles.lambda0(site,:,period,branch);
Sa      = handles.im;
percent = 10*ones(1,length(Sa));
years   = -log(1-percent/100)./lambda;
data0   = [lambda;1./lambda;Sa;percent;years];
Mdeag   = permute(sum(handles.deagg1,1),[2 3 1]);
data    = [handles.Mbin,mean(handles.Mbin,2),Mdeag];
nrow    = size(data,2);

ch = findall(handles.ax,'tag','axtitle');
fprintf(fid,'Logic Tree Branch: %g (%s)\n',branch,ch.String);
fprintf(fid,'Site             : %g (Lat: %g - Lon: %g )\n',site,handles.h.p(site,1),handles.h.p(site,2));
fprintf(fid,'Spectral Period  : %g sec\n\n',T);

fmt = ['%-31s',repmat('%-16e',1,nrow-3),'\n'];  fprintf(fid,fmt,'                Annual Hazard',data0(1,:));
fmt = ['%-31s',repmat('%-16g',1,nrow-3),'\n'];  fprintf(fid,fmt,'                Return Period',data0(2,:));
fmt = ['%-31s',repmat('%-16g',1,nrow-3),'\n'];  fprintf(fid,fmt,'                Sa(g)        ',data0(3,:));
fmt = ['%-31s',repmat('%-16g',1,nrow-3),'\n'];  fprintf(fid,fmt,'                % Exceedance ',data0(4,:));
fmt = ['%-31s',repmat('%-16g',1,nrow-3),'\n\n']; fprintf(fid,fmt,'                Time(Years)  ',data0(5,:));

fmt =['%-8s','%-8s','%-15s','%-50s','\n'];
fprintf(fid,fmt,'From','To','Center','Deagregation Values for Magnitudes');

fmt = ['%-8g','%-8g','%-15g',repmat('%-16e',1,nrow-3),'\t'];
for ii = 1:size(data,1)
    fprintf(fid,fmt,data(ii,:));
    fprintf(fid,'\n');
end
fprintf(fid,'\n\n');
fclose(fid);
open([PathName,FileName])

function Save_Full_Callback(hObject, eventdata, handles)

[FileName,PathName] =  uiputfile('*.mat','Save Hazard Deaggregation Analysis');
if isnumeric(FileName)
    return
end

lambda0 = handles.lambda0; %#ok<NASGU>
deagg   = handles.deagg;   %#ok<NASGU>
save([PathName,FileName],'lambda0','deagg')

function Exit_Callback(hObject, eventdata, handles)
close(handles.figure1)

function Exit_button_Callback(hObject, eventdata, handles)
close(handles.figure1)

% -------- EDIT MENU ------------------------------------------------------

function Edit_Callback(hObject, eventdata, handles)

% function autofix_Callback(hObject, eventdata, handles)
% switch handles.autofix.Checked
%     case 'on', handles.autofix.Checked='off';
%     case 'off',handles.autofix.Checked='on';
% end

function defineMRebins_Callback(hObject, eventdata, handles)

[handles.Rbin,handles.Mbin,handles.Ebin]=setMRebins(handles.Rbin,handles.Mbin,handles.Ebin);
handles = drawbars(handles);
handles = drawlegend(handles);
guidata(hObject,handles)

% -------- PANNEL OPTIONS -------------------------------------------------
function popreturn_Callback(hObject, eventdata, handles)

function menu_branch_Callback(hObject, eventdata, handles)

function menu_source_Callback(hObject, eventdata, handles)

function menu_site_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>

function IM_menu_Callback(hObject, eventdata, handles)

% --------- AUXILIARY FUNCTIONS -------------------------------------------

function menu_branch_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function mouseClick(hObject,eventdata,handles)

x      = getAbsCoords(handles.ax);
IM_ptr = interp1(handles.im,(1:length(handles.im))',x,'nearest','extrap');
ch     = findall(handles.ax,'tag','hazardcurve');
im     = handles.im(IM_ptr);
lam    = round(1/ch.YData(IM_ptr));
handles.line.XData = im*[1 1];
handles.line.YData = handles.ax.YLim;

function [x, y] = getAbsCoords(h_ax)
crd = get(h_ax, 'CurrentPoint');
x = crd(2,1);
y = crd(2,2);

function run_Callback(hObject, eventdata, handles)

IM_ptr     = handles.IM_menu.Value;
ncols      = size(handles.opt.im,2);
if ncols==1
    im1 = handles.opt.im;
else
    im1 = handles.opt.im(:,IM_ptr);
end

ret_ptr    = handles.popreturn.Value;
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

logyy   = log(1./handles.returnperiod);
im3     = exp(interp1(xData,yData,logyy(ret_ptr),'pchip'));
deagg3  = runhazard3(im3,IM,site,Vs30,opt,model,Nsource,1,handles.Ebin);
deagg3  = vertcat(deagg3{1,1,1,:});

deagg3NC    = deagg3(:,5)*1/sum(deagg3(:,5))*1/handles.returnperiod(ret_ptr); % small correction
deagg3(:,5) = deagg3(:,5)*1/sum(deagg3(:,5))*1/handles.returnperiod(ret_ptr); % small correction

haz     = 1/handles.returnperiod(ret_ptr);
MRHEbar = sum(bsxfun(@times,deagg3(:,1:4),deagg3(:,5)),1)/haz;

handles.bartitle.String={...
    sprintf('Deaggregation for %s'     , handles.IM_menu.String{IM_ptr});...
    sprintf('Hazard Level   = %4.3e'   , haz);...
    sprintf('Return Period  = %g yr'   , 1/haz)};

handles.bartitle2.String={...
    sprintf('Mean R Zhyp M e:');...
    sprintf('R = %-4.3g km   Zhyp = %-4.3g km' , MRHEbar(2), MRHEbar(3));...
    sprintf('M = %-4.3g      e    = %4.3g'    , MRHEbar(1),MRHEbar(4))};

data2clipboard_uimenu([],[],MRHEbar)
ch=findall(handles.ax,'tag','haz1'); ch.XData = im1; ch.YData = lambda1;
ch=findall(handles.ax,'tag','haz3'); ch.XData = im3; ch.YData = sum(deagg3NC);
ch=findall(handles.ax,'tag','line'); ch.XData = im3*[1 1]; ch.YData = handles.ax.YLim;
handles = run_funcMRe(handles,deagg3);
guidata(hObject,handles)

function handles = drawbars(handles)

Rbin = handles.Rbin; Rwin = 1/2*(Rbin(:,2)+Rbin(:,1));
Mbin = handles.Mbin; Mwin = 1/2*(Mbin(:,2)+Mbin(:,1));
NR   = size(handles.Rbin,1);
NM   = size(handles.Mbin,1);
NE   = size(handles.Ebin,1);

dr = Rwin(2)-Rwin(1);
handles.ax1.NextPlot='replace';
btest=bar3(handles.ax1,Rwin,nan(NR,NM));
xlabel(handles.ax1,'Magnitude');
ylabel(handles.ax1,'R (km)');
zlabel(handles.ax1,'Hazzard Deagg');
set(handles.ax1,...
    'xtick',1:1:length(Mwin),...
    'xticklabel',Mwin,...
    'projection','perspective',...
    'ylim',[Rwin(1)-dr/2,Rwin(end)+dr/2],...
    'fontsize',8)
delete(btest);
handles.ax1.NextPlot='add';

b     = cell(NM,1);
for j=1:NM
    b{j} = bar3(handles.ax1,Rwin,nan(NR,NE),'stacked');
end

for i=1:NM
    for j=1:length(b{i})
        b{i}(j).XData=b{i}(j).XData+i-1;
        b{i}(j).FaceAlpha=0.7;
        
    end
end
handles.b=b;
ZLIM = max(handles.ax1.ZLim,0);
handles.ax1.ZLim=ZLIM;

function handles = drawlegend(handles)

Ebin = handles.Ebin;
NE   = size(handles.Ebin,1);

col  = parula(NE);
colormap(handles.ax1,col);

handles.ax3.YLim=[0 12];
handles.ax3.XLim=[0 0.7];
handles.ax3.Color='none';
handles.ax3.XColor='none';
handles.ax3.YColor='none';

delete(findall(handles.ax3,'tag','leg'));

for i=1:NE
    x = [0 0.2 0.2 0];
    y = [i-1 i-1 i-0.6 i-0.6]+12-NE;
    vert = [x;y]';
    patch('parent',handles.ax3,...
        'vertices',vert,...
        'faces',1:4,...
        'facecolor',col(i,:),...
        'facealpha',0.7,...
        'tag','leg')
    if isinf(Ebin(i,1))
        str = sprintf('e < %2.1f',Ebin(i,2));
    elseif isinf(Ebin(i,2))
        str = sprintf('%2.1f <  e',Ebin(i,1));
    else
        str = sprintf('%2.1f <  e < %2.1f',Ebin(i,1),Ebin(i,2));
    end
    text(handles.ax3,0.25,(i-0.8)+12-NE,str,'tag','leg','fontsize',8)
end

function activateRot3D_Callback(hObject, eventdata, handles)

if ~isfield(handles,'rot3D')
    handles.rot3D = rotate3d(handles.ax1);
    handles.rot3D.Enable='on';
else
    switch handles.rot3D.Enable
        case 'on', handles.rot3D.Enable='off';
        case 'off',handles.rot3D.Enable='on';
    end
end
guidata(hObject,handles)
