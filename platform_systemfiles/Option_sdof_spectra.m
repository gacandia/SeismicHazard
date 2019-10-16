function varargout = Option_sdof_spectra(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Option_sdof_spectra_OpeningFcn, ...
    'gui_OutputFcn',  @Option_sdof_spectra_OutputFcn, ...
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

function Option_sdof_spectra_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
meth = pshatoolbox_methods(1);
ind  = ismember({meth.type},'regular');
handles.GMMpop.String={meth(ind).label};

if nargin==3
    handles.periodlist.String=num2cell(logsp(0.01,10,30));
else
    handles=pop_options(handles,varargin{1});
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Option_sdof_spectra wait for user response (see UIRESUME)
uiwait(handles.figure1);

function handles=pop_options(handles,ispec)

handles.method.Value=ispec.z{1};
handles.dampingratio.String = sprintf('%g',ispec.z{2});
handles.opt1.Value = ispec.z{3};
handles.opt2.Value = ispec.z{4};
handles.opt3.Value = ispec.z{5};
handles.opt4.Value = ispec.z{6};
handles.Tmin.String = sprintf('%g',ispec.z{7});
handles.Tmax.String = sprintf('%g',ispec.z{8});
handles.Nper.String = sprintf('%g',ispec.z{9});
handles.GMMpop.Value = ispec.z{10};
handles.periodlist.String=num2cell(ispec.z{11});
if handles.opt1.Value
    handles.Tmin.Enable='on';
    handles.Tmax.Enable='on';
    handles.Nper.Enable='on';
    handles.GMMpop.Enable = 'off';
    handles.periodlist.Enable='inactive';
end
if handles.opt2.Value
    handles.Tmin.Enable='on';
    handles.Tmax.Enable='on';
    handles.Nper.Enable='on';
    handles.GMMpop.Enable = 'off';
    handles.periodlist.Enable='inactive';
end
if handles.opt3.Value
    handles.Tmin.Enable='off';
    handles.Tmax.Enable='off';
    handles.Nper.Enable='off';
    handles.GMMpop.Enable = 'on';
    handles.periodlist.Enable='inactive';
end
if handles.opt4.Value
    handles.Tmin.Enable='off';
    handles.Tmax.Enable='off';
    handles.Nper.Enable='off';
    handles.GMMpop.Enable = 'off';
    handles.periodlist.Enable='on';
end




function varargout = Option_sdof_spectra_OutputFcn(hObject, eventdata, handles)

switch handles.method.Value
    case 1,spec.method = @freqspec;
    case 2,spec.method = @timespec;
end
spec.damping = str2double(handles.dampingratio.String);

switch handles.uibuttongroup1.SelectedObject.String
    
    case 'logspaced'
        Tmin = str2double(handles.Tmin.String);
        Tmax = str2double(handles.Tmax.String);
        Nper = str2double(handles.Nper.String);
        spec.T=logsp(Tmin,Tmax,Nper);
        
    case 'linspaced'
        Tmin = str2double(handles.Tmin.String);
        Tmax = str2double(handles.Tmax.String);
        Nper = str2double(handles.Nper.String);
        spec.T=linspace(Tmin,Tmax,Nper);
        
    case 'from GMPE'
        val     = handles.GMMpop.Value;
        meth    = pshatoolbox_methods(1,val);
        [~,spec.T] = mGMPE_info(meth.str);
        
    case 'from List'
        spec.T = str2double(handles.periodlist.String);
end

spec.T = spec.T(:)'; % make sure is a row vector
spec.z = {...
    handles.method.Value,...
    str2double(handles.dampingratio.String),...
    handles.opt1.Value,...
    handles.opt2.Value,...
    handles.opt3.Value,...
    handles.opt4.Value,...
    str2double(handles.Tmin.String),...
    str2double(handles.Tmax.String),...
    str2double(handles.Nper.String),...
    handles.GMMpop.Value,...
    spec.T};
varargout{1} = spec;
delete(handles.figure1)

function method_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>

function method_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dampingratio_Callback(hObject, eventdata, handles)

function dampingratio_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function periodlist_Callback(hObject, eventdata, handles)

function periodlist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Tmin_Callback(hObject, eventdata, handles)

function Tmin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Tmax_Callback(hObject, eventdata, handles)

function Tmax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Nper_Callback(hObject, eventdata, handles)

function Nper_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GMMpop_Callback(hObject, eventdata, handles)

val     = handles.GMMpop.Value;
meth    = pshatoolbox_methods(1,val);
[~,periods] = mGMPE_info(meth.str);
handles.periodlist.String=num2cell(periods);
guidata(hObject,handles)

function GMMpop_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)

switch handles.uibuttongroup1.SelectedObject.String
    case 'logspaced'
        handles.Tmin.Enable='on';
        handles.Tmax.Enable='on';
        handles.Nper.Enable='on';
        handles.GMMpop.Enable = 'off';
        handles.periodlist.Enable = 'inactive';
        Tmin = str2double(handles.Tmin.String);
        Tmax = str2double(handles.Tmax.String);
        Nper = str2double(handles.Nper.String);
        handles.periodlist.String=num2cell(logsp(Tmin,Tmax,Nper));
        
    case 'linspaced'
        handles.Tmin.Enable='on';
        handles.Tmax.Enable='on';
        handles.Nper.Enable='on';
        handles.GMMpop.Enable = 'off';
        handles.periodlist.Enable = 'inactive';
        Tmin = str2double(handles.Tmin.String);
        Tmax = str2double(handles.Tmax.String);
        Nper = str2double(handles.Nper.String);
        handles.periodlist.String=num2cell(linspace(Tmin,Tmax,Nper));
        
    case 'from GMPE'
        handles.Tmin.Enable='off';
        handles.Tmax.Enable='off';
        handles.Nper.Enable='off';
        handles.GMMpop.Enable = 'on';
        handles.periodlist.Enable = 'inactive';
        val     = handles.GMMpop.Value;
        meth    = pshatoolbox_methods(1,val);
        [~,periods] = mGMPE_info(meth.str);
        handles.periodlist.String=num2cell(periods);
        
    case 'from List'
        handles.Tmin.Enable='off';
        handles.Tmax.Enable='off';
        handles.Nper.Enable='off';
        handles.GMMpop.Enable = 'off';
        handles.periodlist.Enable = 'on';
end

guidata(hObject,handles)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function RestoreButton_Callback(hObject, eventdata, handles)
load pshatoolbox_default_periods default_periods
handles=pop_options(handles,default_periods);
guidata(hObject,handles)



