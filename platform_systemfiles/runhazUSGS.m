function handles=runhazUSGS(handles)

opt             = handles.opt;
p               = handles.h.p(:,1:2);
lat             = p(:,1);
lon             = p(:,2);
Nsites          = size(p,1);
Nim             = 20;
NIM             = length(handles.IM_select.String);
Nsource         = length(handles.model.source);
handles.opt.im  = [0.0025;0.0045;0.0075;0.0113;0.0169;0.0253;0.038;0.057;0.0854;0.128;0.192;0.288;0.432;0.649;0.973;1.46;2.19;3.28;4.92;7.38];
MRE          = nan(Nsites,Nim,NIM,Nsource);
handles.deagg   = cell(size(handles.MRE));

Edition  = opt.Edition;
Region   = opt.Region;
Vs30     = opt.Vs30;
IM       = opt.IM;
for i=1:length(IM)
    switch opt.IM{i}
        case 'PGA'       , IM{i}='PGA';
        case 'Sa(T=0.2)' , IM{i}='SA0P2';
        case 'Sa(T=1.0)' , IM{i}='SA1P0';
        case 'Sa(T=2.0)' , IM{i}='SA2P0';
    end
end
IMstr  = strjoin(IM,',');

fprintf('                               SEISMIC HAZARD ANALYSIS \n');
fprintf('-----------------------------------------------------------------------------------------------------------\n');
t0  = cputime;
rootst = 'https://earthquake.usgs.gov/nshmp-haz-ws/hazard';
for j=handles.site_selection
    t=cputime;
    url = sprintf('%s/%s/%s/%g/%g/%s/%g/%g/',rootst,Edition, Region, lon(j), lat(j),IMstr, Vs30);
    lam = read_USGS_hazard(url,IM,Nsource);
    MRE(j,:,:,:) = lam;
    fprintf('Runtime:  %-4.3f s\n',cputime-t);
    %fprintf('%-86s - Runtime:  %-4.3f s\n',url,cputime-t);
end


handles.MRE = MRE;
% load mydata

handles.IM_select.Enable='on';
handles.db_type.Enable='on';
handles.site_menu.Value=handles.site_selection(1);
plot_hazard_PSHA(handles);
plot_sites_PSHA(handles)

fprintf('-----------------------------------------------------------------------------------------------------------\n');
fprintf('%-88sTotal:     %-4.3f s\n','',cputime-t0);

if ~isempty(handles.h.t)
    handles.po_contours.Enable='on';
    handles.po_sites.Value=1;
    handles.HazardMap.Enable='on';
    handles.po_contours.Value=1;
    plot_hazardmap_PSHA(handles);
end


function[lambda]=read_USGS_hazard(url,IM,Nsource)
data = urlread(url); %#ok<*URLRD>
data = strtrim(regexp(data,'\n','split'))';
data = strrep(data,',','');

NIM    = length(IM);
lambda = zeros(20,NIM,Nsource);

for i=1:NIM
    str   = sprintf('"value": "%s"',IM{i});
    [~,B] = intersect(data,str);
    dataB = data(B+64:B+83,:);   lambda(:,i,1)=str2double(dataB)';
    dataB = data(B+89:B+108,:);  lambda(:,i,2)=str2double(dataB)';
    dataB = data(B+114:B+133,:); lambda(:,i,3)=str2double(dataB)';
    dataB = data(B+139:B+158,:); lambda(:,i,4)=str2double(dataB)';
    
    if Nsource==5
        dataB = data(B+164:B+183,:); lambda(:,i,5)=str2double(dataB)';
    end
end
