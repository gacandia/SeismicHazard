function[T,eq]=readCSS_Output(handles)

data=regexprep(handles.inCSS5,' +',' ');
Nth  = regexp(data{1},'\ Total','split');   Nth  = str2double(Nth{1});
Nper = regexp(data{2},'\ nPeriod','split'); Nper = str2double(Nper{1});
T    = str2double(regexp(data{3},'\ ','split'));

eq(1:Nth,1) = struct('Index',[],'HazLevel',[],'RSN',[],'EqID',[],'Scalefactor_h',[],'rate',[],'SA',[]);
for i=1:Nth
    datai      = regexp(data{4+i},'\ ','split');
    datai      = str2double(datai);
    eq(i).SA   = datai(3:end);
end

data =regexprep(handles.inCSS4,' +',' ');
data=data(7:end);
for i=1:Nth
    line = regexp(strtrim(data{i}),'\ ','split');
    numline               = str2double(line(1:13));
    eq(i).Index           = numline(1);
    eq(i).HazLevel        = numline(2);
    eq(i).RSN             = numline(3);
    eq(i).EqID            = numline(4);
    eq(i).Scalefactor_h   = numline(10);
    eq(i).rate            = numline(12);
end