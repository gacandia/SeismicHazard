function[handles]=load_db_xls(handles,fname)
[~,header]= xlsread(fname,'groundmotions','A1:P1'); 
col       = xlsread(fname,'groundmotions','A:A');
col       = 1+length(col);
[~,~,raw]=xlsread(fname,'groundmotions',['A2:P',num2str(col)]); %#ok<*ASGLU>

[~,b] = xlsread(fname,'stations','A:A');
Nsta = length(b)-1;
[~,~,stationdata]=xlsread(fname,'stations',['A2:G',num2str(length(b))]);
station(1:Nsta)=struct('label',[],'gps',[],'Vs30',[],'Vstype',[],'Azimuth',[]);

for i=1:Nsta
   station(i).label     = stationdata{i,1}; 
   station(i).gps       = cell2mat(stationdata(i,2:4));
   station(i).Vs30      = cell2mat(stationdata(i,5));
   station(i).Vstype    = stationdata{i,6}; 
   station(i).Azimuth   = stationdata{i,7}; 
end

[A,B]=fileparts(fname);
newfname = [fullfile(A,B),'.mat'];
save(newfname,'raw','station','header');
handles=load_db_mat(handles,newfname);

