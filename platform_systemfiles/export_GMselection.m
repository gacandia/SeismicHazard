function export_GMselection(handles,fname)

data = handles.tabla.Data;
% converts date to numeric
for i=1:size(data,1)
    if isnumeric(data{i,4})
        data{i,4}=num2str(data{i,4});
    end
end

data=[data,num2cell(handles.overwrite)];

NF1  = '%-8s';
NF2  = ['%-',num2str(max(size(char(data(:,2)),2)+2,10)),'s'];
NF3  = ['%-',num2str(max(size(char(data(:,3)),2)+2,10)),'s'];
NF4  = ['%-',num2str(max(size(char(data(:,4)),2)+2,10)),'s'];
NF5  = ['%-',num2str(max(size(char(data(:,5)),2)+2,10)),'s'];
NF6  = '%-8s';
NF7  = '%-8s';
NF8  = '%-8s';
NF9  = '%-8s';
NF10 = ['%-',num2str(max(size(char(data(:,10)),2)+2,10)),'s'];
NF11 = ['%-',num2str(max(size(char(data(:,11)),2)+2,10)),'s'];
NF12 = ['%-',num2str(max(size(char(data(:,12)),2)+2,10)),'s'];
NF13 = '%-3s';
NF14 = '%-3s';
NF15 = '%-3s';
NF16 = '%-8s';
NF17 = '%-8s';
spat = [NF1,NF2,NF3,NF4,NF5,NF6,NF7,NF8,NF9,NF10,NF11,NF12,NF13,NF14,NF15,NF16,NF17,' \n'];

fileID = fopen(fname,'w');
fprintf(fileID,spat,...
    'ID',...
    'Mechanism',...
    'Earthquake',...
    'Date',...
    'Station',...
    'M',...
    'Dist',...
    'Vs30',...
    'PGA',...
    'Filename H1',...
    'Filename H2',...
    'Filename UP',...
    'H1',...
    'H2',...
    'UP',...
    'trim1',...
    'trim2');

s=strrep(spat,'%','');
s=strrep(s(2:end-2),'s','');
s=regexp(s,'\-','split');
s=sum(str2double(s));
fprintf(fileID,[repmat('-',1,s),'\n']);

NF1  = '%-8d';
NF2  = ['%-',num2str(max(size(char(data(:,2)),2)+2,10)),'s'];
NF3  = ['%-',num2str(max(size(char(data(:,3)),2)+2,10)),'s'];
NF4  = ['%-',num2str(max(size(char(data(:,4)),2)+2,10)),'s'];
NF5  = ['%-',num2str(max(size(char(data(:,5)),2)+2,10)),'s'];
NF6  = '%-8.2f';
NF7  = '%-8.1f';
NF8  = '%-8.1f';
NF9  = '%-8.3f';
NF10 = ['%-',num2str(max(size(char(data(:,10)),2)+2,10)),'s'];
NF11 = ['%-',num2str(max(size(char(data(:,11)),2)+2,10)),'s'];
NF12 = ['%-',num2str(max(size(char(data(:,12)),2)+2,10)),'s'];
NF13 = '%-3g';
NF14 = '%-3g';
NF15 = '%-3g';
NF16 = '%-8.2f';
NF17 = '%-8.2f';
spat = [NF1,NF2,NF3,NF4,NF5,NF6,NF7,NF8,NF9,NF10,NF11,NF12,NF13,NF14,NF15,NF16,NF17,' \n'];

for i=1:size(data,1)
    fprintf(fileID,spat,...
        data{i,1},data{i,2},data{i,3},data{i,4},data{i,5},data{i,6},data{i,7},data{i,8},data{i,9},data{i,10},data{i,11},data{i,12},data{i,13},data{i,14},data{i,15},data{i,16},data{i,17});
end
fclose(fileID);
open(fname)