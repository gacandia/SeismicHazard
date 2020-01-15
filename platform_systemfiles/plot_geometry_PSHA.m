function handles=plot_geometry_PSHA(handles)

if isempty(handles.opt.ellipsoid.Code)
    xlabel(handles.ax1,'X (km)','fontsize',8,'fontname','arial','tag','xlabel')
    ylabel(handles.ax1,'Y (km)','fontsize',8,'fontname','arial','tag','ylabel')
else
    xlabel(handles.ax1,'Lon','fontsize',8,'fontname','arial','tag','xlabel')
    ylabel(handles.ax1,'Lat','fontsize',8,'fontname','arial','tag','ylabel')
end

delete(findall(handles.ax1,'tag','points'));
delete(findall(handles.ax1,'tag','lines'));
delete(findall(handles.ax1,'tag','areas'));
delete(findall(handles.ax1,'tag','areamesh'));
delete(findall(handles.ax1,'tag','linemesh'));

% axis(handles.ax1,'auto')
[A,B] = unique(handles.sys.BRANCH(:,1));
Ngeom = length(A);

meshcolor        = [0.6 0.6 1];
edgecolor        = [1 0.6 0.6];

% ---------- creates source mesh objects -----------------------
handles.po_sourcemesh.Enable='on';
for i=1:Ngeom
    bi       = B(i);
    model    = handles.model(bi);
    offset   = get_offset(model);
    xyzm=zeros(0,3);
    for cont=1:length(model.source)
        xyzm  = [xyzm;model.source(cont).geom.xyzm]; %#ok<*AGROW>
    end
    gpsm     = xyz2gps(xyzm,handles.opt.ellipsoid);
    
    % plots sqares and triangles
    conn     = vcatdss(model.source)+offset;
    conn2    = conn;
    del      = sum(isnan(conn),2)==size(conn,2);
    conn(del,:)=[];
    if isempty(conn)
        conn=nan;
    end
    handles.areamesh(i)=patch(...
        'parent',handles.ax1,...
        'vertices',gpsm(:,[2,1]),...
        'faces',conn,...
        'facecolor','none',...
        'facealpha',0.5,...
        'edgecol',meshcolor,...
        'tag','areamesh',...
        'visible','off');
    
    % plots linesources nodes
    del    = sum(isnan(conn2),2)~=2;
    conn2(del,:)=[];
    conn2(:,3:end)=[];
    %     if isempty(conn2)
    %         conn2=nan;
    %     end
    
    handles.linemesh(i)=patch(...
        'parent',handles.ax1,...
        'vertices',gpsm(:,[2,1]),...
        'faces',conn2,...
        'facecolor','none',...
        'marker','.',...
        'MarkerEdgeColor',[0 0 0],...
        'edgecol',[0 0 0],...
        'EdgeAlpha',0,...
        'tag','linemesh',...
        'visible','off');
end

% ---------- creates source edge objects -----------------------
handles.po_sources.Enable='on';

for i=1:Ngeom
    bi = B(i);
    model =handles.model(bi);
    gps1 = nan(1,3);
    gps2 = nan(1,3);
    gps3 = nan(1,3);
    centroid = zeros(0,2);
    for j=1:length(model.source)
        gps_j =model.source(j).vertices;
        centroid = [centroid;mean(gps_j(:,1:2),1)];
        switch model.source(j).type
            case 'point'
                gps1 =[gps1;gps_j];
            case 'line'
                gps2 =[gps2;gps_j;gps_j(1,:)*NaN];
            case 'area'
                % ojo aca, aun no soporta tria y quad together
                gps3 =[gps3;gps_j;gps_j(1,:);gps_j(1,:)*NaN];
            case 'background'
                % ojo aca, aun no soporta tria y quad together
                gps3 =[gps3;gps_j;gps_j(1,:);gps_j(1,:)*NaN];
            case 'fault'
                % ojo aca, aun no soporta tria y quad together
                gps3 =[gps3;gps_j;gps_j(1,:);gps_j(1,:)*NaN];
        end
    end
    % plots point sources
    handles.points(i)=plot(handles.ax1,gps1(:,2),gps1(:,1),...
        'color',[0 0 0],...
        'marker','s',...
        'linestyle','none',...
        'markerfacecolor',[0.8510    0.3255    0.0980],...
        'tag','points',...
        'visible','off');
    
    % plots linesources
    handles.lines(i)=plot(handles.ax1,gps2(:,2),gps2(:,1),...
        'color',[0 0 0],...
        'linestyle','-',...
        'markerfacecolor',[0.8510    0.6255    0.20],...
        'tag','lines',...
        'visible','off');
    % plot area edges
    conn = 1:size(gps3,1);
    handles.areas(i)=patch(...
        'parent',handles.ax1,...
        'vertices',gps3(:,[2,1]),...
        'faces',conn,...
        'facecolor','b',...
        'edgecol',edgecolor,...
        'tag','areas',...
        'visible','off');
    
    handles.TT{i}=text(handles.ax1,centroid(:,2),centroid(:,1),strrep({model.source.label},'_',' '),'fontsize',8,'fontweight','bold','visible','off','tag','sourcelabel','horizontalalignment','center');
end

% TurnsOn selected Source
reg = handles.po_region.Value;
set(handles.points(reg),'visible','on');
set(handles.lines(reg),'visible','on');
set(handles.areas(reg),'visible','on');
handles.SourceLabels.Enable='on';
switch handles.po_sourcemesh.Value
    case 0, VIS ='off';
    case 1, VIS ='on';
end
set(handles.areamesh(reg),'visible',VIS);
set(handles.linemesh(reg),'visible',VIS);


