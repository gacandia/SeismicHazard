function h = ss_readtxtPSHA(filename)

fid = fopen(filename);
data = textscan(fid,'%s','delimiter','\n');
data = data{1};
fclose(fid);

% removes empty lines
emptylist= [];
for i=1:size(data,1)
    if isempty(data{i,1})
        emptylist=[emptylist,i]; %#ok<*AGROW>
    end
end
data(emptylist,:)=[];

% removes multiple spaces
data=regexprep(data,' +',' ');

newline = data{1};

if strcmp(newline,'Site Selection Tool')
    newline = data{2};
    linea   = regexp(newline,'\s+','split');
    Nsites  = str2double(linea{2});
    p       = regexp(data(3:2+Nsites,:),'\ ','split');
    
    for kk=1:length(p)
       if length(p{kk})==4
           p{kk}(5:6)={'Vs30',nan};
       end
    end
    p       = vertcat(p{:}); 
    p(:,5)  =[];
    
    linenum =Nsites+3;
    newline = data{linenum};
    linea   = regexp(newline,'\s+','split');
    Ngrid   = str2double(linea{2});
    
    t = cell(Ngrid,2);
    for i=1:Ngrid
        linenum=linenum+1;
        newline  = data{linenum};
        newline  = regexp(newline,'\s+','split');
        vertices = str2double(newline{3});
        t{i,1}=newline{1};
        t{i,2}=getconn(data(linenum+(1:vertices),:));
        linenum=linenum+vertices;
    end
    
    if Ngrid==0
        return
    end
    linenum = linenum+1; newline = data{linenum};
    line = regexp(strtrim(newline),'\s+','split');
    lmax = str2double(line{end});
   
    h.p     = [p(:,1),num2cell(str2double(p(:,2:4)))];
    h.t     = t;
    h.shape = [];
    h.lmax  = lmax;
    h.Vs30  = str2double(p(:,5));
    
else
    p   = regexp(data,'\ ','split');
    p   = vertcat(p{:}); 
    p(:,5)  =[];
    h.p     = [p(:,1),num2cell(str2double(p(:,2:4)))];
    h.t     = cell(0,2);
    h.shape = [];
    h.lmax  = 50;
    h.Vs30  = str2double(p(:,5));
end

function[conn]=getconn(data)
data  = strtrim(data);
Nvert = size(data,1);
Nnodes = length(regexp(data{1},'\s+','split'));
conn = zeros(Nvert,Nnodes);
for i=1:Nvert
    conn(i,:)= str2double(regexp(data{i},'\s+','split'));
end
    