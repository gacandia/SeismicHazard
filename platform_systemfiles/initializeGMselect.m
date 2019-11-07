function handles = initializeGMselect(handles)

poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    handles.poolsize = 0;
else
    handles.poolsize = poolobj.NumWorkers;
end
if handles.poolsize==0
    handles.Parpoolsetup.Checked='off';
else
    handles.Parpoolsetup.Checked='on';
end

handles.tabla.Data        = cell(0,15); updatecounters(handles);
handles.Pallet.CData      = double(imread('Pallet.jpg'))/255;
handles.Exit_button.CData = double(imread('Exit.jpg'))/255;
handles.AutoTrim.CData    = double(imresize(imread('TimeHistory.jpg'),[24 24]))/255;
handles.ManualTrim.CData  = double(imread('Trim.jpg'))/255;
handles.restoretrim.CData = double(imread('restore.jpg'))/255;
handles.erase.CData       = double(imread('erase.jpg'))/255;
handles.axisscale.CData   = double(imresize(imread('Ruler.jpg'),[20 20]))/255;
handles.undock.CData      = double(imread('Undock.jpg'))/255;
handles.integrationButton.CData      = double(imread('avector.jpg'))/255;


handles.overwrite         = zeros(0,2);
handles.currentind        = [];
handles.removeind         = [];
handles.gmscale           = [];
handles.db.rawR           = cell(0,19);

load pshatoolbox_default_periods default_periods
handles.spec              = default_periods;
handles.param             = [0 Inf 5 5];
handles.paramAuto         = [0.02 0.95];
handles.AutoTrimPushed    = 0;
handles.buttomselected    = 1;

handles.showgeomean.Visible='on';
handles.show_design.Visible='on';
handles.showgeomean.Enable='off';
handles.show_design.Enable='off';

handles.designT  = nan(0,1);
handles.designSA = nan(0,1);
delete(findall(handles.axes3,'type','line'));

handles.HoldPlot.Value=0;    handles.HoldPlot.Enable='on';
handles.showgeomean.Value=0; handles.showgeomean.Enable='off';
handles.show_design.Value=0; handles.show_design.Enable='off';

ch=get(handles.Display_group,'children');
ch(3).Value=1;

handles.curr_ID.String='';
handles.curr_earthquake.String='';
handles.curr_filename.String='';
handles.curr_component.String='';
handles.figure1.Name='Ground Motion Explorer Toolbox';
if isfield(handles,'station')
    handles=rmfield(handles,'station');
end

handles.integrationLevel=0; % by default do not integrate. 1 for velocity, 2 for displacement
handles.Display_group.Title='Acceleration Display Options';

% detault output parameters
handles.out.fname        = sprintf('%s',fullfile(cd,'GMSelection.mat'));
handles.out.acceleration = 0;
handles.out.velocity     = 0;
handles.out.displacement = 0;
handles.out.PGA          = 1;
handles.out.PGV          = 1;
handles.out.PGD          = 0;
handles.out.SA           = 1;
handles.out.SV           = 0;
handles.out.SD           = 0;
handles.out.method       = default_periods.method;
handles.out.damping      = default_periods.damping;
handles.out.T            = default_periods.T;
handles.out.D595         = 0;
handles.out.D2575        = 0;
handles.out.Dbracket     = 0;
handles.out.MeanPeriod   = 0;
handles.out.PredPeriod   = 0;
handles.out.AvgPeriod    = 0;
handles.out.aRMS         = 0;
handles.out.CAV          = 0;
handles.out.Arias        = 0;
handles.out.outputunits  = 'g-m/s-m';
handles.out.compoments   = [0 0 0 1 0 0 50 50];
handles.out.exitmode     = 1;



