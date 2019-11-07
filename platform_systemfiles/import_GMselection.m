function handles = import_GMselection(handles,fname)

fid  = fopen(fname);
line = fgetl(fid);
p1  = strfind(line,'ID');
p2  = strfind(line,'Mechanism');
p3  = strfind(line,'Earthquake');
p4  = strfind(line,'Date');
p5  = strfind(line,'Station');
p6  = strfind(line,'M');p6=p6(2);
p7  = strfind(line,'Dist');
p8  = strfind(line,'Vs30');
p9  = strfind(line,'PGA');
p10 = strfind(line,'Filename H1');
p11 = strfind(line,'Filename H2');
p12 = strfind(line,'Filename UP');
p13 = strfind(line,'H1'); p13=p13(2);
p14 = strfind(line,'H2'); p14=p14(2);
p15 = strfind(line,'UP'); p15=p15(2);
p16 = strfind(line,'trim1');
p17 = strfind(line,'trim2');

data = cell(1,15);
overwrite=zeros(1,2);
fgetl(fid);
line = fgetl(fid);
i=1;
while ischar(line)
    data{i,1}=eval(line(p1:p2-1));
    data{i,2}=deblank(line(p2:p3-1));
    data{i,3}=deblank(line(p3:p4-1));
    data{i,4}=deblank(line(p4:p5-1));
    data{i,5}=deblank(line(p5:p6-1));
    data{i,6}=eval(line(p6:p7-1));
    data{i,7}=eval(line(p7:p8-1));
    data{i,8}=eval(line(p8:p9-1));
    data{i,9}=eval(line(p9:p10-1));
    data{i,10}=deblank(line(p10:p11-1));
    data{i,11}=deblank(line(p11:p12-1));
    data{i,12}=deblank(line(p12:p13-1));
    data{i,13}=eval(line(p13:p14-1))==1;
    data{i,14}=eval(line(p14:p15-1))==1;
    data{i,15}=eval(line(p15))==1;
    overwrite(i,1)=eval(line(p16:p17-1));
    overwrite(i,2)=eval(line(p17:end));
    i=i+1;
    line = fgetl(fid);
end
fclose(fid);
handles.tabla.Data=data;
updatecounters(handles);
handles.overwrite = overwrite;

handles.disp_accelerogram.Enable='on';
handles.disp_fourier.Enable='on';
handles.disp_spectra.Enable='on';
handles.ExportSelection.Enable='on';
handles.filtros.Enable='off';
handles.HoldPlot.Value=0;
handles.showgeomean.Value=0;
handles.show_design.Value=0;
handles.showgeomean.Enable='off';
handles.show_design.Enable='off';