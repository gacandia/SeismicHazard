function varargout = GMselect(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GMselect_OpeningFcn, ...
    'gui_OutputFcn',  @GMselect_OutputFcn, ...
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

function GMselect_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
handles = initializeGMselect(handles);
handles.accunits  = 'g';
handles.Vs30units = 'm/s';
if nargin==4
    opt=varargin{1};
    % applies filter
    data=[opt.filter.magnitude;
        opt.filter.distance;
        opt.filter.Vs30;
        opt.filter.PGA];
    handles.filtros.Data=data;
    handles.MaxResults.String=num2str(opt.max_rec);
    handles.includeH1.Value=opt.includeH1;
    handles.includeH2.Value=opt.includeH2;
    handles.includeUP.Value=opt.includeUP;
    
    handles.StrikeSlip.Value    = opt.filter.StrikeSlip;
    handles.Normal.Value        = opt.filter.Normal;
    handles.Reverse.Value       = opt.filter.Reverse;
    handles.ReverseOblique.Value= opt.filter.ReverseOblique;
    handles.NormalOblique.Value = opt.filter.NormalOblique;
    handles=NarrowSearch(handles);
    
    if opt.launchGUI
        set(handles.figure1,'visible','off');
        guidata(hObject, handles);
        uiwait(handles.figure1);
    else
        uiresume(handles.figure1);
    end
else
    guidata(hObject, handles);
    %     uiwait(handles.figure1);
end

function varargout = GMselect_OutputFcn(hObject, eventdata, handles)

if nargout==0
    varargout{1}=[];
else
    varargout{1} = buildeqlist(handles);
end

% delete(handles.figure1)

% ------------ FILE MENU ---------------------------------
function File_Callback(hObject, eventdata, handles)

function Reset_Callback(hObject, eventdata, handles)
handles = initializeGMselect(handles);
handles.ImportDatabase.Enable='on';
guidata(hObject,handles)

function ImportDatabase_Callback(hObject, eventdata, handles)
[filename, pathname,filterindex] = uigetfile({'*.mat;*.xlsx'},'Choose Flatfile');
if filterindex==0, return; end

[~,~,ext]=fileparts([pathname,filename]);
handles.pathname = pathname;
switch ext
    case '.xlsx'
        handles = load_db_xls(handles,[pathname,filename]);
    case '.mat'
        handles = load_db_mat(handles,[pathname,filename]);
end

handles.ImportDatabase.Enable='off';
handles.figure1.Name=['Ground Motion Explorer Toolbox - Dataset: ',filename];
guidata(hObject, handles);

function ImportSelection_Callback(hObject, eventdata, handles)
[filename, pathname,filterindex] = uigetfile({'*.txt'},'Pick a file');
if filterindex==0, return; end
handles = import_GMselection(handles,[pathname,filename]);
guidata(hObject,handles)

function LoadDesignSpectra_Callback(hObject, eventdata, handles)

[filename, pathname, filterindex] = uigetfile('*.txt','Select a File');
if filterindex==0, return;end
delete(findall(handles.axes3,'tag','design'));
fname = [pathname,filename];
fid = fopen(fname);
data = textscan(fid,'%f%f');
fclose(fid);
handles.designT  = data{1};
handles.designSA = [data{2}];
handles.designSV = handles.designSA.*handles.designT/(2*pi);
handles.designSD = handles.designSA.*handles.designT.*2/(4*pi^2);
switch handles.show_design.Value
    case 0, plot(handles.axes3,handles.designT,handles.designSA,'b','tag','design','visible','off');
    case 1, plot(handles.axes3,handles.designT,handles.designSA,'b','tag','design','visible','on');
end

guidata(hObject,handles)

function ExportSelection_Callback(hObject, eventdata, handles)
[filename, pathname,filterindex] =  uiputfile('*.txt','Save Ground Motion Selection');
if filterindex==0, return; end
fname = [pathname,filename];
export_GMselection(handles,fname);

function SaveAs_Callback(hObject, eventdata, handles)

function MatFile_Callback(hObject, eventdata, handles)
handles.out=GMoutput(handles);
guidata(hObject,handles)
if handles.out.exitmode
    % export_records2mat_nitro(handles);
    export_siberrisk_nitro(handles);
end
guidata(hObject,handles)

function UndockAxes_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.axes3)

function Parpoolsetup_Callback(hObject, eventdata, handles)
handles=parsetup(handles);
guidata(hObject,handles);

function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% if isequal(get(hObject,'waitstatus'),'waiting')
%     uiresume(hObject);
% else
%     delete(hObject);
% end
delete(hObject);

function Exit_Callback(hObject, eventdata, handles)
close(handles.figure1)

function Exit_button_Callback(hObject, eventdata, handles)
close(handles.figure1)

% ------------ SIGNAL OPTIONS ---------------------------------

function SignalOptionsMenu_Callback(hObject, eventdata, handles)

function RSpecOptions_Callback(hObject, eventdata, handles)
handles.spec = Option_sdof_spectra(handles.spec);
if isempty(handles.currentind)
    guidata(hObject, handles)
    return
else
    handles=plotGMselection(handles,handles.currentind);
    guidata(hObject, handles)
end

function Addfilters_Callback(hObject, eventdata, handles)
prompt={'High Pass frequency - FCH ','Low Pass frequency - FCL'};
defaultanswer={num2str(handles.param(1)),num2str(handles.param(2))};
answer=inputdlg(prompt,'Set filter parameters',[1 40],defaultanswer);
if isempty(answer), return;end
handles.param(1)=str2double(answer{1});
handles.param(2)=str2double(answer{2});

if isempty(handles.currentind)
    guidata(hObject,handles)
    return
else
    delete(findall(handles.axes3,'type','line'));
    handles=plotGMselection(handles,handles.currentind);
    guidata(hObject,handles)
end

function AutoTrimOpt_Callback(hObject, eventdata, handles)
prompt={'Percent Low','Percent High'};
defaultanswer={num2str(handles.paramAuto(1)),num2str(handles.paramAuto(2))};
answer=inputdlg(prompt,'Time trim',[1 40],defaultanswer);
if isempty(answer), return;end
handles.paramAuto(1)=str2double(answer{1});
handles.paramAuto(2)=str2double(answer{2});

if isempty(handles.currentind)
    guidata(hObject,handles)
    return
else
    handles.AutoTrimPushed=1;
    handles=plotGMselection(handles,handles.currentind);
    handles.AutoTrimPushed=0;
    guidata(hObject,handles)
end

function GMScaling_Callback(hObject, eventdata, handles)

prompt={'Period','Sa'};
if isempty(handles.gmscale)
    defaultanswer={'',''};
else
    defaultanswer={num2str(handles.gmscale(1)),num2str(handles.gmscale(2))};
end
answer=inputdlg(prompt,'Response Spectra Scaling',[1 40],defaultanswer);
if isempty(answer), return;end
handles.gmscale(1)=str2double(answer{1});
handles.gmscale(2)=str2double(answer{2});

if any(isnan(handles.gmscale))
    handles.gmscale=[];
end

if isempty(handles.currentind)
    guidata(hObject,handles)
    return
else
    handles=plotGMselection(handles,handles.currentind);
    guidata(hObject,handles)
end

% ------------ MANAGER MENU ---------------------------------

function Manager_Callback(hObject, eventdata, handles)

function RemoveEarthquake_Callback(hObject, eventdata, handles) %#ok<*INUSL>

if isempty(handles.removeind)
    return
end
ind = handles.removeind(:,1);
handles.tabla.Data(ind,:)=[];
handles.overwrite(ind,:)=[];
updatecounters(handles);
handles.removeind=[];

ch=findall(handles.axes3,'type','line');
disc = [];
for i=1:length(ch)
    T=regexp(ch(i).Tag,'\_','split');
    T=str2double(T{1});
    if any(ind==T)
        disc=[disc,i]; %#ok<AGROW>
    end
end
delete(ch(disc));
guidata(hObject, handles)

function DeleteSelection_Callback(hObject, eventdata, handles)
ch  = findall(handles.axes3,'linewidth',1.5);
Tag = regexp(ch.Tag,'\_','split');
I=str2double(Tag{1});
J=str2double(Tag{2})+3;
handles.tabla.Data{I,J}=false;
delete(ch)
hObject.Enable='off';
updatecounters(handles);
guidata(hObject,handles)

% ------------ SEARCH PANNEL ---------------------------------

function filtros_CellEditCallback(hObject, eventdata, handles)

if isnan(eventdata.NewData)
    data = handles.filtros.Data;
    data{eventdata.Indices(1),eventdata.Indices(2)}=[];
    handles.filtros.Data=data;
end
handles=NarrowSearch(handles);
updatecounters(handles);
guidata(hObject, handles);

function MaxResults_Callback(hObject, eventdata, handles)
val = str2double(hObject.String);
if val<0 || isnan(val)
    hObject.String='0';
end
handles = NarrowSearch(handles);
handles.overwrite=zeros(size(handles.tabla.Data,1),2);
updatecounters(handles);
guidata(hObject, handles);

function MaxResults_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%---------------- mechanism group -----------------------------------------
function mechanism_group_SelectionChangedFcn(hObject, eventdata, handles)

function mechanism_group_CreateFcn(hObject, eventdata, handles)

function Interface_Callback(hObject, eventdata, handles)
handles = NarrowSearch(handles);
guidata(hObject, handles)

function IntermediateDepth_Callback(hObject, eventdata, handles)
handles = NarrowSearch(handles);
guidata(hObject, handles)

function StrikeSlip_Callback(hObject, eventdata, handles)
handles = NarrowSearch(handles);
guidata(hObject, handles)

function Normal_Callback(hObject, eventdata, handles)
handles = NarrowSearch(handles);
guidata(hObject, handles)

function Reverse_Callback(hObject, eventdata, handles)
handles = NarrowSearch(handles);
guidata(hObject, handles)

function ReverseOblique_Callback(hObject, eventdata, handles)
handles = NarrowSearch(handles);
guidata(hObject, handles)

function NormalOblique_Callback(hObject, eventdata, handles)
handles = NarrowSearch(handles);
guidata(hObject, handles)

function nomechanism_Callback(hObject, eventdata, handles)
handles = NarrowSearch(handles);
guidata(hObject, handles)

% ---------------- componnts------------------ ----------------------------
function includeH1_Callback(hObject, eventdata, handles)
val = hObject.Value==1;
data = handles.tabla.Data;
for i=1:size(data,1)
    data{i,13}=val;
end
handles.tabla.Data=data;
updatecounters(handles);

if isfield(handles.db,'raw')
    H1 = handles.includeH1.Value==1;
    for i=1:size(handles.db.raw,1)
        handles.db.raw{i,17}=H1;
    end
end

guidata(hObject, handles);

function includeH2_Callback(hObject, eventdata, handles)
val = hObject.Value==1;
data = handles.tabla.Data;
for i=1:size(data,1)
    data{i,14}=val;
end
handles.tabla.Data=data;
updatecounters(handles);

if isfield(handles.db,'raw')
    H2 = handles.includeH2.Value==1;
    for i=1:size(handles.db.raw,1)
        handles.db.raw{i,18}=H2;
    end
end
guidata(hObject, handles);

function includeUP_Callback(hObject, eventdata, handles)
val = hObject.Value==1;
data = handles.tabla.Data;
for i=1:size(data,1)
    data{i,15}=val;
end
handles.tabla.Data=data;
updatecounters(handles);

if isfield(handles.db,'raw')
    UP = handles.includeUP.Value==1;
    for i=1:size(handles.db.raw,1)
        handles.db.raw{i,19}=UP;
    end
end

guidata(hObject, handles);

function show_allH1_Callback(hObject, eventdata, handles)
if isempty(handles.tabla.Data)
    return
end
handles.HoldPlot.Value=1;
if handles.buttomselected~=3
    handles.showgeomean.Enable='off';
    handles.show_design.Enable='off';
end
for i=1:size(handles.tabla.Data,1)
    handles=plotGMselection(handles,[i,10]);
    ch=findall(handles.axes3,'tag','geomean');
    delete(ch);
    handles=plot_geomean(handles);
    drawnow
end
guidata(hObject,handles)

function show_allH2_Callback(hObject, eventdata, handles)
if isempty(handles.tabla.Data)
    return
end
handles.HoldPlot.Value=1;
if handles.buttomselected~=3
    handles.showgeomean.Enable='off';
    handles.show_design.Enable='off';
end
for i=1:size(handles.tabla.Data,1)
    handles=plotGMselection(handles,[i,11]);
    ch=findall(handles.axes3,'tag','geomean');
    delete(ch);
    handles=plot_geomean(handles);
    drawnow
end
guidata(hObject,handles)

function show_allUP_Callback(hObject, eventdata, handles)
if isempty(handles.tabla.Data)
    return
end
handles.HoldPlot.Value=1;
if handles.buttomselected~=3
    handles.showgeomean.Enable='off';
    handles.show_design.Enable='off';
end
for i=1:size(handles.tabla.Data,1)
    handles=plotGMselection(handles,[i,12]);
    ch=findall(handles.axes3,'tag','geomean');
    delete(ch);
    handles=plot_geomean(handles);
    drawnow
end
guidata(hObject,handles)

function Show_SelectionH1_Callback(hObject, eventdata, handles)
if isempty(handles.tabla.Data)
    return
end
handles.HoldPlot.Value=1;
if handles.buttomselected~=3
    handles.showgeomean.Enable='off';
    handles.show_design.Enable='off';
end
for i=1:size(handles.tabla.Data,1)
    if handles.tabla.Data{i,13}==true
        handles=plotGMselection(handles,[i,10]);
        ch=findall(handles.axes3,'tag','geomean');
        delete(ch);
        handles=plot_geomean(handles);
    end
    drawnow
end
guidata(hObject,handles)

function Show_SelectionH2_Callback(hObject, eventdata, handles)
if isempty(handles.tabla.Data)
    return
end
handles.HoldPlot.Value=1;
if handles.buttomselected~=3
    handles.showgeomean.Enable='off';
    handles.show_design.Enable='off';
end
for i=1:size(handles.tabla.Data,1)
    if handles.tabla.Data{i,14}==true
        handles=plotGMselection(handles,[i,11]);
        ch=findall(handles.axes3,'tag','geomean');
        delete(ch);
        handles=plot_geomean(handles);
        drawnow
    end
end
guidata(hObject,handles)

function Show_SelectionUP_Callback(hObject, eventdata, handles)
if isempty(handles.tabla.Data)
    return
end
handles.HoldPlot.Value=1;
if handles.buttomselected~=3
    handles.showgeomean.Enable='off';
    handles.show_design.Enable='off';
end
for i=1:size(handles.tabla.Data,1)
    if handles.tabla.Data{i,15}==true
        handles=plotGMselection(handles,[i,12]);
        ch=findall(handles.axes3,'tag','geomean');
        delete(ch);
        handles=plot_geomean(handles);
        drawnow
    end
end
guidata(hObject,handles)

% --------------- GROUND MOTION TABLE -------------------------------------

function tabla_CellSelectionCallback(hObject, eventdata, handles)
ind = eventdata.Indices;
handles.removeind=eventdata.Indices;
if numel(ind)==0
    return
end
if or(ind(2)<10,ind(2)>12)
    guidata(hObject, handles);
    return
end
handles.currentind = ind;
handles=plotGMselection(handles,ind);
handles.HideLine.Visible='off';
handles.DeleteSelection.Enable='off';

% updates geometric mean
ch=findall(handles.axes3,'tag','geomean');
delete(ch);
handles=plot_geomean(handles);
guidata(hObject, handles);

function tabla_KeyPressFcn(hObject, eventdata, handles)

function tabla_CellEditCallback(hObject, eventdata, handles)
updatecounters(handles)

% --------------- SYSTEM FUNCTIONS ---------------------------------------
function Display_group_SelectionChangeFcn(hObject, eventdata, handles)

switch hObject.String
    case 'Time Series',       handles.buttomselected=1;handles.showgeomean.Enable='off';handles.show_design.Enable='off';
    case 'Fourier Spectrum',  handles.buttomselected=2;handles.showgeomean.Enable='off';handles.show_design.Enable='off';
    case 'Response Spectrum', handles.buttomselected=3;handles.showgeomean.Enable='on';handles.show_design.Enable='on';
end

if isempty(handles.currentind)
    guidata(hObject,handles)
    return
end

OLDV=handles.HoldPlot.Value;
handles.HoldPlot.Value=0;
handles=plotGMselection(handles,handles.currentind);
handles.HoldPlot.Value=OLDV;
guidata(hObject,handles)

function HoldPlot_Callback(hObject, eventdata, handles)
if hObject.Value==0
    handles.showgeomean.Value=0;
    handles.showgeomean.Enable='off';
    ch=findall(handles.axes3,'tag','geomean');
    delete(ch);
    
    handles.show_design.Value=0;
    handles.show_design.Enable='off';
    ch=findall(handles.axes3,'tag','design');
    delete(ch);
else
    if handles.buttomselected==3
        handles.showgeomean.Enable='on';
        handles.show_design.Enable='on';
    end
end

guidata(hObject,handles)

function HideLine_Callback(hObject, eventdata, handles)

ch=findall(handles.axes3,'linewidth',1.5);

Tag = regexp(ch.Tag,'\_','split');
I=str2double(Tag{1});
J=str2double(Tag{2})+3;
handles.tabla.Data{I,J}=false;

delete(ch)
hObject.Visible='off';
updatecounters(handles);

% updates geometric mean
ch=findall(handles.axes3,'tag','geomean');
delete(ch);
handles=plot_geomean(handles);
handles.curr_ID.String='';
handles.curr_earthquake.String='';
handles.curr_filename.String='';
handles.curr_component.String='';
guidata(hObject,handles)

% ----------- SIDE BUTTONS -----------------------------------------------
function AutoTrim_Callback(hObject, eventdata, handles)

if isempty(handles.currentind)
    return
end

switch handles.buttomselected
    case 2, return
    case 3, return
end

handles.AutoTrimPushed=1;
handles=plotGMselection(handles,handles.currentind);
handles.AutoTrimPushed=0;
guidata(hObject,handles)

function ManualTrim_Callback(hObject, eventdata, handles)
ind  = handles.currentind;
if isempty(ind) || ~strcmp(handles.Display_group.SelectedObject.String,'Accelerogram')
    return
end

XLIMOLD = handles.overwrite(ind(1),:);
XLIM    = handles.axes3.XLim;
handles.overwrite(ind(1),:) =XLIMOLD(1)+XLIM;
tagname = [num2str(ind(1)),'_',num2str(ind(2)),'_1'];
ch=findall(handles.axes3,'tag',tagname);
delete(ch);
handles=plotGMselection(handles,handles.currentind);
guidata(hObject,handles)

function restoretrim_Callback(hObject, eventdata, handles)
ind  = handles.currentind;
if isempty(ind) || ~strcmp(handles.Display_group.SelectedObject.String,'Accelerogram')
    return
end
handles.overwrite(ind(1),:)=[0 0];

tagname = [num2str(ind(1)),'_',num2str(ind(2)),'_1'];
ch=findall(handles.axes3,'tag',tagname);
delete(ch);

handles=plotGMselection(handles,handles.currentind);
guidata(hObject,handles)

function erase_Callback(hObject, eventdata, handles)
delete(findall(handles.axes3,'type','line'));
handles.overwrite=zeros(size(handles.tabla.Data,1),2);
handles.curr_ID.String=' ';
handles.curr_earthquake.String=' ';
handles.curr_filename.String=' ';
handles.curr_component.String=' ';
handles.axes3.ColorOrderIndex=1;
guidata(hObject,handles)

function axisscale_Callback(hObject, eventdata, handles)
switch [handles.axes3.XScale,handles.axes3.YScale]
    case 'linearlinear', handles.axes3.XScale='log';
    case 'loglinear',    handles.axes3.XScale='linear'; handles.axes3.YScale='log';
    case 'linearlog',    handles.axes3.XScale='log';
    case 'loglog',       handles.axes3.XScale='linear'; handles.axes3.YScale='linear';
end

function showgeomean_Callback(hObject, eventdata, handles)
ch=get(handles.axes3,'children');
if isempty(ch), return; end
[~,B]=intersect(char(ch.Tag),'design','rows');
ch(B)=[];
if isempty(ch), return; end

delete(findall(handles.axes3,'tag','geomean'));
handles=plot_geomean(handles);

guidata(hObject,handles)

function show_design_Callback(hObject, eventdata, handles)
delete(findall(handles.axes3,'tag','design'));
switch hObject.Value
    case 0, plot(handles.axes3,handles.designT,handles.designSA,'b','tag','design','visible','off');
    case 1, plot(handles.axes3,handles.designT,handles.designSA,'b','tag','design','visible','on');
        
end
guidata(hObject,handles)

function Display_group_CreateFcn(hObject, eventdata, handles)

function undock_Callback(hObject, eventdata, handles)
figure2clipboard_uimenu(hObject, eventdata,handles.axes3)

function SelectStations_Callback(hObject, eventdata, handles)
if ~isfield(handles,'station')
    return
end
handles.site_selection= GMStationSelect(handles);
handles=NarrowSearch(handles);
guidata(hObject,handles)

function integrationButton_Callback(hObject, eventdata, handles)

switch handles.integrationLevel
    case 2, handles.integrationLevel=0; handles.Display_group.Title='Acceleration Display Options';
    case 1, handles.integrationLevel=2; handles.Display_group.Title='Displacement Display Options';
    case 0, handles.integrationLevel=1; handles.Display_group.Title='Velocity Display Options';
end

ch=findall(handles.axes3,'type','line');
delete(ch);
handles=plotGMselection(handles,handles.currentind);
guidata(hObject,handles)

function Pallet_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 1 % pushed
        ch = findall(handles.axes3,'type','line');
        for i=1:length(ch)
            if and(~strcmp(ch(i).Tag,'geomean'),~strcmp(ch(i).Tag,'design'))
                ch(i).Color=[1 1 1]*0.5;
            end
        end
        
    case 0 % released
        ch = findall(handles.axes3,'type','line');
        CO = handles.axes3.ColorOrder;
        cont = 0;
        for i=length(ch):-1:1
            if and(~strcmp(ch(i).Tag,'geomean'),~strcmp(ch(i).Tag,'design'))
                cont=cont+1;
                row = rem(cont,7);if row==0,row=7;end
                ch(i).Color=CO(row,:);
            end
        end        
        
        
end
