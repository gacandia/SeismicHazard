function plot_hazardmap_PSHA(handles)

v = handles.site_colors;
MapOptions = handles.HazOptions;
delete(findall(handles.FIGSeismicHazard,'Tag','Colorbar'));
pall={'parula','autumn','bone','colorcube','cool','copper','flag','gray','hot','hsv','jet','lines','pink','prism','spring','summer','white','winter'};
pallet = pall{MapOptions.map(2)};
set(handles.FIGSeismicHazard,'colormap',feval(pallet));
ch=findall(handles.ax1,'tag','gmap'); uistack(ch,'bottom');

nt = size(handles.h.t,1);
for i=1:nt
    ch = findall(handles.ax1,'tag',num2str(i));
    delete(ch);
end
ch=findall(handles.ax1,'Tag','satext');delete(ch);

umax = -inf;
umin = inf;
label = handles.h.id;
p     = handles.h.p(:,[2,1]);

if ~isempty(handles.h.shape)
    active = vertcat(handles.h.shape.active);
    active = find(active);
end
ii     = 1;
text(NaN,NaN,'','parent',handles.ax1,'Tag','satext');

% This piece of code prevents the patches to be generated for paths elements
t      = handles.h.t;
ispath = regexp(t(:,1),'path');
for i=1:length(ispath)
    if isempty(ispath{i}),ispath{i}=0;end
end
ispath=cell2mat(ispath);
t(ispath==1,:)=[];

for i=1:size(t,1)
    vptr=regexp(label,t{i});
    for j=1:length(vptr)
        if isempty(vptr{j})
            vptr{j}=0;
        end
    end
    vptr = find(cell2mat(vptr));
    x    = p(vptr,1);
    y    = p(vptr,2);
    u    = v(vptr);
    F =  scatteredInterpolant(x,y,u,'linear','none');
    handles.TriScatterd{i}=F;
    if regexp(t{i,1},'grid')
        conn = t{i,2};
        gps  = [x,y];
        in   = 1:size(gps,1);
    end
    
    if regexp(t{i,1},'shape')
        ind = active(ii);
        xl=handles.h.shape(ind).Lon';
        yl=handles.h.shape(ind).Lat';
        faces = handles.h.shape(ind).faces;
        pv =[xl,yl];
        gps  = zeros(0,2);
        conn = zeros(0,3);
        offset=0;
        for count=1:size(faces,1)
            indface = faces(count,:);
            indface(isnan(indface))=[];
            pvface = pv(indface,:);
            [gps_i,conn_i]=triangulate_maps(pvface,[x,y]);
            gps = [gps;gps_i]; %#ok<AGROW>
            conn = [conn;conn_i+offset]; %#ok<AGROW>
            offset=size(gps,1);
        end
        u = F(gps(:,1),gps(:,2));
        in = inpolygon(gps(:,1),gps(:,2),xl,yl);
        ii=ii+1;
    end
    handles.shading(i) = patch(...
        'parent',handles.ax1,...
        'vertices',gps,...
        'faces',conn,...
        'facevertexcdata',u,...
        'facecol','interp',...
        'edgecol','none',...
        'linewidth',0.5,...
        'facealpha',0.7,...
        'Tag',num2str(i),...
        'ButtonDownFcn',{@site_click_PSHA,handles,2},...
        'visible','on');
    uistack(handles.shading(i),'bottom') % move map to bottom (so it doesn't hide previously drawn annotations)
    
    uin = u;
    uin = uin(in);
    umin = min(min(uin),umin);
    umax = max(max(uin),umax);
    
end

if umin==umax
    umin=umin-1e-3;
    umax=umax+1e-3;
end

if ~isempty(t)
    caxis([umin umax])
end

ch = findall(handles.ax1,'tag','siteplot');
if all(v~=0)
    ch.CData=v;
    ch.ButtonDownFcn={@site_click_PSHA;handles;1};
end

if ~isempty(t)
    handles.po_contours.Enable='on';
    handles.po_contours.Value=1;
    handles.colorbar=colorbar('peer',handles.ax1,'location','eastoutside','position',[0.94 0.16 0.02 0.65],'ylim',[umin,umax]);
    set(get(handles.colorbar,'Title'),'String',handles.IM_select.String{handles.IM_select.Value})
    handles.ax1.ButtonDownFcn={@clear_satxt;handles};
end

h = findall(handles.ax1,'tag','gmap');
if ~isempty(h)
    h.ButtonDownFcn={@clear_satxt;handles};
    uistack(h,'bottom')
end

function clear_satxt(hObject,eventdata,handles) %#ok<*INUSL,*INUSD>
ch=findall(handles.ax1,'Tag','satext');delete(ch);

