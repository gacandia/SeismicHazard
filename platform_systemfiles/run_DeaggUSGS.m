function handles=run_DeaggUSGS(handles)

% distance bins
opt  = handles.opt;
Rbin = handles.Rbin;
Mbin = handles.Mbin;

IM  = handles.IM_menu.String{handles.IM_menu.Value};
gps = cell2mat(handles.h.p(1,2:3));
RP  = str2double(handles.RP.String);

tempname1 = [tempname,'.bin'];
tempname2 = [tempname,'.csv'];
tempname3 = [tempname,'.csv']; %['PGA_hazardcurve' '.csv']
DownloadJsonDataSH(opt,gps,RP,IM,tempname1,tempname2,tempname3);
MWIN = unique(round(Mbin(:)*10)/10)';
RWIN = unique(round(Rbin(:)*10)/10)';
 
dg1  = ProcessDeaggSH (MWIN, RWIN, tempname2);
dg1  = permute(dg1,[2,3,1]);
delete(tempname1)
delete(tempname2)
delete(tempname3)
updateZValue(handles.b,dg1);
% ZLIM = handles.ax1.ZLim;
% ZLIM(2)=min(max(ceil(Zmax/5)*5+5),100);
% handles.ax1.ZLim=ZLIM;

function DownloadJsonDataSH(opt, gps,RP,IM,tempname1,tempname2,tempname3)

roots   = 'https://earthquake.usgs.gov/nshmp-haz-ws/deagg';
url     = sprintf('%s/%s/%s/%g/%s/%s/%i/%i/',roots,opt.Edition, opt.Region, gps(2), gps(1),IM, opt.Vs30, RP);

% while (1)
%     data     = urlread(url);
%     pre_data = loadjson(data);
%     if isfield(pre_data, 'response')
%         break
%     end
% end

data     = urlread(url); %#ok<*URLRD>
file1 = fopen(tempname1,'w');
fwrite(file1, unicode2native(data, 'UTF-8' ));
fclose(file1);

file1  = fopen(tempname1, 'r');
file2  = fopen(tempname2, 'w');
file3  = fopen(tempname3, 'w');
precision = 15;

data = loadjson(native2unicode(fscanf(file1,'%s'), 'UTF-8'));
data = data.response{1,1}.data;
% the total deaggregation
holder = 0.0;

for j = 1:length(data{1,1}.data)
    t = [num2str(data{1,1}.data{1,j}.r, precision), ',',num2str(data{1,1}.data{1,j}.m, precision) ];
    
    % If the value is 0, then it is derived. Assume it doesn't exist unless a value is found
    tem = [0,0,0,0,0,0,0,0,0,0,0,0];
    % each line of inputs in csvs
    etotal = 0;
    %data{1,1}.data{1,j}
    for k = 1:length(data{1,1}.data{1,j}.x0xCE__0xB5_data)
        % e12 is the first element in the array
        tem(12 - data{1,1}.data{1,j}.x0xCE__0xB5_data{1,k}.x0xCE__0xB5_bin)...
            = data{1,1}.data{1,j}.x0xCE__0xB5_data{1,k}.value;
        etotal = etotal + data{1,1}.data{1,j}.x0xCE__0xB5_data{1,k}.value;
        holder = holder + data{1,1}.data{1,j}.x0xCE__0xB5_data{1,k}.value;
    end
    % handle the derived attribute
    t = [t ',' num2str(etotal, precision)]; %#ok<*AGROW>
    for s = 1:12
        t = [t ',' num2str(tem(s), precision)];
    end
    fwrite(file2, sprintf([t '\n']));
end

fwrite(file3, sprintf([num2str(data{1,1}.summary{1,1}.data{1,3}.value, precision) ',' num2str(data{1,1}.summary{1,2}.data{1,2}.value, precision) '\n']));
fclose(file1);
fclose(file2);
fclose(file3);
disp ('USGS Integration Finished')

function [DEAG] = ProcessDeaggSH (Mwin, Rwin, tempname2)

dim   = [length(Mwin)-1, length(Rwin)-1];
DEAG  = zeros(dim);
USGS  = csvread(tempname2);
contr = sum(USGS(:,3));
[s_USGS, ~] = size(USGS);
for i = 1:dim(1)
    for j = 1:dim(2)
        for k = 1:s_USGS
            if Mwin(i) <= USGS(k,2) && USGS(k,2) < Mwin(i+1) && Rwin(j) <= USGS(k,1) && USGS(k,1) < Rwin(j+1)
                DEAG(i,j) = DEAG(i,j) + USGS(k,3) / contr;
            end
        end
    end
end

