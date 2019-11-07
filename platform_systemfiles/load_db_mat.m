function handles=load_db_mat(handles,fname)

load(fname)

% GM_setup
handles.db.header = header; %#ok<*USENS>
if ~isempty(strfind(header{16},'g'));          handles.accunits = 'g';     end
if ~isempty(strfind(header{16},'m/seg/seg'));  handles.accunits = 'm/s2';  end
if ~isempty(strfind(header{16},'m/s/s'));      handles.accunits = 'm/s2';  end
if ~isempty(strfind(header{16},'m/s'));        handles.accunits = 'm/s2';  end
if ~isempty(strfind(header{16},'cm/seg/seg')); handles.accunits = 'cm/s2'; end
if ~isempty(strfind(header{16},'cm/s/s'));     handles.accunits = 'cm/s2'; end
if ~isempty(strfind(header{16},'cm/s2'));      handles.accunits = 'cm/s2'; end
if ~isempty(strfind(header{16},'gal'));        handles.accunits = 'gal';   end
handles.tabla.ColumnName{9}=['PGA(',handles.accunits,')'];

if ~isempty(strfind(header{12},'m/seg'));      handles.Vs30units = 'm/s';  end
if ~isempty(strfind(header{12},'m/s'));        handles.Vs30units = 'm/s';  end
if ~isempty(strfind(header{12},'cm/seg'));     handles.Vs30units = 'cm/s'; end
if ~isempty(strfind(header{12},'cm/s'));       handles.Vs30units = 'cm/s'; end
handles.tabla.ColumnName{8}=['Vs30(',handles.Vs30units,')'];

H1 = handles.includeH1.Value==1;
H2 = handles.includeH2.Value==1;
UP = handles.includeUP.Value==1;

if exist('station','var')
    handles.station=station;
end

raw(:,end+1:end+3)=cell(size(raw,1),3); %#ok<*NODEF>
for i=1:size(raw,1)
    raw{i,17}=H1;
    raw{i,18}=H2;
    raw{i,19}=UP;
end

handles.db.rawR = raw;
ind = ones(size(raw,1),1);

if ~handles.Interface.Value
    m = strcmp('Interface',handles.db.rawR(:,2));
    ind(m)=0;
end

if ~handles.IntermediateDepth.Value
    m = strcmp('Intraslab',handles.db.rawR(:,2));
    ind(m)=0;
end

if ~handles.StrikeSlip.Value
    m = strcmp('Strike-Slip',handles.db.rawR(:,2));
    ind(m)=0;
end
if ~handles.Normal.Value
    m = strcmp('Normal',handles.db.rawR(:,2));
    ind(m)=0;
end
if ~handles.Reverse.Value
    m = strcmp('Reverse',handles.db.rawR(:,2));
    ind(m)=0;
end
if ~handles.ReverseOblique.Value
    m = strcmp('Reverse-Oblique',handles.db.rawR(:,2));
    ind(m)=0;
end
if ~handles.NormalOblique.Value
    m = strcmp('Normal-Oblique',handles.db.rawR(:,2));
    ind(m)=0;
end

if ~handles.nomechanism.Value
    m = strcmp('Unspecified',handles.db.rawR(:,2));
    ind(m)=0;
end

ind = find(ind==1);
MaxR = str2double(get(handles.MaxResults,'string'));
if ~isnan(MaxR) && MaxR>=0
    if MaxR<=length(ind)
        ind = ind(1:MaxR);
    end
end

for i=1:1:size(raw,1)
    if isnan(handles.db.rawR{i,2})
        handles.db.rawR{i,2} = '  ';
        raw{i,2}=' ';
    end
end
data = handles.db.rawR(ind,[1,2,3,4,5,6,11,12,16,13,14,15,17,18,19]);
if isempty(handles.tabla.Data)
    handles.tabla.Data=data;
    updatecounters(handles);
    handles.db.raw  = raw;
    handles.db.rawR = cell(0,19);
else
    dataaux=handles.tabla.Data;
    handles.tabla.Data=[dataaux;data];
    updatecounters(handles);
end
handles.overwrite      = zeros(size(handles.tabla.Data,1),2);
handles.datenum        = datenum(handles.db.raw(:,4),'yyyy-mm-dd');

stalibrary             = {handles.station.label}';
[~,handles.Bsta] = ismember(handles.db.raw(:,5),stalibrary);

handles.site_selection = 1:length(station);
handles.disp_accelerogram.Enable='on';
handles.disp_fourier.Enable='on';
handles.disp_spectra.Enable='on';
handles.ExportSelection.Enable='on';
handles.Interface.Enable='on';
handles.IntermediateDepth.Enable='on';
handles.StrikeSlip.Enable='on';
handles.Normal.Enable='on';
handles.Reverse.Enable='on';
handles.ReverseOblique.Enable='on';
handles.NormalOblique.Enable='on';
handles.nomechanism.Enable='on';
handles.HoldPlot.Value=0;
handles.showgeomean.Value=0;
handles.show_design.Value=0;
handles.showgeomean.Enable='off';
handles.show_design.Enable='off';
