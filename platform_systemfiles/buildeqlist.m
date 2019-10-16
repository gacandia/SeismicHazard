
function[eq]=buildeqlist(handles)
data = handles.tabla.Data;
ROOT = handles.pathname;
Neq  = size(data,1);
eq(1:Neq,1:3)    = struct('earthquake',[],'date',[],'station',[],'component',[],'filename',[],'magnitude',[],'rrup',[],'gps_event',[],'gps_station',[],'Vs30',[],'dt',[],'acc',[],'T',[],'Sa',[]);

%% carga componentes del terremoto (no dependientes de un registro en particular)
for i=1:Neq
    eq(i,1).earthquake= data{i,3};  eq(i,2).earthquake = data{i,3};   eq(i,3).earthquake = data{i,3};
    eq(i,1).component = 'HNN';      eq(i,2).component  = 'HNE';       eq(i,3).component  = 'HNZ';
    eq(i,1).filename  = data{i,10}; eq(i,2).filename   = data{i,11};  eq(i,3).filename   = data{i,12};
    eq(i,1).date      = data{i,4};  eq(i,2).date       = data{i,4};   eq(i,3).date       = data{i,4};
    eq(i,1).station   = data{i,5};  eq(i,2).station    = data{i,5};   eq(i,3).station    = data{i,5};
    eq(i,1).magnitude = data{i,6};  eq(i,2).magnitude  = data{i,6};   eq(i,3).magnitude  = data{i,6};
    eq(i,1).rrup      = data{i,7};  eq(i,2).rrup       = data{i,7};   eq(i,3).rrup       = data{i,7};
    
    ind = data{i,1};
    gps_event = cell2mat(handles.db.raw(ind,8:10));
    eq(i,1).gps_event = gps_event; eq(i,2).gps_event  = gps_event; eq(i,3).gps_event = gps_event;
    
    if isfield(handles,'station')
        [~,sptr]=intersect({handles.station.label},data{i,5});
        gps_station = handles.station(sptr).gps;
        Vs30        = handles.station(sptr).Vs30;
        eq(i,1).gps_station = gps_station; eq(i,2).gps_station  = gps_station; eq(i,3).gps_station = gps_station;
        eq(i,1).Vs30        = Vs30;        eq(i,2).Vs30         = Vs30;        eq(i,3).Vs30         = Vs30;
    end
end


%% carga componentes HNN,HNE,HNZ
for i=1:Neq
    EQ       = data{i,3};
    
    % componente HHN
    FILE  = data{i,10};
    filea = regexp(FILE,'\.','split');
    
    switch filea{end}
        case 'at2'
            if data{i,13}
                NGA_ID = data{i,1};
                STR  = regexp(data{i,10},'\/','split');
                eq(i,1).filename  = ['NGA_no_',num2str(NGA_ID),'_',STR{end}];
                FULLPATH = fullfile(ROOT,eq(i,1).filename);
                [eq(i,1).dt,eq(i,1).acc]=readNGA(FULLPATH);
            end
        case 'txt'
            if data{i,13}
                FULLPATH = fullfile(ROOT,EQ,FILE);
                [eq(i,1).dt,eq(i,1).acc]=readSIBERRISK(FULLPATH);
            end
    end
    
    % componente HNE
    FILE  = data{i,11};
    filea = regexp(FILE,'\.','split');
    
    switch filea{end}
        case 'at2'
            if data{i,14}
                NGA_ID = data{i,1};
                STR  = regexp(data{i,11},'\/','split');
                eq(i,2).filename= ['NGA_no_',num2str(NGA_ID),'_',STR{end}];
                FULLPATH = fullfile(ROOT,eq(i,2).filename);
                [eq(i,2).dt,eq(i,2).acc]=readNGA(FULLPATH);
            end
        case 'txt'
            if data{i,14}
                FULLPATH = fullfile(ROOT,EQ,FILE);
                [eq(i,2).dt,eq(i,2).acc]=readSIBERRISK(FULLPATH);
            end
    end
    
    % componente HNZ
    FILE  = data{i,10};
    filea = regexp(FILE,'\.','split');
    switch filea{end}
        case 'at2'
            if data{i,15}
                NGA_ID     = data{i,1};
                STR  = regexp(data{i,12},'\\','split');
                eq(i,3).filename= ['NGA_no_',num2str(NGA_ID),'_',STR{end},'.at2'];
                FULLPATH   = fullfile(ROOT,eq(i,3).filename);
                [eq(i,3).dt,eq(i,3).acc]=readNGA(FULLPATH);
            end
        case 'txt'
            if data{i,15}
                FULLPATH = fullfile(ROOT,EQ,FILE);
                [eq(i,3).dt,eq(i,3).acc]=readSIBERRISK(FULLPATH);
            end
    end
end

%% APPLIES TRIM
overwrite = handles.overwrite;

for i=1:Neq
    ow = sum(abs(overwrite(i,:)));
    if data{i,13} && ow>0
        ACC         = eq(i,1).acc;
        TIME        = eq(i,1).dt*(0:length(ACC)-1);
        eq(i,1).acc = ACC(and(TIME>=overwrite(i,1)  ,TIME<=overwrite(i,2)));
    end
    
    if data{i,14} && ow>0
        ACC         = eq(i,2).acc;
        TIME        = eq(i,2).dt*(0:length(ACC)-1);
        eq(i,2).acc = ACC(and(TIME>=overwrite(i,1)  ,TIME<=overwrite(i,2)));
    end
    
    if data{i,15} && ow>0
        ACC     = eq(i,3).acc;
        TIME    = eq(i,3).dt*(0:length(ACC)-1);
        eq(i,3).acc = ACC(and(TIME>=overwrite(i,1)  ,TIME<=overwrite(i,2)));
    end
end

%% APPLYIES FILTERS
for i=1:Neq
    if data{i,13}
        ACC     = eq(i,1).acc;
        TIME    = eq(i,1).dt*(0:length(ACC)-1);
        eq(i,1).acc = butterworth(TIME,ACC,handles.param);
    end
    
    if data{i,14}
        ACC     = eq(i,2).acc;
        TIME    = eq(i,2).dt*(0:length(ACC)-1);
        eq(i,2).acc = butterworth(TIME,ACC,handles.param);
    end
    
    if data{i,15}
        ACC     = eq(i,3).acc;
        TIME    = eq(i,3).dt*(0:length(ACC)-1);
        eq(i,3).acc = butterworth(TIME,ACC,handles.param);
    end
end

%% COMPUTES SPECTRUM
for i=1:Neq
    if data{i,13}
        ACC     = eq(i,1).acc;
        TIME    = eq(i,1).dt*(0:length(ACC)-1);
        [eq(i,1).T,eq(i,1).Sa] = freqspec(TIME,ACC,handles.spec);
    end
    
    if data{i,14}
        ACC     = eq(i,2).acc;
        TIME    = eq(i,2).dt*(0:length(ACC)-1);
        [eq(i,2).T,eq(i,2).Sa] = freqspec(TIME,ACC,handles.spec);
    end
    
    if data{i,15}
        ACC     = eq(i,3).acc;
        TIME    = eq(i,3).dt*(0:length(ACC)-1);
        [eq(i,3).T,eq(i,3).Sa] = freqspec(TIME,ACC,handles.spec);
    end
end

