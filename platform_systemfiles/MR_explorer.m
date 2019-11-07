function varargout = MR_explorer(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MR_explorer_OpeningFcn, ...
    'gui_OutputFcn',  @MR_explorer_OutputFcn, ...
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

function MR_explorer_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.Exit_button.CData=double(imread('Exit.jpg'))/255;
handles.openbook.CData=double(imread('book_open.jpg'))/255;
handles.AxisScale.CData=double(imresize(imread('Ruler.jpg'),[20 20]))/255;
handles.gridmanager.CData=double(imread('Grid.jpg'))/255;

handles.xlabel=xlabel(handles.ax1,'Magnitude','fontsize',10);
handles.ylabel=ylabel(handles.ax1,'Magnitude pdf','fontsize',10);

methods = pshatoolbox_methods(2);
handles.MRselect.String = {methods.label};

handles.ax1.Box='on';
handles.ax1.Color=[1 1 1];
handles.ax1.XGrid='on';
handles.ax1.YGrid='on';
handles.ax1.NextPlot='add';

% initialize data to fill plot
handles.paramlist = cell(0,2);
handles.ptrs      = zeros(0,15);
ch  = get(handles.panel2,'children'); tag  = char(ch.Tag);
handles.text = flipud(find(ismember(tag(:,1),'t')));
handles.edit = flipud(find(ismember(tag(:,1),'e')));
handles.selectedrow = [];

set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off');
handles.uitable1.Data=cell(0,2);

if nargin==4
    branch = 1;
    model = varargin{1}.model(branch);
    handles.mu    = varargin{1}.opt.ShearModulus;
    Nsources = length(model.source);
    Areas = nan(Nsources,1);
    for j=1:Nsources
        source = model.source(j);
        Areas(j)=source.geom.Area;
        handles.uitable1.Data(end+1,:)={source.mscl.source,func2str(source.mscl.handle)};
        
        % Builds paramlist and ptrs list
        [param,ptrs]               = mMRparam(handles,source);
        handles.paramlist(end+1,:) = {source.label,param};
        handles.ptrs(end+1,:)      = ptrs;
    end
    handles.Areas=Areas;
    handles = CellSelectAction(handles,1);
    handles.AddNew.Enable='off';
else
    handles = mMRdefault(handles,ch(handles.text),ch(handles.edit));
    plotmrmodel(handles);
end

axis(handles.ax1,'auto')
guidata(hObject, handles);
% uiwait(handles.figure1);

function varargout = MR_explorer_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
varargout{1} = handles.output;

% ------------ key funtions ---------------------------------------------------
function MRselect_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

ch=get(handles.panel2,'children');
set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off','Style','edit');

handles = mMRdefault(handles,ch(handles.text),ch(handles.edit));
plotmrmodel(handles);
guidata(hObject,handles)

function MRselect_CreateFcn(hObject, eventdata, handles)

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
        XL = handles.ax1.XLim; strX = [num2str(XL(1)),' ',num2str(XL(2))];
        YL = handles.ax1.YLim; strY = [num2str(YL(1)),' ',num2str(YL(2))];
        defaultanswer={handles.ax1.XScale,handles.ax1.YScale,strX,strY};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answer)
            return
        end
        XLIM = regexp(answer{3},'\s','split'); YLIM = regexp(answer{4},'\s','split');
        handles.ax1.XScale=answer{1};
        handles.ax1.YScale=answer{2};
        handles.ax1.XLim=[eval(XLIM{1}) eval(XLIM{2})];
        handles.ax1.YLim=[eval(YLIM{1}) eval(YLIM{2})];
    case 1
        axis(handles.ax1,'auto')
end
guidata(hObject,handles)

function HoldPlot_Callback(hObject, eventdata, handles)

function File_Callback(hObject, eventdata, handles)

function Library_Callback(hObject, eventdata, handles)

function AddNew_Callback(hObject, eventdata, handles)

msclid = handles.MRselect.String{handles.MRselect.Value};
prompt={'Label'};
name='mscl';
numlines=1;
defaultanswer={msclid};
answer=inputdlg(prompt,name,numlines,defaultanswer);

if isempty(answer)
    return
end

[param,ptrs]               = mMRgetparam(handles);
handles.paramlist(end+1,:) = {handles.fun,param};
handles.ptrs(end+1,:)      = ptrs;
handles.uitable1.Data(end+1,:) = {answer{1},func2str(handles.fun)};
guidata(hObject,handles)

function UpdateModel_Callback(hObject, eventdata, handles)
if isempty(handles.selectedrow)
    return
end

val = handles.selectedrow;
prompt={'Update Magnitude Relation Name'};
name='MSCL'; numlines=1;
defaultanswer={handles.uitable1.Data{val,1}};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    return
end
handles.uitable1.Data{val,1} = answer{1};
[param,ptrs]                 = mMRgetparam(handles);
handles.ptrs(val,:)          = ptrs;
handles.paramlist(val,:)     = {handles.fun,param};

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
    fprintf(fid,'mscl %g %s\n',i,list{i});
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
plotmrmodel(handles);
guidata(hObject,handles)

function e1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e2_Callback(hObject, eventdata, handles)

plotmrmodel(handles);
guidata(hObject,handles)

function e2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e3_Callback(hObject, eventdata, handles)
plotmrmodel(handles);
guidata(hObject,handles)

function e3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e4_Callback(hObject, eventdata, handles)
plotmrmodel(handles);
guidata(hObject,handles)

function e4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e5_Callback(hObject, eventdata, handles)
plotmrmodel(handles);
guidata(hObject,handles)

function e5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e6_Callback(hObject, eventdata, handles)

plotmrmodel(handles);
guidata(hObject,handles)

function e6_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e7_Callback(hObject, eventdata, handles)
plotmrmodel(handles);
guidata(hObject,handles)

function e7_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e8_Callback(hObject, eventdata, handles)
plotmrmodel(handles);
guidata(hObject,handles)

function e8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e9_Callback(hObject, eventdata, handles)

switch handles.MRselect.String{handles.MRselect.Value}
    case 'Abrahamson Silva 2008 - NGA' % set default Ztop
        Vs30 = str2double(handles.e9.String);
        handles.e8.String=sprintf('%4.4g',Z10_default_AS08_NGA(Vs30));
end

plotmrmodel(handles);
guidata(hObject,handles)

function e9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e10_Callback(hObject, eventdata, handles)
switch handles.MRselect.String{handles.MRselect.Value}
    case 'Chiou Youngs 2008 - NGA' % set default Z1.0
        Vs30 = str2double(handles.e10.String);
        %handles.e7.String=sprintf('%4.4g',exp(28.5-3.82/8*log(Vs30^8+378.8^8)));
        handles.e7.String=sprintf('%4.4g',Z10_default_AS08_NGA(Vs30));
end

plotmrmodel(handles);
guidata(hObject,handles)

function e10_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e11_Callback(hObject, eventdata, handles)
plotmrmodel(handles);
guidata(hObject,handles)

function e11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e12_Callback(hObject, eventdata, handles)
plotmrmodel(handles);
guidata(hObject,handles)

function e12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e13_Callback(hObject, eventdata, handles)
plotmrmodel(handles);
guidata(hObject,handles)

function e13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e14_Callback(hObject, eventdata, handles)
plotmrmodel(handles);
guidata(hObject,handles)

function e14_CreateFcn(hObject, eventdata, handles)
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

% --------------------------------------------------------------------
function grouplist_Callback(hObject, eventdata, handles)

function grouplist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uitable1_CellSelectionCallback(hObject, eventdata, handles)
if isempty(eventdata.Indices)
    return
end
ind     = eventdata.Indices(1);
handles = CellSelectAction(handles,ind);
guidata(hObject,handles)

function[handles]=CellSelectAction(handles,ind)
vals = handles.ptrs(ind,:);
handles.MRselect.Value = vals(end);
ch=get(handles.panel2,'children');
set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off','Style','edit');
handles = mMRdefault(handles,ch(handles.text),ch(handles.edit));

paramlist= handles.paramlist{ind,2};
flds     = fields(paramlist);
for i=1:length(flds)
    fn = ['e',num2str(i)];
    handles.(fn).String=num2str(paramlist.(flds{i}));
    handles.(fn).Value=vals(i);
end
if isfield(handles,'Areas')
    handles.CurrentArea = handles.Areas(ind);
end
plotmrmodel(handles);
handles.selectedrow=ind;

function uitable1_CellEditCallback(hObject, eventdata, handles)

guidata(hObject,handles)

% --------------------------------------------------------------------
function UndockAxis_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.ax1)



% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)

plotmrmodel(handles);
