function handles = create_mesh_select(handles)

ellipsoid = handles.opt.ellipsoid;
shape  = handles.shape;
active = find(vertcat(handles.shape.active))';
p      = get(handles.p,'data');
t      = handles.t;

% ---------- delete existing shape_points ------
p1  = p(:,1);
ind = false(size(p1));
for i=1:size(p1,1)
    if strfind(p1{i},'shape_')
        ind(i)=true;
    end
end
p(ind,:)=[];

t1  = handles.t(:,1);
ind = false(size(t1));
for i=1:size(t1,1)
    if strfind(t1{i},'shape_')
        ind(i)=true;
    end
end
t(ind,:)=[];

% -----------------------------------------------
for i=active
    X=shape(i).BoundingBox(:,1);mX =mean(X);
    Y=shape(i).BoundingBox(:,2);mY =mean(Y);
    X = (X-mX)*1.1+mX; X=X([1,2,2,1]);
    Y = (Y-mY)*1.1+mY; Y=Y([1,1,2,2]);
    pv         = [X,Y];
    conversion = EarthRadius(mean(Y),ellipsoid)*pi/180;
    thmax      = handles.lmax/conversion;
    [psm,tsm]  = mesh_quad2D(pv,thmax,0);
    
    switch handles.ElevModel
        case 1,Elev=psm(:,1)*0;
        case 2,Elev=getElevations(psm(:,2),psm(:,1))/1000;
    end
    
    % updates gps coordinates
    Vs30 = getVs30(psm(:,[2,1]),handles.Vs30);
    sh_id = ['shape_',num2str(i)];
    for j=1:size(psm,1)
        id_g = [sh_id,'-P',num2str(j)];
        p(end+1,:) = {id_g,psm(j,2),psm(j,1),Elev(j),Vs30(j)}; %#ok<*AGROW>
    end
    
    % updates connectivity
    t{end+1,1}=sh_id;
    t{end,2}  = tsm;
end
set(handles.p,'data',p);
handles.t = t;
plotsiteselect(handles);

