function plot_scenario_PSDA2(handles,varargin)

delete(findall(handles.ax1,'tag','scenario'));

ind        = handles.pop_scenario.Value;
str        = strrep(handles.pop_scenario.String{ind},'scen ','');
ptrs       = str2double(regexp(str,'\-','split'));
shakefield = handles.shakefield(ptrs(1));
Lptr       = shakefield.Lptr(ptrs(2));
opt        = handles.opt;
hyp        = xyz2gps(shakefield.geom.hypm(ptrs(2),:),opt.ellipsoid);

switch handles.show_RA.Value
    case 1, VIS='on';
    case 2, VIS='off';
end
plot(handles.ax1,hyp(2),hyp(1),'ks','markerfacecolor','r','tag','scenario','visible',VIS);
switch handles.po_sites.Value
    case 0, VIS1='off';
    case 1, VIS1='on';
end

switch handles.po_contours.Value
    case 0, VIS2='off';
    case 1, VIS2='on';
end

switch handles.po_sites.Value+handles.po_contours.Value
    case 0,    VIS3='off';
    otherwise, VIS3='on';
end

IM_ptr = handles.pop_field.Value;
if iscell(handles.pop_field.String)
    xlabel(handles.ax2,handles.pop_field.String{IM_ptr},'fontsize',10)
else
    xlabel(handles.ax2,handles.pop_field.String,'fontsize',10)
end
ylabel(handles.ax2,'Mean Rate of Exceedance','fontsize',10)

% create scenario
Nsites  = length(handles.h.id);
val     = handles.pop_field.Value;
II      = (1:Nsites)+Nsites*(val-1);
mulogIM = shakefield.mulogIM(:,val,ptrs(2));
Nz      = size(handles.L,1);

switch handles.PSDA_display_mode.Value
    case 1
        Y = exp(mulogIM);
    case 2
        Y = normrnd(0,1,Nsites,1);
    case 3
        Z = normrnd(0,1,Nz,1);
        L = handles.L(II,:,Lptr);
        Y = exp(mulogIM+L*Z);
end
delete(findall(handles.FIGSeismicHazard,'Tag','Colorbar'));
pall={'parula','autumn','bone','colorcube','cool','copper','flag','gray','hot','hsv','jet','lines','pink','prism','spring','summer','white','winter'};
pallet = pall{handles.HazOptions.map(2)};
set(handles.FIGSeismicHazard,'colormap',feval(pallet));

% This piece of code prevents the patches to be generated for paths elements
t      = handles.h.t;
ispath = regexp(t(:,1),'path');
for i=1:length(ispath)
    if isempty(ispath{i}),ispath{i}=0;end
end
ispath=cell2mat(ispath);
t(ispath==1,:)=[];

delete(findall(handles.ax1,'tag','siteplot'));
delete(findall(handles.ax1,'Tag','satext'));
XY      = handles.h.p(:,1:2);

if size(t,1)==0
    scatter(handles.ax1,XY(:,2),XY(:,1),[],Y,'filled','markeredgecolor','k','tag','siteplot','visible',VIS1,...
        'ButtonDownFcn',{@site_click_PSDA;handles;1});
    handles.colorbar=colorbar('peer',handles.ax1,'location','eastoutside','position',[0.94 0.16 0.02 0.65]);
    CYLIM=sort([0.9*min(Y),1.1*max(Y)]);
    handles.colorbar.YLim = CYLIM;
    caxis(handles.ax1,CYLIM);
    handles.colorbar.Visible=VIS3;
    return
else
    handles.po_contours.Enable='on';
end
% ------------------------------------------------------------------------

ch=findall(handles.ax1,'tag','gmap'); uistack(ch,'bottom');
nt = size(handles.h.t,1);
for i=1:nt
    ch = findall(handles.ax1,'tag',num2str(i));
    delete(ch);
end

ch=findall(handles.ax1,'Tag','satext');delete(ch);
umax  = -inf;
umin  = inf;
label = handles.h.id;
p     = handles.h.p(:,[2,1]);

if ~isempty(handles.h.shape)
    active = vertcat(handles.h.shape.active);
    active = find(active);
end
ii     = 1;
handles.SaText = text(NaN,NaN,'','parent',handles.ax1,'Tag','satext');
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
    u    = Y(vptr);
    F    = scatteredInterpolant(x,y,u,'linear','none');
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
    
    
    
    shad=patch(...
        'parent',handles.ax1,...
        'vertices',gps,...
        'faces',conn,...
        'facevertexcdata',u,...
        'facecol','interp',...
        'edgecol','none',...
        'linewidth',0.5,...
        'facealpha',0.7,...
        'Tag',num2str(i),...
        'ButtonDownFcn',{@site_click_PSDA,handles,2},...
        'visible',VIS2);
    uistack(shad,'bottom') % move map to bottom (so it doesn't hide previously drawn annotations)
    
    uin = u;
    uin = uin(in);
    umin = min(min(uin),umin);
    umax = max(max(uin),umax);
    
end

caxis([umin umax])
YLIM = [umin,umax];
switch handles.po_sites.Value
    case 0, VIS='off';
    case 1, VIS='on';
end
scatter(handles.ax1,XY(:,2),XY(:,1),[],Y,'filled','markeredgecolor','k','tag','siteplot','visible',VIS1,'ButtonDownFcn',{@site_click_PSDA;handles;1},'visible',VIS);
handles.colorbar=colorbar('peer',handles.ax1,'location','eastoutside','position',[0.94 0.16 0.02 0.65],'ylim',YLIM);
handles.colorbar.Visible=VIS3;
handles.ax1.ButtonDownFcn={@clear_satxt,handles};

% restores map
h = findall(handles.ax1,'tag','gmap');
if ~isempty(h)
    h.ButtonDownFcn={@clear_satxt;handles};
    uistack(h,'bottom') % move map to bottom (so it doesn't hide previously drawn annotations)
end

function clear_satxt(hObject,eventdata,handles) %#ok<*INUSL,*INUSD>
findall(handles.ax1,'Tag','satext');

