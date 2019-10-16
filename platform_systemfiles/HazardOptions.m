function varargout = HazardOptions(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @HazardOptions_OpeningFcn, ...
    'gui_OutputFcn',  @HazardOptions_OutputFcn, ...
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

function HazardOptions_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

if nargin==6 && strcmp(varargin{3},'off')
    % loads input variables
    branchnames = varargin{1}(1,:);
    isREGULAR   = cell2mat(varargin{1}(2,:));
    ihaz        = varargin{2};
    
    % sets mode
    switch ihaz.mod
        case 1, handles.mod1.Value=1; handles.mod2.Value=0;
        case 2, handles.mod1.Value=0; handles.mod2.Value=1;
        case 3, handles.mod1.Value=0; handles.mod2.Value=1;
    end
    
    % populate pannel 1
    handles.pan1_1.Value=ihaz.avg(1);
    handles.pan1_2.Value=ihaz.avg(2);
    handles.pan1_3.Value=ihaz.avg(3);
    handles.pan1_4.String=sprintf('%g',ihaz.avg(4));
    handles.pan1_5.Value=ihaz.avg(5);
    
    % populate pannel 2
    handles.pan2_1.String = branchnames;
    handles.pan2_1.Value  = ihaz.sbh(1);
    handles.pan2_2.Value  = ihaz.sbh(2);
    handles.pan2_3.Value  = ihaz.sbh(3);
    handles.pan2_4.Value  = ihaz.sbh(4);
    
    % fills dbt
    handles.pan3_1.Value  = ihaz.dbt(1);
    handles.pan3_2.Value  = ihaz.dbt(2);
    handles.pan3_3.Value  = ihaz.dbt(3);
    handles.pan3_4.String = sprintf('%g',ihaz.dbt(4));

    % fills hazard map options
    handles.pan4_1.String = sprintf('%g',ihaz.map(1));
    handles.pan4_2.Value  = ihaz.map(2);

    % fills pce data
    handles.pan5_1.Value  = ihaz.pce(1);
    handles.pan5_2.Value  = ihaz.pce(2);
    handles.pan5_3.String = sprintf('%g',ihaz.pce(3));    
    
    switch ihaz.mod
        case 1
            handles.pan1_1.Enable='on';
            handles.pan1_2.Enable='on';
            handles.pan1_3.Enable='on';
            handles.pan1_4.Enable='on';
            handles.pan1_5.Enable='on';
            handles.pan2_1.Enable='off';
            handles.pan2_2.Enable='off';
            handles.pan2_3.Enable='off';
            handles.pan2_4.Enable='off';
        case {2,3}
            handles.pan1_1.Enable='off';
            handles.pan1_2.Enable='off';
            handles.pan1_3.Enable='off';
            handles.pan1_4.Enable='off';
            handles.pan1_5.Enable='off';
            handles.pan2_1.Enable='on';
    end
    
    if any([ihaz.mod==2,ihaz.mod==3])
        if isREGULAR(handles.pan2_1.Value) % isREGULAR
            handles.pan2_2.Enable='on';
            handles.pan2_3.Enable='on';
            handles.pan2_4.Enable='off';
        else %isPCE
            handles.pan2_2.Enable='off';
            handles.pan2_3.Enable='off';
            handles.pan2_4.Enable='on';
        end
    end
    handles.isregular     = isREGULAR;
    switch handles.pan1.SelectedObject.String
        case 'Percentile'
            handles.pan1_4.Enable='on';
        otherwise
            handles.pan1_4.Enable='off';
    end
    
    switch handles.pan3.SelectedObject.String
        case 'Probability of Exceedance'
            handles.pan3_4.Enable='on';
        otherwise
            handles.pan3_4.Enable='off';
    end
    
    switch handles.pan5.SelectedObject.String
        case 'Percentile'
            handles.pan5_3.Enable='on';
        otherwise
            handles.pan5_3.Enable='off';
    end
    
end

if nargin==6 && strcmp(varargin{3},'on')
    % loads input variables
    handles.mod1.Enable='inactive';
    handles.mod2.Enable='off';
    handles.mod3.Enable='off';
    

    % populate pannel 1
    handles.pan1_1.Enable='on';
    handles.pan1_1.Value=1;
    handles.pan1_2.Enable='off';
    handles.pan1_3.Enable='off';
    handles.pan1_4.Enable='off';
    handles.pan1_5.Enable='off';
    
    % populate pannel 2
    handles.pan2_1.Enable='off';
    handles.pan2_2.Enable='off';
    handles.pan2_3.Enable='off';
    handles.pan2_4.Enable='off';
    
    % fills dbt
    handles.pan3_1.Enable='off';
    handles.pan3_2.Enable='off';
    handles.pan3_3.Enable='off';
    handles.pan3_4.Enable='off';

    % fills hazard map options
%     handles.pan4_1.Enable ='off';
%     handles.pan4_2.Enable ='off';

    % fills pce data
    handles.pan5_1.Enable='off';
    handles.pan5_2.Enable='off';
    handles.pan5_3.Enable='off';
%     handles.isregular     = isREGULAR;
end

guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = HazardOptions_OutputFcn(hObject, eventdata, handles)

switch handles.mod1.Value
    case 1
        haz.mod  = 1;
    case 0
        if handles.isregular(handles.pan2_1.Value)
            haz.mod=2;
        else
            haz.mod=3;
        end
end

haz.avg = [...
    handles.pan1_1.Value,...
    handles.pan1_2.Value,...
    handles.pan1_3.Value,...
    str2double(handles.pan1_4.String),...
    handles.pan1_5.Value];

haz.sbh = [handles.pan2_1.Value,...
    handles.pan2_2.Value,...
    handles.pan2_3.Value,...
    handles.pan2_4.Value];

haz.dbt = [...
    handles.pan3_1.Value,...
    handles.pan3_2.Value,...
    handles.pan3_3.Value,...
    str2double(handles.pan3_4.String)];

haz.map = [str2double(handles.pan4_1.String),...
    handles.pan4_2.Value];

haz.pce = [handles.pan5_1.Value,...
           handles.pan5_2.Value,...
           str2double(handles.pan5_3.String)];

Nbranches = length(handles.pan2_1.String);
rnd = rand(Nbranches,1); rnd = rnd/sum(rnd);
haz.rnd = rnd;
       
varargout{1} = haz;
delete(handles.figure1)

function pan1_1_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function pan1_2_Callback(hObject, eventdata, handles)

function pan1_3_Callback(hObject, eventdata, handles)

function pan1_4_Callback(hObject, eventdata, handles)

val = str2double(hObject.String);
val = min(max(val,0),100);
hObject.String=sprintf('%g',val);
guidata(hObject,handles)

function pan1_5_Callback(hObject, eventdata, handles)

function pan2_2_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 0
    case 1
        handles.pan2_3.Value=0;
end
guidata(hObject,handles)

function pan2_3_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 0
    case 1
        handles.pan2_2.Value=0;
end
guidata(hObject,handles)

function mod1_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 0
        handles.pan1_1.Enable='off';
        handles.pan1_2.Enable='off';
        handles.pan1_3.Enable='off';
        handles.pan1_4.Enable='off';
        handles.pan1_5.Enable='off';
        handles.mod2.Value=1;
        handles.pan2_1.Enable='on';
        if handles.isregular(handles.pan2_1.Value)==1
            handles.pan2_2.Enable='on';
            handles.pan2_3.Enable='on';
            handles.pan2_4.Enable='off';
        else
            handles.pan2_2.Enable='off';
            handles.pan2_3.Enable='off';
            handles.pan2_4.Enable='on';            
        end
    case 1
        handles.pan1_1.Enable='on';
        handles.pan1_2.Enable='on';
        handles.pan1_3.Enable='on';
        handles.pan1_4.Enable='on';
        handles.pan1_5.Enable='on';
        handles.mod2.Value=0;
        handles.pan2_1.Enable='off';
        handles.pan2_2.Enable='off';
        handles.pan2_3.Enable='off';
        handles.pan2_4.Enable='off';
end

switch handles.pan1.SelectedObject.String
    case 'Percentile'
        handles.pan1_4.Enable='on';
    otherwise
        handles.pan1_4.Enable='off';
end

guidata(hObject,handles)

function mod2_Callback(hObject, eventdata, handles)
switch hObject.Value
    case 0
        handles.mod1.Value=1;
        handles.pan1_1.Enable='on';
        handles.pan1_2.Enable='on';
        handles.pan1_3.Enable='on';
        handles.pan1_4.Enable='on';
        handles.pan1_5.Enable='on';
        handles.pan2_1.Enable='off';
        handles.pan2_2.Enable='off';
        handles.pan2_3.Enable='off';
        handles.pan2_4.Enable='off';
    case 1
        handles.mod1.Value=0;
        handles.pan1_1.Enable='off';
        handles.pan1_2.Enable='off';
        handles.pan1_3.Enable='off';
        handles.pan1_4.Enable='off';
        handles.pan1_5.Enable='off';
        handles.pan2_1.Enable='on';
        
        if handles.isregular(handles.pan2_1.Value)==1
            handles.pan2_2.Enable='on';
            handles.pan2_3.Enable='on';
            handles.pan2_4.Enable='off';
        else
            handles.pan2_2.Enable='off';
            handles.pan2_3.Enable='off';
            handles.pan2_4.Enable='on';            
        end
end
guidata(hObject,handles)

function pan3_4_Callback(hObject, eventdata, handles)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function pan1_SelectionChangedFcn(hObject, eventdata, handles)

switch handles.pan1.SelectedObject.String
    case 'Percentile'
        handles.pan1_4.Enable='on';
    otherwise
        handles.pan1_4.Enable='off';
end

function pan3_SelectionChangedFcn(hObject, eventdata, handles)

switch handles.pan3.SelectedObject.String
    case 'Probability of Exceedance'
        handles.pan3_4.Enable='on';
    otherwise
        handles.pan3_4.Enable='off';
end

function pan4_1_Callback(hObject, eventdata, handles)

function pan4_2_Callback(hObject, eventdata, handles)

function pan5_3_Callback(hObject, eventdata, handles)

function pan5_1_Callback(hObject, eventdata, handles)

function pan5_SelectionChangedFcn(hObject, eventdata, handles)

switch hObject.String
    case 'Mean Hazard', handles.pan5_3.Enable = 'off';
    case 'Percentile' , handles.pan5_3.Enable = 'on';
end

function pan2_4_Callback(hObject, eventdata, handles)

function pan2_1_Callback(hObject, eventdata, handles)
val = hObject.Value;
if handles.isregular(val)==1 % isREGULAR
    handles.pan2_2.Enable='on';
    handles.pan2_3.Enable='on';
    handles.pan2_4.Enable='off';
else %isPCE
    handles.pan2_2.Enable='off';
    handles.pan2_3.Enable='off';
    handles.pan2_4.Enable='on';    
end
