function handles=ss_readtxt(handles,filename,pathname)
fid = fopen([pathname,filename]);
data = textscan(fid,'%s','delimiter','\n');
data = data{1};
fclose(fid);

newline = data{1};

if strcmp(newline,'Site Selection Tool')
    newline = data{2};
    linea   = regexp(newline,'\s+','split');
    Nsites  = str2double(linea{2});
    p       = cell(Nsites,5);
    for i=1:Nsites
        linenum = i+2;
        newline = data{linenum};
        linea   = regexp(strtrim(newline),'\s+','split');
        id      = strjoin(linea(1:end-5),' ');
        Lat     = str2double(linea{end-4});
        Lon     = str2double(linea{end-3});
        Elev    = str2double(linea{end-2});
        Vs30    = str2double(linea{end-0});
        p(i,:)  = {id,Lat,Lon,Elev,Vs30};
    end
    set(handles.p,'data',p);
    site = cell2mat(p(:,2:3));
    if ~isempty(site)
        plotsiteselect(handles)
    end
    
    linenum =linenum+2;
    newline = data{linenum};
    linea   = regexp(newline,'\s+','split');
    Ngrid   = str2double(linea{2});
    
    handles.t = cell(Ngrid,2);
    for i=1:Ngrid
        linenum=linenum+1;
        newline  = data{linenum};
        newline  = regexp(newline,'\s+','split');
        vertices = str2double(newline{3});
        handles.t{i,1}=newline{1};
        handles.t{i,2}=getconn(data(linenum+(1:vertices),:));
        linenum=linenum+vertices;
    end
    
    if Ngrid==0
        return
    end
    linenum = linenum+1; newline = data{linenum};
    line = regexp(strtrim(newline),'\s+','split');
    handles.lmax = str2double(line{end});

    linenum = linenum+1; newline = data{linenum};
    line = regexp(strtrim(newline),'\ShapeFile :','split');
    line = strtrim(line{2});
    handles.fname=line;
    handles.opt.Boundary=line;
    handles.shape1.String={handles.fname};
    handles.shape1.Value=1;
    default_maps(handles,handles.ax1);
    
    linenum = linenum+1; newline = data{linenum};
    line    = regexp(strtrim(newline),'\s+','split');
    Nshape  = str2double(line{end});
    
    if Nshape==0
        return
    end
    
    active  = false(Nshape,1);
    for i=1:Nshape
        linenum = linenum+1; %newline = data{linenum};
        linenum = linenum+1; %newline = data{linenum};
        linenum = linenum+1; %newline = data{linenum};
        linenum = linenum+1; %newline = data{linenum};
        linenum = linenum+1; %newline = data{linenum};
        linenum = linenum+1; %newline = data{linenum};
        linenum = linenum+1; newline = data{linenum};
        line = regexp(strtrim(newline),'\s+','split');
        if strcmp(line{end},'1')
            active(i) = true;
        end
    end
    handles = create_shape_select(handles,handles.fname,handles.lmax,active);
else
    p = cell(0,5);
    % prepare data for reading
    ind = false(size(data,1),1);
    for j=1:size(data,1)
        ind(j)= isempty(data{j,1});
    end
    data(ind,:)=[];
    
    for i=1:size(data,1)
        newline = data{i};
        date    = regexp(newline,'\s+','split');
        str     = strjoin(date(1:end-5),' ');
        lat     = str2double(date{end-4});
        lon     = str2double(date{end-3});
        elev    = str2double(date{end-2});
        Vs30    = str2double(date{end-0});
        p(i,:)= {str,lat,lon,elev,Vs30};
    end
    set(handles.p,'data',p);
    plotsiteselect(handles)
    Ngrid     = 0;
    handles.t = cell(Ngrid,2);

end

function[conn]=getconn(data)
data  = strtrim(data);
Nvert = size(data,1);
Nnodes = length(regexp(data{1},'\s+','split'));
conn = zeros(Nvert,Nnodes);
for i=1:Nvert
    conn(i,:)= str2double(regexp(data{i},'\s+','split'));
end
    
    