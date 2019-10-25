function[]=CreateUHS_CSS(Periods,AEP,uhs_spec,nameUHS)

Nper = length(Periods);
Nhaz = length(AEP);

fid  = fopen('UHSref.out3');
data = textscan(fid,'%s','delimiter','\n');
data = strtrim(data{1});
fclose(fid);
data=strrep(data,'$ref1',sprintf('%i',Nhaz));
data=strrep(data,'$ref3',sprintf('%i',Nper));

% write 1
[~,B]=ismember(data,'$ref2');pos = find(B);
chunk1 = data(1:pos-1);
chunk2 = cell(Nhaz,1);
for i=1:Nhaz
    chunk2{i}=sprintf('%8.5E %.3f',AEP(i),1/AEP(i));
end
chunk3 = data(pos+1:end);
data = [chunk1;chunk2;chunk3];

% write 2
[~,B]=ismember(data,'$ref4');pos = find(B);
chunk1 = data(1:pos-1);
chunk2 = cell(Nper,1);
for i=1:Nper
    str=sprintf('   %.3f%16i           DCPP_run_all_12x.out3',Periods(i),i);
    chunk2{i}=str;
end
chunk3 = data(pos+1:end);
data = [chunk1;chunk2;chunk3];

% write 3
data=strrep(data,'$ref5',sprintf('%g ',AEP));
data=strrep(data,'$ref6',sprintf('%g ',1./AEP));

% write 4
[~,B]=ismember(data,'$ref7');pos = find(B);
chunk1 = data(1:pos-1);
chunk2 = cell(Nper,1);
for i=1:Nper
    str=[sprintf('%2i  %6.2f',i,Periods(i)),'  ',sprintf('%f ',uhs_spec(i,:))];
    chunk2{i}=str;
end
chunk3 = data(pos+1:end);
data = [chunk1;chunk2;chunk3];

fileID = fopen([nameUHS,'.out3'],'w');
fprintf(fileID,'%s\n',data{:});
fclose(fileID);

