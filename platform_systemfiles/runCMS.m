function runCMS(handles)

% set up data
ellipsoid   = handles.opt.ellipsoid;
site_ptr    = handles.pop_site.Value;
site        = cell2mat(handles.h.p(site_ptr,2:4));
Vs30        = handles.h.Vs30(site_ptr);
r0          = gps2xyz(site,ellipsoid);
model_ptr   = handles.pop_branch.Value;
Tcond       = str2double(handles.Cond_Period.String);
T           = UHSperiods(handles);
Tcond_ptr   = T==Tcond;
Tr          = str2double(handles.Ret_Period.String);

col         = find(handles.opt.IM>=0);
im1         = repmat(handles.opt.im(:,col(1)),1,length(T));
opt         = handles.opt;
model       = handles.model(model_ptr);
Nsource     = length(model.source);

% compute seismic hazard for all Sa(T*)
lambda1 = runhazard1(im1,T,site,Vs30,opt,model,Nsource,1);
lambda1 = permute(nansum(lambda1,4),[2 3 1]);

% compute Hazard Deagregation for T* at Return Period Tr
logy    = log(lambda1(:,Tcond_ptr));
logx    = log(im1(:,Tcond_ptr));
logyy   = log(1/Tr);
logxx   = interp1(logy,logx,logyy,'pchip');
im2     = exp(logxx);
opt2    = opt;
opt2.im = im2;
opt2.IM = Tcond;
lambda2 = nan(1,1,1,Nsource,1);
[deagg2]  = runhazard2(im2,Tcond,site,Vs30,opt2,model,Nsource,1);
for i=1:numel(deagg2)
    if ~isempty(deagg2{i})
        lambda2(i)=sum(deagg2{i}(:,3));
    end
end
lambda2 = permute(lambda2,[2,1,3,4]);
lambda2 = nansum(lambda2,4);
[handles,MRscen] = run_func(handles,model,lambda2,deagg2);

M     = MRscen(1);
rrup  = MRscen(2);
ptr1  = MRscen(4);
ptr2  = MRscen(5);

handles.control_R.String = sprintf('%4.3g',rrup);
handles.control_M.String = sprintf('%4.3g',M);

% compute UHS
uhs  = uhspectrum(handles.opt.im,lambda1,1/Tr);

% compute GMPE prediction
source             = model.source(ptr1);
gmpefun            = source.gmpe.handle;
Rmetric            = source.gmpe.Rmetric;
source.mscl.M      = M;
source.mscl.dPm    = 1;
source.geom.conn   = source.geom.conn(ptr2,:);
source.geom.aream  = source.geom.aream(ptr2,:);   
source.geom.hypm   = source.geom.hypm(ptr2,:);   
source.geom.normal = source.geom.normal(ptr2,:);
source = mGMPEVs30(source,Vs30);
switch source.type
    case 'point',  param = mGMPEassemblePoint(r0,source,Rmetric,ellipsoid);
    case 'line',   param = mGMPEassembleLine(r0,source,Rmetric,ellipsoid);
    case 'area'
        switch source.mechanism
            case {'interface','intraslab','grid'}
                param = mGMPEassembleArea(r0,source,Rmetric,ellipsoid);
            case 'crustal'
%                 param = mGMPEassembleCrustal(r0,source,rateM,Rmetric,ellipsoid);
        end
end
mu  = zeros(size(uhs));
sig = zeros(size(uhs));
for j=1:length(T)
    [mu(j),sig(j)] = gmpefun(T(j),param{:});
end
gmpe    = exp(mu);

% Step 4: compute e*
eTs = (log(uhs(Tcond_ptr))-mu(Tcond_ptr))/sig(Tcond_ptr);

% Step 5: compute ebar
rho     = zeros(size(T));
methods = pshatoolbox_methods(4,handles.spatial_model.Value);
func    = methods.func;

Cond_param.opp       = 0;
Cond_param.mechanism = model.source(ptr1).mechanism;
Cond_param.R         = rrup;
Cond_param.M         = M;
Cond_param.residual  = 'phi';
Cond_param.direction = 'horizontal';
for i=1:length(rho)
    rho(i)  = func(Tcond,T(i),Cond_param);
end

% Step 6: compute cms
sigCMS = sig.*sqrt(1-rho.^2); 
epsCMS = 1.0; % can be changed to something else;

lncms   = mu+eTs*rho.*sig;      
lncmss1 = lncms+epsCMS*sigCMS; 
lncmss2 = lncms-epsCMS*sigCMS; 

cms     = exp(lncms);
cmss1   = exp(lncmss1);
cmss2   = exp(lncmss2);

%[T,cms,cmss1,cmss2];

% graphics
ch=findall(handles.ax1,'tag','haz');  ch.XData = im1(:,Tcond_ptr);       ch.YData = lambda1(:,Tcond_ptr);
ch=findall(handles.ax2,'tag','uhs');  ch.XData = T(:);      ch.YData = uhs;
ch=findall(handles.ax2,'tag','gmpe'); ch.XData = T;         ch.YData = gmpe;
ch=findall(handles.ax4,'tag','rho');  ch.XData = T;         ch.YData = rho;
ch=findall(handles.ax2,'tag','cms');  ch.XData = T;         ch.YData = cms;
ch=findall(handles.ax2,'tag','cmss'); ch.XData = [T;nan;T]; ch.YData = [cmss1;nan;cmss2];
L=legend(handles.ax2,'UHS','GMPE','CMS (\mu)','CMS(\mu\pm\sigma)');L.Box='off';

% uicontext
cF=get(0,'format');
format long g
num = [im1(:,Tcond_ptr),lambda1(:,Tcond_ptr)];
data = num2cell([zeros(1,2);num]);
data(1,:)={sprintf('Sa(T*=%g)',Tcond),'lambda Sa'};
c = uicontextmenu;
uimenu(c,'Label','Copy data','Callback',{@data2clipboard_uimenu,data});
uimenu(c,'Label','Undock','Callback'   ,{@figure2clipboard_uimenu,handles.ax1});
set(handles.ax1,'uicontextmenu',c);

num = [T,uhs,gmpe,cms,cmss1,cmss2];
data = num2cell([zeros(1,6);num]);
data(1,:) = {'T(s)','UHS','GMPE','CMS','CMS+SIG','CMS-SIG'};
c = uicontextmenu;
uimenu(c,'Label','Copy data','Callback',{@data2clipboard_uimenu,data});
uimenu(c,'Label','Undock','Callback'   ,{@figure2clipboard_uimenu,handles.ax2});
set(handles.ax2,'uicontextmenu',c);

c = uicontextmenu;
uimenu(c,'Label','Undock','Callback'   ,{@figure2clipboard_uimenu,handles.ax3});
set(handles.ax3,'uicontextmenu',c);

num = [T,rho];
data = num2cell([zeros(1,2);num]);
data(1,:)={'T(s)',sprintf('rho(T,T*)')};
c = uicontextmenu;
uimenu(c,'Label','Copy data','Callback',{@data2clipboard_uimenu,data});
uimenu(c,'Label','Undock','Callback'   ,{@figure2clipboard_uimenu,handles.ax4});
set(handles.ax4,'uicontextmenu',c);

format(cF);

function [handles,MRscen]=run_func(handles,model,lambda2,deagg2)

deagg{1}    = vertcat(deagg2{1,1,1,:});
indsource   = zeros(0,2);
Nsources    = size(deagg2,4);
for i=1:Nsources
    dg         = deagg2{1,1,1,i};
    if ~isempty(dg)
        Nscen      = size(dg,1);
        NM = length(model.source(i).mscl.M);
        NR = size(model.source(i).geom.conn,1);
        ptr2       = sort(repmat((1:NR)',NM,1));
        indsource  = [indsource;[i*ones(Nscen,1),ptr2]];  %#ok<*AGROW>
    end
end

if isempty(deagg)
    return
end

% build deaggregation chart 'dchart'
rmin      = handles.Rbin(1);
rmax      = handles.Rbin(end);
Rcenter   = mean(handles.Rbin,2);
Mcenter   = mean(handles.Mbin,2);
handles.dchart = deagghazard(deagg,lambda2,Mcenter,Rcenter);

Mbar = sum(deagg{1}(:,1).*deagg{1}(:,3))/sum(deagg{1}(:,3));
Rbar = sum(deagg{1}(:,2).*deagg{1}(:,3))/sum(deagg{1}(:,3));
ind1 = and(handles.Mbin(:,1)<Mbar,handles.Mbin(:,2)>Mbar);
ind2 = and(handles.Rbin(:,1)<Rbar,handles.Rbin(:,2)>Rbar);

MBIN = handles.Mbin(ind1,:);
RBIN = handles.Rbin(ind2,:);
ind  = (deagg{1}(:,1)>=MBIN(1)).*(deagg{1}(:,1)<=MBIN(2)).*(deagg{1}(:,2)>=RBIN(1)).*(deagg{1}(:,2)<=RBIN(2))==1;

DG     = [deagg{1}(ind,:),indsource(ind,:)];
mean1  = mean(DG(:,1:2),1);
std1   = std(DG(:,1:2),0,1);
disc1  = bsxfun(@times,bsxfun(@minus,DG(:,1:2)  ,mean1),1./std1);
disc2  = bsxfun(@times,bsxfun(@minus,[Mbar,Rbar],mean1),1./std1);
DISC   = sum(bsxfun(@minus,disc1,disc2).^2,2);
[~,indmin] = min(DISC);
MRscen = DG(indmin,:);

handles.b=bar3(handles.ax3,Rcenter,handles.dchart(:,:,1));
set(handles.ax3,...
    'xtick',1:2:length(Mcenter),...
    'xticklabel',Mcenter(1:2:end),...
    'ytick',Rcenter(1:2:end),...
    'projection','perspective',...
    'fontsize',8,...
    'ylim',[rmin,rmax],'visible','on')
xlabel(handles.ax3,'Magnitude','fontsize',8);
ylabel(handles.ax3,'R (km)','fontsize',8);
zlabel(handles.ax3,'Hazzard Deagg','fontsize',8)

