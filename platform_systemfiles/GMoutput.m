function varargout = GMoutput(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GMoutput_OpeningFcn, ...
                   'gui_OutputFcn',  @GMoutput_OutputFcn, ...
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

function GMoutput_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

handles.exitmode = 1;
handles.spec=varargin{1}.spec;

iout = varargin{1}.out;
handles.filepath.String           = iout.fname;
handles.acceleration.Value        = iout.acceleration;
handles.velocity.Value            = iout.velocity;
handles.displacement.Value        = iout.displacement;
handles.pga.Value                 = iout.PGA;
handles.pgv.Value                 = iout.PGV;
handles.pgd.Value                 = iout.PGD;
handles.sa.Value                  = iout.SA;
handles.sv.Value                  = iout.SV;
handles.sd.Value                  = iout.SD;
handles.D595.Value                = iout.D595;
handles.D2575.Value               = iout.D2575;
handles.Dbracket.Value            = iout.Dbracket;
handles.MeanPeriod.Value          = iout.MeanPeriod;
handles.PredPeriod.Value          = iout.PredPeriod;
handles.AvgPeriod.Value           = iout.AvgPeriod;
handles.aRMS.Value                = iout.aRMS;
handles.CAV.Value                 = iout.CAV;
handles.arias.Value               = iout.Arias;
handles.CompH1.Value              = iout.compoments(1);
handles.CompH2.Value              = iout.compoments(2);
handles.CompHZ.Value              = iout.compoments(3);
handles.CompGeometricMean.Value   = iout.compoments(4);
handles.CompGMRotDpp.Value        = iout.compoments(5);
handles.CompGMRotIpp.Value        = iout.compoments(6);
handles.percentile1.String        = sprintf('%g',iout.compoments(7));
handles.percentile2.String        = sprintf('%g',iout.compoments(8));
switch iout.outputunits
    case 'g - m/s - m'      , handles.radiobutton2.Value=1;
    case 'g - cm/s - cm'    , handles.radiobutton3.Value=1;    
    case 'm/s2 - m/s - m'   , handles.radiobutton5.Value=1;
    case 'cm/s2 - cm/s - cm', handles.radiobutton6.Value=1;
end

handles.browseButt.CData = double(imread('browse2.jpg'))/255;
methods = pshatoolbox_methods(1);
methods(end)=[];
handles.gmpe.String = {'auto',methods.label};

guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = GMoutput_OutputFcn(hObject, eventdata, handles) 

% filename
out.fname        = handles.filepath.String;

% time histories
out.acceleration = handles.acceleration.Value;
out.velocity     = handles.velocity.Value;
out.displacement = handles.displacement.Value;

% response spectra
out.PGA          = handles.pga.Value;
out.PGV          = handles.pgv.Value;
out.PGD          = handles.pgd.Value;
out.SA           = handles.sa.Value;
out.SV           = handles.sv.Value;
out.SD           = handles.sd.Value;
out.method       = handles.spec.method;
out.damping      = handles.spec.damping;
out.T            = handles.spec.T;

% D595
out.D595         = handles.D595.Value;
out.D2575        = handles.D2575.Value;
out.Dbracket     = handles.Dbracket.Value;

% frequency content
out.MeanPeriod  = handles.MeanPeriod.Value;
out.PredPeriod  = handles.PredPeriod.Value;
out.AvgPeriod   = handles.AvgPeriod.Value;

% Other Parameters
out.aRMS        = handles.aRMS.Value;
out.CAV         = handles.CAV.Value;
out.Arias       = handles.arias.Value;

% other control parameters
out.outputunits  = handles.uibuttongroup1.SelectedObject.String;
out.compoments   = [...
    handles.CompH1.Value,...
    handles.CompH2.Value,...
    handles.CompHZ.Value,...
    handles.CompGeometricMean.Value,...
    handles.CompGMRotDpp.Value,...
    handles.CompGMRotIpp.Value,...
    str2double(handles.percentile1.String),...
    str2double(handles.percentile2.String)];

out.exitmode     = handles.exitmode;
varargout{1} = out;
delete(handles.figure1)

% ----------------- PANEL: TIME HISTORIES  --------------------------------
function acceleration_Callback(hObject, eventdata, handles)

function velocity_Callback(hObject, eventdata, handles)

function displacement_Callback(hObject, eventdata, handles)

% ----------------- PANEL: RESPONSE SPECTRA--------------------------------
function pga_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>

function pgv_Callback(hObject, eventdata, handles)

function pgd_Callback(hObject, eventdata, handles)

function sa_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 1, handles.text2.Visible='on';  handles.gmpe.Visible='on';
    case 0, handles.text2.Visible='off'; handles.gmpe.Visible='off';
end

function sv_Callback(hObject, eventdata, handles)

function sd_Callback(hObject, eventdata, handles)

function updateSpec_Callback(hObject, eventdata, handles)
handles.spec = Option_sdof_spectra(handles.spec);
guidata(hObject,handles)

% ----------------- PANEL: DURATION ---------------------------------------
function D595_Callback(hObject, eventdata, handles)

function D2575_Callback(hObject, eventdata, handles)

function Dbracket_Callback(hObject, eventdata, handles)

% ----------------- PANEL: FREQUENCY CONTENT-------------------------------
function MeanPeriod_Callback(hObject, eventdata, handles)

function PredPeriod_Callback(hObject, eventdata, handles)

function AvgPeriod_Callback(hObject, eventdata, handles)


% ----------------- PANEL: OTHER PARAMETERS--------------------------------
function aRMS_Callback(hObject, eventdata, handles)

function CAV_Callback(hObject, eventdata, handles)

function arias_Callback(hObject, eventdata, handles)

% ----------------- FILENAME ----------------------------------------------
function filepath_Callback(hObject, eventdata, handles)

function filepath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browseButt_Callback(hObject, eventdata, handles)

[filename, pathname,filterindex]=  uiputfile(handles.filepath.String,'Save Ground Motion Selection');
if filterindex==0
else
    handles.filepath.String=[pathname,filename];
end

% ----------------- Components --------------------------------------------
function CompH1_Callback(hObject, eventdata, handles)

function CompH2_Callback(hObject, eventdata, handles)

function CompHZ_Callback(hObject, eventdata, handles)

function CompGeometricMean_Callback(hObject, eventdata, handles)

function CompGMRotDpp_Callback(hObject, eventdata, handles)

function CompGMRotIpp_Callback(hObject, eventdata, handles)

function percentile1_Callback(hObject, eventdata, handles)

function percentile1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function percentile2_Callback(hObject, eventdata, handles)

function percentile2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ----------------- Exit GUI ----------------------------------------------
function OK_button_Callback(hObject, eventdata, handles)
handles.exitmode = 1;
guidata(hObject,handles);
close(handles.figure1)

function Cancel_Button_Callback(hObject, eventdata, handles)
handles.exitmode = 0;
guidata(hObject,handles);
close(handles.figure1)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
guidata(hObject,handles);
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
% delete(hObject);
