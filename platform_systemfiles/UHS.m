function varargout = UHS(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UHS_OpeningFcn, ...
                   'gui_OutputFcn',  @UHS_OutputFcn, ...
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

function UHS_OpeningFcn(hObject, eventdata, handles, varargin)

handles.Engine.CData         = double(imread('Engine.jpg'))/255;
handles.Exit_button.CData    = double(imread('Exit.jpg'))/255;
handles.ax1Limits.CData      = double(imread('Limits.jpg'))/255;
handles.compute_uhs.CData    = double(imread('Play.jpg'))/255;
handles.clear_analysis.CData = double(imresize(imread('delete.jpg'),[16 16]))/255;

handles.output    = hObject;
handles.sys       = varargin{1};
handles.model     = varargin{2};
handles.opt       = varargin{3};
handles.h         = varargin{4};

%prepare model for UHS
handles.isREGULAR = find(horzcat(handles.model.isregular)==1);
handles.isPCE     = find(horzcat(handles.model.isregular)==0);

% ------------ REMOVES PCE MODELS (AT LEAST FOR NOW) ----------------------
isREGULAR = handles.isREGULAR;
handles.model = handles.model(isREGULAR); 
[~,B]=setdiff(handles.sys.BRANCH(:,2),isREGULAR);
if ~isempty(B)
    handles.sys.BRANCH(B,:)=[];
    handles.sys.WEIGHT(B,:)=[];
    handles.sys.WEIGHT(:,4)=handles.sys.WEIGHT(:,4)/sum(handles.sys.WEIGHT(:,4));
    warndlg('PCE Models removed from logic tree. Weights re-normalized')
    uiwait
end
% -------------------------------------------------------------------------

set(handles.select_site,'string',handles.h.id);
handles.figure1.Name=[handles.sys.filename, ' - Uniform Hazard Spectrum'];

Tmax = [];
for i=1:length(handles.model)
   for j=1:length(handles.model(i).source) 
       T    = handles.model(i).source(j).gmpe.T;
       Tmax = [Tmax;max(T)]; %#ok<AGROW>
   end
end
Tmax  = min(Tmax);
handles.Tmax = Tmax;
tlist = unique([0.01:0.01:0.1,0.1:0.1:1,1:1:10]);
tlist(tlist>Tmax)=[];
handles.defaultperiods = tlist;
handles.Tlist.String = num2cell(tlist);

handles.param=[1 0 0 50 1]; 
guidata(hObject, handles);
% uiwait(handles.figure1);

function varargout = UHS_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
varargout{1} = [];

% delete(handles.figure1)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% if isequal(get(hObject,'waitstatus'),'waiting')
%     uiresume(hObject);
% else
%     delete(hObject);
% end
delete(hObject);

function select_site_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
if ~isempty(handles.UHS)
    plot_UHS_spec(handles)
end
 guidata(hObject, handles);
 
function select_site_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function compute_uhs_Callback(hObject, eventdata, handles)

% this change is to accomodate the latest V-PSHA capabilities
% ----------------------------------------------------------------
im        = logsp(0.0001,10,50)';
site      = handles.h.p;
Tdof      = sort(str2double(handles.Tlist.String));
handles.opt.IM = Tdof;
handles.opt.im = repmat(im,1,length(Tdof));
% ----------------------------------------------------------------

handles.site_selection=1:size(site,1);
if isfield(handles,'lambda')
    lambda    = handles.lambda;
else
    lambda    = runlogictree1(handles.sys,handles.model,handles.opt,handles.h,handles.site_selection);
    lambda    = nansum(lambda,4);
    lambda    = permute(nansum(lambda,4),[1,2,3,5,4]);
    handles.lambda = lambda;
end
hazlevel  = 1./str2double(handles.ReturnPeriod.String);
[Nsite,~,NIM,Nbranches] = size(lambda);
handles.UHS = zeros(Nsite,NIM,Nbranches);
set(handles.figure1,'Pointer','watch');
for i=1:Nsite
    for j=1:Nbranches
        lij = permute(lambda(i,:,:,j),[2,3,1]);
        uhs = uhspectrum(im,lij,hazlevel);
        handles.UHS(i,:,j) = uhs;
    end
end
set(handles.figure1,'Pointer','arrow');
plot_UHS_spec(handles)
set(handles.ExportUHS,'enable','on');
guidata(hObject, handles);

function plot_UHS_spec(handles)
if ~isfield(handles,'UHS')
    return
end
param = handles.param;
site_ptr = get(handles.select_site,'value');
uhs = permute(handles.UHS(site_ptr,:,:),[2,3,1]);
delete(findall(handles.ax1,'tag','uhs'))

switch param(5)
    case 1
        Ny = size(uhs,2);
        c1 = [0.7660    0.6740    0.1880];
        c2 = [0.3010    0.7450    0.9330];
        handles.ax1.ColorOrder= [linspace(c1(1),c2(1),Ny)',linspace(c1(2),c2(2),Ny)',linspace(c1(3),c2(3),Ny)'];
        plot(handles.ax1,handles.opt.IM,uhs,'-','tag','uhs');
    case 0
end

% mean UHS
if param(1)==1
    weight = handles.sys.WEIGHT(:,4)';
    uhsm   = prod(bsxfun(@power,uhs,weight),2);
    legstr = 'Default Weights';
elseif param(2)==1
    weight = rand(size(handles.sys.WEIGHT(:,4)'));
    weight = weight/sum(weight);
    uhsm   = prod(bsxfun(@power,uhs,weight),2);
    legstr = 'Random Weights';
elseif param(3)==1
    per = param(4);
    uhsm  = prctile(uhs,per,2);
    legstr = sprintf('Percentile %g',per);
end
plot(handles.ax1,handles.opt.IM,uhsm,'-','color',[0 0.447 0.741],'linewidth',2,'tag','uhs');
xlabel('Period (s)')
ylabel('Sa (g)')

switch param(5)
    case 1,LL=legend({handles.model.id,legstr}); LL.Box='off';
    case 0,LL=legend(legstr); LL.Box='off';
end

% uicontext
cF=get(0,'format');
format long g
num = [handles.opt.IM(:),[uhs,uhsm]];
data = num2cell(num);
c = uicontextmenu;
uimenu(c,'Label','Copy data','Callback'          ,{@data2clipboard_uimenu,data});
set(handles.ax1,'uicontextmenu',c);
format(cF);

function edit_hazard_level_CellEditCallback(hObject, eventdata, handles)

data=get(hObject,'data');
for i=1:numel(data)
    if isempty(data{i}) || isnan(data{i})
        data{i}=[];
    end
end
f = size(data,1);
for i=1:f
    if data{i,1}<=0 , data{i,1}=[];end
    if data{i,1}>100, data{i,1}=[];end
    if data{i,2}<=0 , data{i,2}=[];end    
    data{i,3}=[];
    
end

data0=data;
for i=1:numel(data0)
    if isempty(data0{i}) || isnan(data0{i})
        data0{i}=0;
    end
end
data0 = cell2mat(data0);

% number of entered rows
ind = find(prod(data0(:,1:2),2)); 

if isempty(ind)
   set(hObject,'data',data);
   set(handles.compute_uhs,'enable','off')
   return 
end


for i=1:length(ind)
    prob = data0(ind(i),1)/100;
    twin = data0(ind(i),2);
    data{ind(i),3}= -twin/log(1-prob);
end

set(hObject,'data',data);
Nsite = size(handles.h.p,1);
if Nsite>0 && isfield(handles,'model') && ~isempty(cell2mat(data(:,3)))
    set(handles.compute_uhs,'enable','on');
end

guidata(hObject, handles);

function Plus_Callback(hObject, eventdata, handles)
% hObject    handle to Plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.edit_hazard_level,'data');
data(end+1,:)=cell(1,3);
set(handles.edit_hazard_level,'data',data);
guidata(hObject, handles);

function Minus_Callback(hObject, eventdata, handles)
data = get(handles.edit_hazard_level,'data');
if size(data,1)>1
    data(end,:)=[];
    set(handles.edit_hazard_level,'data',data);
end
guidata(hObject, handles);

function File_Callback(hObject, eventdata, handles)

function Options_Callback(hObject, eventdata, handles)

function Parpoolsetup_Callback(hObject, eventdata, handles)

handles=parsetup(handles);
guidata(hObject,handles);

function ExportUHS_Callback(hObject, eventdata, handles)

p = handles.h.p;

[FileName,PathName] =  uiputfile('*.out','Save UHS As ...');
if isnumeric(FileName)
    return
end
FNAME = [PathName,FileName];
fileID = fopen(FNAME,'w');
fprintf(fileID,' -------  Seismic Hazard Analysis : UHS Toolbox v0.1 ------\n');

Treturn = 1./str2double(handles.ReturnPeriod.String);
Nret    = size(Treturn,2);
Nsite   = size(p,1);
text1 = repmat(' %7.3f,',1,Nret);text1(end)=[];
fprintf(fileID,['Return Periods (years):',text1,'\n'],Treturn);
fprintf(fileID,'Number of Sites       : %d \n\n',Nsite);

for val=1:Nsite
    fprintf(fileID,'Site            : %d \n',val);
    fprintf(fileID,'Site ID         : %s \n',p{val});
    fprintf(fileID,'Lat             : %6.4f°\n',p{val,2});
    fprintf(fileID,'Lon             : %6.4f°\n',p{val,3});
    
    text3 = '';
    for i=1:Nret
        text3=[text3,'Sa ',num2str(i),repmat(' ',1,13-ceil(log10(i+1)))]; %#ok<AGROW>
    end
    fprintf(fileID,['Period (s)      ',text3,'\n']);
    text2 = repmat(' %12.8e',1,Nret);
    WEIGHTS = handles.sys.WEIGHT(:,4);
    uhs=exp(permute(log(handles.UHS(val,:,:)),[2 3 1])*WEIGHTS);
    fprintf(fileID,['%12.8e',text2,'\n'],[handles.opt.IM';uhs']);
    fprintf(fileID,' \n');
end
fclose(fileID);

if ispc,winopen(FNAME);end

function SetDefault_Callback(hObject, eventdata, handles)

handles.edit_hazard_level.Data= {10,50,-50/log(1-10/100)};
data = handles.edit_hazard_level.Data;
Nsite = size(handles.h.p,1);
if Nsite>0 && isfield(handles,'model') && ~isempty(cell2mat(data(:,3)))
    handles.compute_uhs.Enable='on';
end

guidata(hObject, handles);

function handles = axscale_uimenu(source,callbackdata,handles)

str = get(source,'Label');
switch str
    case 'linear'   , set(gca,'xscale','linear' ,'yscale','linear'),
    case 'loglog'   , set(gca,'xscale','log'    ,'yscale','log')
    case 'semilogx' , set(gca,'xscale','log'    ,'yscale','linear'),
    case 'semilogy' , set(gca,'xscale','linear' ,'yscale','log'),
end

function Exit_Callback(hObject, eventdata, handles)

close(handles.figure1)

function Exit_button_Callback(hObject, eventdata, handles)
close(handles.figure1)

function Tlist_Callback(hObject, eventdata, handles)

Tlist = strtrim(handles.Tlist.String);

if length(Tlist)==1
    Tlist = eval(Tlist{1});
    Tlist = Tlist(:);
else
    Tlist = unique(str2double(Tlist));
end
Tlist(Tlist>handles.Tmax)=[];
handles.Tlist.String=num2cell(Tlist);
if isfield(handles,'lambda')
    handles=rmfield(handles,'lambda');
end
guidata(hObject,handles)

function Tlist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ReturnPeriod_Callback(hObject, eventdata, handles)

function ReturnPeriod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function clear_analysis_Callback(hObject, eventdata, handles)

delete(findall(handles.ax1,'tag','uhs'))
if isfield(handles,'UHS')
    handles=rmfield(handles,{'UHS'});
end
guidata(hObject,handles);


% --- Executes on button press in ax1Limits.
function ax1Limits_Callback(hObject, eventdata, handles)
handles.ax1=ax2Control(handles.ax1);

function restoredefaultperiods_Callback(hObject, eventdata, handles)

handles.Tlist.String=num2cell(handles.defaultperiods);
guidata(hObject,handles)

function Engine_Callback(hObject, eventdata, handles)

handles.param = UHSOptions(handles.param);
plot_UHS_spec(handles);
guidata(hObject,handles)
