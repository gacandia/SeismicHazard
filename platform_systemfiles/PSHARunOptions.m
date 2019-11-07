function varargout = PSHARunOptions(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PSHARunOptions_OpeningFcn, ...
    'gui_OutputFcn',  @PSHARunOptions_OutputFcn, ...
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

function PSHARunOptions_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
ihandles                = varargin{1};
handles.ax1             = ihandles.ax1;
handles.p               = ihandles.h.p;
handles.site_list.String = ihandles.h.id;
if isempty(ihandles.site_selection)
    handles.site_list.Value  = 1:size(handles.p,1);
else
    handles.site_list.Value  = ihandles.site_selection;
    full_list = length(ihandles.site_selection)==length(1:size(handles.p,1));
    if full_list
        handles.buttongroup.SelectedObject = handles.radiobutton4;
        handles.site_list.Value  = ihandles.site_selection;
    else
        handles.buttongroup.SelectedObject = handles.radiobutton5;
    end
end

handles.output          = [];
guidata(hObject, handles);
uiwait(handles.runOPT);

function varargout = PSHARunOptions_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.site_list.Value;
delete(handles.runOPT)

function runOPT_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);

function site_list_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
handles.selection=hObject.Value;
handles.buttongroup.SelectedObject = handles.radiobutton5;
guidata(hObject,handles)

function site_list_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function buttongroup_SelectionChangedFcn(hObject, eventdata, handles)

switch hObject.String
    case 'All'
        handles.site_list.Value =  1:size(handles.p,1);
    case 'From List'

    case 'Within Map Limits'
        x         = handles.p(:,2);
        y         = handles.p(:,1);
        xv        = handles.ax1.XLim([1,2,2,1])';
        yv        = handles.ax1.YLim([1 1 2 2])';
        handles.site_list.Value = find(inpolygon(x,y,xv,yv));
end

guidata(hObject,handles)
