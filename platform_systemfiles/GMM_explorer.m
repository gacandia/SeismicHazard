function varargout = GMM_explorer(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GMM_explorer_OpeningFcn, ...
    'gui_OutputFcn',  @GMM_explorer_OutputFcn, ...
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

function GMM_explorer_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.Exit_button.CData=double(imread('Exit.jpg'))/255;
handles.openbook.CData=double(imread('book_open.jpg'))/255;
handles.AxisScale.CData=double(imresize(imread('Ruler.jpg'),[20 20]))/255;
handles.gridmanager.CData=double(imread('Grid.jpg'))/255;
handles.epsilon = 0;

methods  = pshatoolbox_methods(1);
gmpetype = {methods.type}';
B        = strcmp(gmpetype,'regular');
handles.GMPEselect.String = {methods(B).label};
handles.ax1.Box='on';
handles.ax1.Color=[1 1 1];
handles.ax1.XGrid='on';
handles.ax1.YGrid='on';
handles.ax1.NextPlot='add';
handles.ax2.Visible='off';

% initialize data to fill plot
handles.paramlist = cell(0,2);
handles.ptrs      = zeros(0,18);
ch  = get(handles.panel2,'children'); tag  = char(ch.Tag);
handles.text = flipud(find(ismember(tag(:,1),'t')));
handles.edit = flipud(find(ismember(tag(:,1),'e')));
handles.selectedrow = [];

set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off');
handles.uitable1.Data=cell(0,2);

if nargin==4
    GMPE = varargin{1}.sys.GMPELIB;
    GMPE = GMPE(:);
    GMPE(ismember({GMPE.type},'pce')) = [];
    GMPE(ismember({GMPE.type},'udm')) = [];
    GMPE(ismember({GMPE.type},'cond'))= [];
    GMPE(ismember({GMPE.type},'frn')) = [];
    Nj = length(GMPE);
    if Nj>0
        for j=1:Nj
            gmpe = GMPE(j,:);
            handles.uitable1.Data(end+1,:)={gmpe.label,func2str(gmpe.handle)};
            
            % Builds paramlist and ptrs list
            [param,ptrs]                = mGMPEusp(gmpe);
            handles.paramlist(end+1,:) = {gmpe.label,param};
            handles.ptrs(end+1,:)      = ptrs;
        end
        handles=CellSelectAction(handles,1);
    else
        handles = mGMPEdefault(handles,ch(handles.text),ch(handles.edit));
        plotgmpe(handles);
    end
else
    handles = mGMPEdefault(handles,ch(handles.text),ch(handles.edit));
    plotgmpe(handles);
end
handles.targetIM.Value  = 1;
handles.targetIM.String = IM2str(handles.IM);

handles.xlabel=xlabel(handles.ax1,'T(s)','fontsize',10);
if handles.rad2.Value==1
    handles.targetIM.Value  = 1;
    handles.targetIM.String = IM2str(handles.IM);
    handles.ylabel=ylabel(handles.ax1,IM2str(handles.IM(1)),'fontsize',10);
else
    handles.ylabel=ylabel(handles.ax1,'Sa','fontsize',10);
end
axis(handles.ax1,'auto')
% Update handles structure
guidata(hObject, handles);
% uiwait(handles.figure1);

function varargout = GMM_explorer_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>

varargout{1} = handles.output;

% ------------ key funtions ---------------------------------------------------
function GMPEselect_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

ch=get(handles.panel2,'children');
set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off','Style','edit');
handles = mGMPEdefault(handles,ch(handles.text),ch(handles.edit));
if handles.rad2.Value==1
    if isempty(handles.IM)
        handles.targetIM.Visible='off';
        handles.text50.Visible='off';
    else
        handles.targetIM.Visible='on';
        handles.text50.Visible='on';
        handles.targetIM.Value  = 1;
        handles.targetIM.String = IM2str(handles.IM);
        handles.ylabel=ylabel(handles.ax1,IM2str(handles.IM(1)),'fontsize',10);
    end
else
    handles.ylabel=ylabel(handles.ax1,'Sa','fontsize',10);
end
plotgmpe(handles);
guidata(hObject,handles)

function GMPEselect_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------ create funtions --------------------------------------------

function Exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to Exit_button (see GCBO)

% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1)

function AxisScale_Callback(hObject, eventdata, handles)
% hObject    handle to AxisScale (see GCBO)

% handles    structure with handles and user data (see GUIDATA)
XYSCALE=[handles.ax1.XScale,handles.ax1.YScale];

switch XYSCALE
    case 'linearlinear', handles.ax1.XScale='log';
    case 'loglinear',    handles.ax1.XScale='linear'; handles.ax1.YScale='log';
    case 'linearlog',    handles.ax1.XScale='log';
    case 'loglog',       handles.ax1.XScale='linear'; handles.ax1.YScale='linear';
end

function AutoScale_Callback(hObject, eventdata, handles)
switch hObject.Value
    case 0
        prompt={'Xscale','Yscale','XLim','YLim'};
        name='Manual Scale'; numlines=1;
        XL = handles.ax1.XLim; strX = [num2str(XL(1)),'-',num2str(XL(2))];
        YL = handles.ax1.YLim; strY = [num2str(YL(1)),'-',num2str(YL(2))];
        defaultanswer={handles.ax1.XScale,handles.ax1.YScale,strX,strY};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answer)
            return
        end
        XLIM = regexp(answer{3},'\-','split'); YLIM = regexp(answer{4},'\-','split');
        handles.ax1.XScale=answer{1};
        handles.ax1.YScale=answer{2};
        handles.ax1.XLim=[eval(XLIM{1}) eval(XLIM{2})];
        handles.ax1.YLim=[eval(YLIM{1}) eval(YLIM{2})];
    case 1
        axis(handles.ax1,'auto')
end
guidata(hObject,handles)

function HoldPlot_Callback(hObject, eventdata, handles)

function OverlayImage_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 1
        D=what('GMPE_ArticleValidation');
        [filename, pathname]=uigetfile([D.path,'\*.png;*.jpge;*.jpg;*.bmp;*.emf'],'Images');
        
        if isnumeric(filename)
            return
        end
        AD=str2double(handles.ImageAlpha.String);
        I=imshow([pathname,filename],'parent',handles.ax2,'XData',[0 10],'YData',[0 10]);
        set(I,'AlphaData',AD,'tag','image');
        handles.ax1.Color='none';
        handles.ax2.Visible='off';
        handles=mGMPEfromfigures(handles,filename);
    case 0
        handles.ax1.Color=[1 1 1];
        handles.ax2.Visible='off';
end
guidata(hObject,handles)

function ImageAlpha_Callback(hObject, eventdata, handles)
AD=str2double(handles.ImageAlpha.String);
ch=findall(handles.ax2,'tag','image');
set(ch,'AlphaData',AD);

function ImageAlpha_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function File_Callback(hObject, eventdata, handles)

function Library_Callback(hObject, eventdata, handles)

function AddNew_Callback(hObject, eventdata, handles)

gmpeid = handles.GMPEselect.String{handles.GMPEselect.Value};
prompt={'Label'};
name='GMPE';
numlines=1;
defaultanswer={gmpeid};
answer=inputdlg(prompt,name,numlines,defaultanswer);

if isempty(answer)
    return
end

[param,ptrs]               = mGMPEgetparam(handles);
handles.paramlist(end+1,:) = {handles.fun,param};
handles.ptrs(end+1,:)      = ptrs;
handles.uitable1.Data(end+1,:) = {answer{1},func2str(handles.fun)};
guidata(hObject,handles)

function UpdateModel_Callback(hObject, eventdata, handles)
if isempty(handles.selectedrow)
    return
end

val = handles.selectedrow;
prompt={'Update GMPE Name'};
name='GMPE'; numlines=1;
defaultanswer={handles.uitable1.Data{val,1}};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    return
end
handles.uitable1.Data{val,1} = answer{1};
[param,ptrs]                 = mGMPEgetparam(handles);
handles.ptrs(val,:)          = ptrs;
un                           = handles.paramlist{val,2};
handles.paramlist(val,:)     = {handles.fun,un,param};
guidata(hObject,handles)

function LoadList_Callback(hObject, eventdata, handles)

function Save_Callback(hObject, eventdata, handles)

[filename, pathname] = uiputfile('*.txt','Save as');
if isnumeric(filename)
    return
end
fname = [pathname,filename];
fid = fopen(fname,'w');
list  = handles.uitable1.Data(:,1);
param = handles.paramlist;
for i=1:size(list,1)
    fprintf(fid,'gmpe %g %s\n',i,list{i});
    fprintf(fid,'@%s\n',func2str(param{i,1}));
    fprintf(fid,'%g\n',param{i,2});
    par = param{i,3};
    for j=1:length(par)
        e = par{j};
        if isnumeric(e)
            fprintf(fid,'%g\n',e);
        else
            fprintf(fid,'%s\n',e);
        end
    end
    if i<size(list,1)
        fprintf(fid,'\n');
    end
end
fclose(fid);
if ispc,winopen(fname);end

function RemoveSelection_Callback(hObject, eventdata, handles)

if isempty(handles.selectedrow)
    return
end
val                          = handles.selectedrow;
handles.uitable1.Data(val,:) = [];
handles.ptrs(val,:)          = [];
handles.paramlist(val,:)     = [];
handles.selectedrow          = [];
guidata(hObject,handles)

% ------------  edit boxes
function e1_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e2_Callback(hObject, eventdata, handles)

plotgmpe(handles);
guidata(hObject,handles)

function e2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e3_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e4_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e5_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e6_Callback(hObject, eventdata, handles)

plotgmpe(handles);
guidata(hObject,handles)

function e6_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e7_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e7_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e8_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e9_Callback(hObject, eventdata, handles)

switch handles.GMPEselect.String{handles.GMPEselect.Value}
    case 'Abrahamson Silva 2008 - NGA' % set default Ztop
        Vs30 = str2double(handles.e9.String);
        handles.e8.String=sprintf('%4.4g',Z10_default_AS08_NGA(Vs30));
end

plotgmpe(handles);
guidata(hObject,handles)

function e9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e10_Callback(hObject, eventdata, handles)
switch handles.GMPEselect.String{handles.GMPEselect.Value}
    case 'Chiou Youngs 2008 - NGA' % set default Z1.0
        Vs30 = str2double(handles.e10.String);
        %handles.e7.String=sprintf('%4.4g',exp(28.5-3.82/8*log(Vs30^8+378.8^8)));
        handles.e7.String=sprintf('%4.4g',Z10_default_AS08_NGA(Vs30));
end

plotgmpe(handles);
guidata(hObject,handles)

function e10_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e11_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e12_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e13_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e14_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e15_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e16_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e17_Callback(hObject, eventdata, handles)
plotgmpe(handles);
guidata(hObject,handles)

function e17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function gridmanager_Callback(hObject, eventdata, handles)
switch [handles.ax1.XGrid,handles.ax1.XMinorGrid]
    case 'offoff'
        handles.ax1.XGrid     ='on';  handles.ax1.XMinorGrid='on';
        handles.ax1.YGrid     ='on';  handles.ax1.YMinorGrid='on';
    case 'onon'
        handles.ax1.XGrid     ='on';  handles.ax1.XMinorGrid='off';
        handles.ax1.YGrid     ='on';  handles.ax1.YMinorGrid='off';
    case 'onoff'
        handles.ax1.XGrid     ='off';  handles.ax1.XMinorGrid='on';
        handles.ax1.YGrid     ='off';  handles.ax1.YMinorGrid='on';
    case 'offon'
        handles.ax1.XGrid     ='off';  handles.ax1.XMinorGrid='off';
        handles.ax1.YGrid     ='off';  handles.ax1.YMinorGrid='off';
end

function PlotOptions_Callback(hObject, eventdata, handles)

function openbook_Callback(hObject, eventdata, handles)

val     = handles.GMPEselect.Value;
methods = pshatoolbox_methods(1,val);
if ~isempty(methods.ref)
    try
        web(methods.ref,'-browser')
    catch
    end
end
function Help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function OpenNGADoc_Callback(hObject, eventdata, handles)
D=what('GMPE References');
open([D.path,'\NGA_Documentation.pdf'])

function grouplist_Callback(hObject, eventdata, handles)

function grouplist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uitable1_CellSelectionCallback(hObject, eventdata, handles)
if isempty(eventdata.Indices)
    return
end
ind  = eventdata.Indices(1);
handles = CellSelectAction(handles,ind);
guidata(hObject,handles)

function handles=CellSelectAction(handles,ind)

vals = handles.ptrs(ind,:);
handles.GMPEselect.Value = vals(end);
ch=get(handles.panel2,'children');
set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off','Style','edit');
handles = mGMPEdefault(handles,ch(handles.text),ch(handles.edit));

paramlist= handles.paramlist{ind,2};
for i=1:length(paramlist)
    fn = ['e',num2str(i)];
    if isnumeric(paramlist{i})
        handles.(fn).String=num2str(paramlist{i});
    else
        handles.(fn).Value=vals(i);
    end
end
plotgmpe(handles);
handles.selectedrow=ind;

function rad1_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 0,handles.rad2.Value=1; handles.text50.Visible='on';  handles.targetIM.Visible='on';
    case 1,handles.rad2.Value=0; handles.text50.Visible='off';  handles.targetIM.Visible='off';
end
plotgmpe(handles);
if handles.rad2.Value==1
    if isempty(handles.IM)
        handles.targetIM.Visible='off';
        handles.text50.Visible='off';
    else
        handles.targetIM.Visible='on';
        handles.text50.Visible='on';
        handles.targetIM.Value  = 1;
        handles.targetIM.String = IM2str(handles.IM);
        handles.ylabel=ylabel(handles.ax1,IM2str(handles.IM(1)),'fontsize',10);
    end
else
    handles.ylabel=ylabel(handles.ax1,'Sa','fontsize',10);
end
guidata(hObject,handles)

function rad2_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 0,handles.rad1.Value=1; handles.text50.Visible='off'; handles.targetIM.Visible='off';
    case 1,handles.rad1.Value=0; handles.text50.Visible='on';  handles.targetIM.Visible='on';
end
plotgmpe(handles);
if handles.rad2.Value==1
    if isempty(handles.IM)
        handles.targetIM.Visible='off';
        handles.text50.Visible='off';
    else
        handles.targetIM.Visible='on';
        handles.text50.Visible='on';
        handles.targetIM.Value  = 1;
        handles.targetIM.String = IM2str(handles.IM);
        handles.ylabel=ylabel(handles.ax1,IM2str(handles.IM(1)),'fontsize',10);
    end
else
    handles.ylabel=ylabel(handles.ax1,'Sa','fontsize',10);
end
guidata(hObject,handles)

function targetIM_Callback(hObject, eventdata, handles)
plotgmpe(handles);
handles.ylabel=ylabel(handles.ax1,IM2str(handles.IM(hObject.Value)),'fontsize',10);
guidata(hObject,handles)

function targetIM_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uitable1_CellEditCallback(hObject, eventdata, handles)

guidata(hObject,handles)

function UndockAxis_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax1)

function showepsilon_Callback(hObject, eventdata, handles)

prompt={'Enter epsilon values'};
name='epsilon';
numlines=[1 50];
defaultanswer={strtrim(sprintf('%g ',handles.epsilon'))};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    epsilon = 0;
else
    epsilon =eval(['[',answer{1},']']);
end
handles.epsilon = epsilon;
plotgmpe(handles);
guidata(hObject,handles)


% --------------------------------------------------------------------
function uitable1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
