function varargout = DispDeaggMR(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DispDeaggMR_OpeningFcn, ...
    'gui_OutputFcn',  @DispDeaggMR_OutputFcn, ...
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

function DispDeaggMR_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.Exit_button.CData  = double(imread('exit.jpg'))/255;

handles.sys    = varargin{1};
handles.model  = varargin{2};
handles.opt    = varargin{3};
handles.h      = varargin{4};
handles.T1     = varargin{5};
handles.T2     = varargin{6};
handles.T3     = varargin{7};
handles.paramPSDA  = varargin{8};
handles.dlist  = varargin{9};
[handles.branches,handles.IJK]=main_psda(handles.T1,handles.T2,handles.T3);

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

Nbranches = size(handles.IJK,1);
str = cell(1,Nbranches);
dlist = handles.dlist(:)';
for i=dlist
   str{i} = sprintf('PSDA %i',i); 
end
handles.menu_branch.String = str;
handles.menu_branch.Value  = 1;
handles.menu_site.String   = handles.h.p(:,1);
handles.menu_site.Value    = 1;

handles = drawbars(handles);
xlabel(handles.ax,'d(m)');
ylabel(handles.ax,'Exceedance Rate');
handles.bartitle.String='';
handles.bartitle2.String='';
rotate3d(handles.ax1)

plot(handles.ax,nan*[1 1],handles.ax.YLim,'-','tag','haz1');
plot(handles.ax,nan*[1 1],handles.ax.YLim,'.' ,'tag','haz2');
plot(handles.ax,nan*[1 1],handles.ax.YLim,'k:','tag','line');

guidata(hObject, handles);

function varargout = DispDeaggMR_OutputFcn(hObject, eventdata, handles)
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

function popreturn_Callback(hObject, eventdata, handles)

function menu_branch_Callback(hObject, eventdata, handles)

function menu_site_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>

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
home
deaggD  = runDeaggAnalysis(handles);
if isempty(deaggD)
    return
end
dchart  = DchartPSDA(deaggD,handles.Mbin,handles.Rbin);
Mcenter = mean(handles.Mbin,2);
Rcenter = mean(handles.Rbin,2);
rmin    = handles.Rbin(1);
rmax    = handles.Rbin(end);
handles.b=bar3(handles.ax1,Rcenter,dchart);

xlabel(handles.ax1,'Magnitude');
ylabel(handles.ax1,'R (km)');
zlabel(handles.ax1,'D-Deagg')
set(handles.ax1,...
    'xtick',1:1:length(Mcenter),...
    'xticklabel',Mcenter,...
    'projection','perspective',...
    'fontsize',8,...
    'ylim',[rmin,rmax])
guidata(hObject,handles)

function deaggD = runDeaggAnalysis(handles)
% preparacion de calculos
Tr            = str2double(handles.popreturn.String{handles.popreturn.Value});
b             = regexp(handles.menu_branch.String{handles.menu_branch.Value},'\ ','split');
branch_ptr    = str2double(b{2});
site_ptr      = handles.menu_site.Value;
IND           = handles.IJK(branch_ptr,:);
handles.T1    = handles.T1(IND(1),:);
handles.T2    = handles.T2(IND(2),:);
handles.T3    = handles.T3(IND(3),:);
handles.model = handles.model(IND(1));
handles.h.p   = handles.h.p(site_ptr,:);

% Run Seismic Hazard and Displacement Hazard
d                   = logsp(1,200,15);
handles.paramPSDA.d = d;
handles.haz         = haz_PSDA(handles);
handles             = runPSDA_regular(handles);

lambdaD       = permute(handles.lambdaD,[2 3 1]);
mechs  = strrep({handles.model.source.mechanism},'shallowcrustal','crustal');
m1        = strcmp(mechs,'system');
m2        = strcmp(mechs,'interface');
m3        = strcmp(mechs,'intraslab');
m4        = strcmp(mechs,'slab');
m5        = strcmp(mechs,'crustal');
m6        = strcmp(mechs,'shallowcrustal');
m7        = strcmp(mechs,'fault');
m8        = strcmp(mechs,'grid');
lambdaD   = [nansum(lambdaD,2),nansum(lambdaD(:,m1),2) nansum(lambdaD(:,m2),2) nansum(lambdaD(:,m3),2) nansum(lambdaD(:,m4),2) nansum(lambdaD(:,m5),2) nansum(lambdaD(:,m6),2) nansum(lambdaD(:,m7),2) nansum(lambdaD(:,m8),2)];
NOTNAN    = (sum(lambdaD,1)>0);
lambdaD   = lambdaD(:,NOTNAN);
mechs     = {'total','system','interface','intraslab','slab','crustal','shallowcrustal','fault','grid'};
str       = mechs(NOTNAN);

delete(findall(handles.ax,'type','line'))
handles.ax.XLimMode='auto';
handles.ax.YLimMode='auto';
handles.ax.ColorOrderIndex=1;
plot(handles.ax,d,lambdaD,'.-')
L=legend(handles.ax,str);L.Box='off';L.Location='SouthWest';
deaggD         = [];
lambdaD        = lambdaD(:,1);
if and(min(lambdaD)<=1/Tr,1/Tr<max(lambdaD))
    dtr        = exp(interp1(log(lambdaD),log(d),log(1/Tr),'pchip'));
    handles.d  = dtr;
    deaggD     = DeaggPSDA_regular(handles);

    XL = handles.ax.XLim; plot(handles.ax,XL,1/Tr*[1 1],'k--','handlevisibility','off')
    YL = handles.ax.YLim; plot(handles.ax,dtr*[1 1],YL,'k--','handlevisibility','off')
    plot(handles.ax,dtr,1/Tr,'b.','markersize',10,'handlevisibility','off')
    handles.ax.XLim=XL;
    handles.ax.YLim=YL;
else
    warndlg('Displacement Hazard Out of Bounds')
end

function Undockdeagg_Callback(hObject, eventdata, handles)

figure2clipboard_uimenu([],[],handles.ax1)
