function[v]=compute_v(handles)

MapOptions = handles.HazOptions;
IM_ptr     = handles.IM_select.Value;

switch handles.opt.LiteMode
    case 'on'
        lambdaREG = handles.MRE(:,:,IM_ptr);
        lambdaPCE = handles.MREPCE(:,:,IM_ptr);
        lambda    = lambdaREG.*lambdaPCE;
        LiteMode = 1;
    case 'off'
        lambda   = nansum(handles.MRE(:,:,IM_ptr,:,:),4);
        lambda   = permute(lambda,[5,1,2,3,4]);
        LiteMode = 0;
end

switch MapOptions.mod
    case 1 %weithed average of hazard
     
        if MapOptions.avg(1)==1 && LiteMode==0% default weights
            weights = handles.sys.WEIGHT(:,4);
            lambda  = prod(bsxfun(@power,lambda,weights),1);
        end
        
        if MapOptions.avg(2)==1
            weights  = MapOptions.rnd;
            lambda  = prod(bsxfun(@power,lambda,weights),1);
        end
        
        if MapOptions.avg(3)==1
            Per      = MapOptions.avg(4);
            lambda   = nansum(handles.MRE(:,:,IM_ptr,:,:),4);
            lambda   = permute(lambda,[5,1,2,3,4]);
            lambda   = prctile(lambda,Per,1);
        end
        
    case 2 %single branch
        ptr      = MapOptions.sbh(1);
        lambda   = nansum(handles.MRE(:,:,IM_ptr,:,:),4);
        lambda   = permute(lambda,[5,1,2,3,4]);
        lambda   = lambda(ptr,:,:);
end

if LiteMode==0
    lambda   = permute(lambda,[2,3,1]);
end
im       = handles.opt.im;

pall={'parula','autumn','bone','colorcube','cool','copper','flag','gray','hot','hsv','jet','lines','pink','prism','spring','summer','white','winter'};
pallet = pall{MapOptions.map(2)};
set(handles.FIGSeismicHazard,'colormap',feval(pallet));
hazard   = 1/MapOptions.map(1);
logh     = log(hazard);
logHIM   = log(lambda);

%handles.SaText = 
text(NaN,NaN,'','parent',handles.ax1,'Tag','satext');

% interpolation oh hazard curves
Nsites = size(handles.h.p,1);
v   = zeros(Nsites,1);
for j=1:Nsites
    xxx =logHIM(j,:);
    im0  = im(~isinf(xxx));
    x0  = xxx(~isinf(xxx))';
    if any([min(xxx)<logh,max(xxx)>logh,length(unique(xxx))>2]==0)
        v(j)  = 0;
    else
        %v(j)  = interp1(x0,im0,logh,'linear');
        v(j)  = robustinterp(x0,im0,logh,'linear');
    end
end

