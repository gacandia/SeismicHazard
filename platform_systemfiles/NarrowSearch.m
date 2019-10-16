function handles=NarrowSearch(handles)

if ~isfield(handles.db,'raw')
    return
end

% process filters 1 to 4
filtro = handles.filtros.Data;
for i=1:4
    if isempty(filtro{i,1})
        filtro{i,1}=0;
    else
        filtro{i,1}=str2double(filtro{i,1});
    end
    if isempty(filtro{i,2})
        filtro{i,2}=inf;
    else
        filtro{i,2}=str2double(filtro{i,2});
    end
end

% process filter 5
if isempty(filtro{5,1})
    filtro{5,1}=-inf;
else
    filtro{5,1}=datenum(filtro{5,1},'yyyy-mm-dd');
end

if isempty(filtro{5,2})
    filtro{5,2}= inf;
else
    filtro{5,2}=datenum(filtro{5,2},'yyyy-mm-dd');
end


% apply filters 1 to 5
ind  = ones(size(handles.db.raw,1),1);
for i=1:size(filtro,1)
    f1 =filtro{i,1};
    f2 =filtro{i,2};
    if f1<=f2
        switch i
            case 1,f = cell2mat(handles.db.raw(:,6)); ind =ind .* and(f>=f1,f<=f2); %Magnitude
            case 2,f = cell2mat(handles.db.raw(:,11));ind =ind .* and(f>=f1,f<=f2); %Distance
            case 3,f = cell2mat(handles.db.raw(:,12));ind =ind .* and(f>=f1,f<=f2); %Vs30
            case 4,f = cell2mat(handles.db.raw(:,16));ind =ind .* and(f>=f1,f<=f2); %PGA
            case 5, ind =ind .* and(handles.datenum>=f1,handles.datenum<=f2);       %DATE
        end
    end
end

% apply mechanism filters
if ~handles.Interface.Value,          m = strcmp('Interface',      handles.db.raw(:,2)); ind(m)=0; end
if ~handles.IntermediateDepth.Value,  m = strcmp('Intraslab',      handles.db.raw(:,2)); ind(m)=0; end
if ~handles.StrikeSlip.Value,         m = strcmp('Strike-Slip',    handles.db.raw(:,2)); ind(m)=0; end
if ~handles.Normal.Value,             m = strcmp('Normal',         handles.db.raw(:,2)); ind(m)=0; end
if ~handles.Reverse.Value,            m = strcmp('Reverse',        handles.db.raw(:,2)); ind(m)=0; end
if ~handles.ReverseOblique.Value,     m = strcmp('Reverse-Oblique',handles.db.raw(:,2)); ind(m)=0; end
if ~handles.NormalOblique.Value,      m = strcmp('Normal-Oblique', handles.db.raw(:,2)); ind(m)=0; end
if ~handles.nomechanism.Value,        m = strcmp('Unspecified',    handles.db.raw(:,2)); ind(m)=0; end


% apply station filter
m =~ismember(handles.Bsta,handles.site_selection);
ind(m)=0;

% apply number of entries
ind = find(ind==1);
MaxR = str2double(get(handles.MaxResults,'string'));
if ~isnan(MaxR) && MaxR>=0
    if MaxR<=length(ind)
        ind = ind(1:MaxR);
    end
end

handles.tabla.Data= handles.db.raw(ind,[1,2,3,4,5,6,11,12,16,13,14,15,17,18,19]);
handles.currentind = [];
delete(findall(handles.axes3,'type','line'));
