function varargout = DeaggregationUSGS(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DeaggregationUSGS_OpeningFcn, ...
    'gui_OutputFcn',  @DeaggregationUSGS_OutputFcn, ...
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

function DeaggregationUSGS_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
handles.Exit_button.CData  = double(imread('exit.jpg'))/255;
handles.activateRot3D.CData  = double(imresize(imread('Rot3D.jpg'),[20 20]))/255;
ihandles=varargin{1};

handles.menu_branch.String = {ihandles.model.id};
handles.menu_branch.Value  = 1;
handles.menu_source.String = ['all sources',{ihandles.model(1).source.label}];
handles.menu_source.Value  = 1;
handles.menu_site.String   = ihandles.h.p(:,1);
handles.menu_site.Value    = ihandles.site_selection(1);
handles.h                  = ihandles.h;
handles.opt                = ihandles.opt;
handles.model              = ihandles.model;
handles.poolsize           = ihandles.poolsize;
handles.IM_menu.String     = handles.opt.IM;
handles.im                 = ihandles.opt.im;
handles.MRE                = ihandles.MRE;
handles.deagg              = ihandles.deagg;


% Build interface to adjust this piece of code
%--------------------------------------------------------------------------
rmin  = 0;  rmax  = 200; dr    = 10;
handles.Rbin      = [(rmin:dr:rmax-dr)',(rmin:dr:rmax-dr)'+dr];
mmin  = 5; mmax  = 9; dm    = 0.2;
handles.ewin.String        = '-5 5';%sprintf('%g %g',handles.opt.Epsilon(1),handles.opt.Epsilon(2));
handles.Mbin      = [(mmin:dm:mmax-dm)',(mmin:dm:mmax-dm)'+dm];
handles.returnperiod = [30;43;72;108;144;224;336;475;712;975;1462;1950;2475;3712;4975;7462;9950;19900];
%--------------------------------------------------------------------------

handles = drawlegend(handles);
handles = drawbars(handles);
site    = handles.menu_site.Value;
source  = handles.menu_source.Value;
period  = handles.IM_menu.Value;
branch  = handles.menu_branch.Value;

x       = handles.im;

switch source
    case 1
        y1  = nansum(handles.MRE(site,:,period,:,branch),4);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
        
    otherwise
        y1  = handles.MRE(site,:,period,source+1,branch);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
end

y2      = nan(size(y1));

gData   = ~isnan(y1);
x475    = exp(interp1(log(y1(gData)),log(x(gData)),log(1/475),'pchip'));
handles.RP.String=475;

handles.ax.NextPlot='add';
hc=plot(handles.ax,x,y1,'.-','tag','hazardcurve');
hk=plot(handles.ax,x,y2,'.-','tag','hazardcheck');
handles.ax.XScale='log';
handles.ax.YScale='log';
xlabel(handles.ax,handles.IM_menu.String{1},'fontsize',10);
ylabel(handles.ax,'Exceedance Rate','fontsize',10);


handles.line = plot(handles.ax,x475*[1 1],handles.ax.YLim,'k:');
handles.bartitle.String='';
set (hc        , 'ButtonDownFcn', {@mouseClick,handles});
set (hk        , 'ButtonDownFcn', {@mouseClick,handles});
set (handles.ax, 'ButtonDownFcn', {@mouseClick,handles});
% rotate3d(handles.ax1)
guidata(hObject, handles);

function varargout = DeaggregationUSGS_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

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
MRE  = handles.lambda0(site,:,period,branch);
Sa      = handles.im;
percent = 10*ones(1,length(Sa));
years   = -log(1-percent/100)./MRE;
data0   = [MRE;1./MRE;Sa;percent;years];
Mdeag   = permute(sum(handles.deagg1,1),[2 3 1]);
data    = [handles.Mbin,mean(handles.Mbin,2),Mdeag];
nrow    = size(data,2);

ch = findall(handles.ax,'tag','axtitle');
fprintf(fid,'Logic Tree Branch: %g (%s)\n',branch,ch.String);
fprintf(fid,'Site             : %g (Lat: %g - Lon: %g )\n',site,handles.h.p{site,2},handles.h.p{site,3});
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

function autofix_Callback(hObject, eventdata, handles)
switch handles.autofix.Checked
    case 'on', handles.autofix.Checked='off';
    case 'off',handles.autofix.Checked='on';
end

function EditBins_Callback(hObject, eventdata, handles)

prompt={'Distance dr:','Magnitude dm:','Epsilon deps:'};
name='Bins';
numlines=1;
defaultanswer={num2str(handles.dr),num2str(handles.dm),num2str(handles.de)};

answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    return
end
handles.dr=str2double(answer{1});
handles.dm=str2double(answer{2});
handles.de=str2double(answer{3});
guidata(hObject,handles)

% -------- PANNEL OPTIONS -------------------------------------------------

function menu_branch_Callback(hObject, eventdata, handles)

branch = handles.menu_branch.Value;
source = handles.menu_source.Value;
site   = handles.menu_site.Value;
period = handles.IM_menu.Value;
ch=findall(handles.ax,'tag','hazardcurve');

switch source
    case 1
        y1  = nansum(handles.MRE(site,:,period,:,branch),4);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
        ch.YData = y1;
    otherwise
        y1  = handles.MRE(site,:,period,source-1,branch);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
        ch.YData = y1;
end

ch=findall(handles.ax,'tag','hazardcheck');
ch.YData(:)=nan;
if isfield(handles,'deagg1')
    handles=rmfield(handles,'deagg1');
end
ch = findall(handles.ax,'tag','axtitle');
str1 = handles.model(branch).id1;
str2 = handles.model(branch).id2;
str3 = handles.model(branch).id3;
ch.String = [str1,' | ',str2,' | ',str3];
handles = drawbars(handles);
handles.line.YData(:)=nan;
handles.bartitle.String='';
% set (handles.figure1, 'WindowButtonMotionFcn', {@mouseMove,handles});
guidata(hObject,handles);

function menu_source_Callback(hObject, eventdata, handles)
branch = handles.menu_branch.Value;
source = handles.menu_source.Value;
site   = handles.menu_site.Value;
period = handles.IM_menu.Value;
ch=findall(handles.ax,'tag','hazardcurve');

switch source
    case 1
        y1  = nansum(handles.MRE(site,:,period,:,branch),4);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
        ch.YData = y1;
    otherwise
        y1  = handles.MRE(site,:,period,source-1,branch);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
        ch.YData = y1;
end

ch=findall(handles.ax,'tag','hazardcheck');
ch.YData(:)=nan;
if isfield(handles,'deagg1')
    handles=rmfield(handles,'deagg1');
end
ch = findall(handles.ax,'tag','axtitle');
str1 = handles.model(branch).id1;
str2 = handles.model(branch).id2;
str3 = handles.model(branch).id3;
ch.String = [str1,' | ',str2,' | ',str3];
handles = drawbars(handles);
handles.line.YData(:)=nan;
handles.bartitle.String='';
% set (handles.figure1, 'WindowButtonMotionFcn', {@mouseMove,handles});
guidata(hObject,handles);

function menu_source_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function menu_site_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
branch = handles.menu_branch.Value;
source = handles.menu_source.Value;
site   = handles.menu_site.Value;
period = handles.IM_menu.Value;
ch=findall(handles.ax,'tag','hazardcurve');
switch source
    case 1
        y1  = nansum(handles.MRE(site,:,period,:,branch),4);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
        ch.YData = y1;
    otherwise
        y1  = handles.MRE(site,:,period,source-1,branch);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
        ch.YData = y1;
end

ch=findall(handles.ax,'tag','hazardcheck');
ch.YData(:)=nan;
if isfield(handles,'deagg1')
    handles=rmfield(handles,'deagg1');
end
% ch = findall(handles.ax,'tag','axtitle');
% str1 = handles.model(branch).id1;
% str2 = handles.model(branch).id2;
% str3 = handles.model(branch).id3;
% ch.String = [str1,' | ',str2,' | ',str3];
handles.line.YData(:)=nan;
handles.bartitle.String='';

hc=findall(handles.ax,'tag','hazardcurve');
hk=findall(handles.ax,'tag','hazardcheck');
set (handles.ax, 'ButtonDownFcn', {@mouseClick,handles});
set (hc        , 'ButtonDownFcn', {@mouseClick,handles});
set (hk        , 'ButtonDownFcn', {@mouseClick,handles});

handles = drawbars(handles);
guidata(hObject,handles);

function IM_menu_Callback(hObject, eventdata, handles)
branch = handles.menu_branch.Value;
source = handles.menu_source.Value;
site   = handles.menu_site.Value;
period = handles.IM_menu.Value;
ch=findall(handles.ax,'tag','hazardcurve');
switch source
    case 1
        y1  = nansum(handles.MRE(site,:,period,:,branch),4);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
        ch.YData = y1;
    otherwise
        y1  = handles.MRE(site,:,period,source-1,branch);
        y1  = y1(:);
        y1(or(1./y1<1,1./y1>20000))=nan;
        ch.YData = y1;
end
ch=findall(handles.ax,'tag','hazardcheck');
ch.YData(:)=nan;
if isfield(handles,'deagg1')
    handles=rmfield(handles,'deagg1');
end
ch = findall(handles.ax,'tag','axtitle');
str1 = handles.model(branch).id1;
str2 = handles.model(branch).id2;
str3 = handles.model(branch).id3;
ch.String = [str1,' | ',str2,' | ',str3];
handles.line.YData(:)=nan;
handles.bartitle.String='';
xlabel(handles.ax,handles.IM_menu.String{handles.IM_menu.Value},'fontsize',10)
% set (handles.ax, 'ButtonDownFcn', {@mouseMove,handles});
handles = drawbars(handles);
guidata(hObject,handles);

% --------- AUXILIARY FUNCTIONS -------------------------------------------

function IM_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function menu_branch_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function mouseClick(hObject,eventdata,handles)

ch     = findall(handles.ax,'tag','hazardcurve');
gData  = ~isnan(ch.YData);
x      = ch.XData(gData);
y      = ch.YData(gData);
im     = getAbsCoords(handles.ax);
RP     = 1/exp(interp1(log(x),log(y),log(im),'pchip'));
lam    = 1./RP;
ch     = findall(handles.ax,'tag','hazardcurve');
gData  = ~isnan(ch.YData);
im     = exp(interp1(log(ch.YData(gData)),log(ch.XData(gData)),log(lam)));
handles.RP.String=sprintf('%i',round(RP));
handles.line.XData = im*[1 1];
handles.line.YData = handles.ax.YLim;

function [x, y] = getAbsCoords(h_ax)
crd = get(h_ax, 'CurrentPoint');
x = crd(2,1);
y = crd(2,2);

% --------------------------------------------------------------------

function run_Callback(hObject, eventdata, handles)

handles = drawlegend(handles);
handles = drawbars(handles);
handles = run_DeaggUSGS(handles);
guidata(hObject,handles)

function handles = drawbars(handles)

% info = getbins(handles);
Rwin = mean(handles.Rbin,2);
Mwin = mean(handles.Mbin,2);
NR   = length(Rwin);
NM   = length(Mwin);
NE   = 1;

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

if NE==1
    FACEALPHA=0.2;
else
    FACEALPHA=0.7;
end

for i=1:NM
    for j=1:length(b{i})
        b{i}(j).XData=b{i}(j).XData+i-1;
        b{i}(j).FaceAlpha=FACEALPHA;
        
    end
end
handles.b=b;
ZLIM = max(handles.ax1.ZLim,0);
handles.ax1.ZLim=ZLIM;

function handles = drawlegend(handles)

info.NE = 1;
info.Ebin = [-5 5];
col  = gray(info.NE);
colormap(handles.ax1,col);

handles.ax3.YLim=[0 12];
handles.ax3.XLim=[0 0.7];
handles.ax3.Color='none';
handles.ax3.XColor='none';
handles.ax3.YColor='none';

delete(findall(handles.ax3,'tag','leg'));

if info.NE==1
    FACEALPHA=0.2;
else
    FACEALPHA=0.7;
end

for i=1:info.NE
    x = [0 0.2 0.2 0];
    y = [i-1 i-1 i-0.6 i-0.6]+12-info.NE;
    vert = [x;y]';
    patch('parent',handles.ax3,...
        'vertices',vert,...
        'faces',1:4,...
        'facecolor',col(i,:),...
        'facealpha',FACEALPHA,...
        'tag','leg')
    str = sprintf('%2.1f <  e < %2.1f',info.Ebin(i,1),info.Ebin(i,2));
    text(handles.ax3,0.25,(i-0.8)+12-info.NE,str,'tag','leg','fontsize',8)
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

function RP_Callback(hObject, eventdata, handles)

ch       = findall(handles.ax,'tag','hazardcurve');
gData    = ~isnan(ch.YData);
lam      = 1/str2double(hObject.String);
im       = interp1(ch.YData(gData),ch.XData(gData),lam);
handles.line.XData = im*[1 1];

function RP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ax_ButtonDownFcn(hObject, eventdata, handles)
