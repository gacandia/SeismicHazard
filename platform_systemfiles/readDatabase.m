function alldata = readDatabase(filename)

alldata=xlsread(filename);
if isempty(alldata)
    fid=fopen(filename);
    C = textscan(fid,'%s','headerlines',4); C= C{1};
    fclose(fid);
    
    if ismember(';',C{1})
        strpat = '\;';
    elseif ismember(',',C{1})
        strpat = '\,';
    end
    Neq = size(C,1);
    alldata =zeros(Neq,7);
    for i=1:Neq
        line=regexp(C{i},strpat,'split');
        alldata(i,:)=str2double(line([4,7,8,13,17,21,18]));
    end
    
else
    alldata=alldata(4:end,[4,7,8,13,17,21,18]);
end
