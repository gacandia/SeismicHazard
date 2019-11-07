function[kydata]=runPSDA_singlebranch(handles,Tr,Da,branch_ptr)

%% A little housekeeping
site_ptr  = handles.pop_site.Value;
IJK       = handles.IJK;
indT1     = IJK(branch_ptr,1); % pointer to scenario and Tm value
indT2     = IJK(branch_ptr,2); % pointer to Ky and Ts values
indT3     = IJK(branch_ptr,3); % pointer to analyses models
SMLIB     = handles.sys.SMLIB;
id        = {handles.sys.SMLIB.id};
optimizeD = handles.paramPSDA.optimize;
d         = Da;
Ts        = handles.T2{indT2,2};
KY        = handles.T2{indT2,3};
KMIN      = 0.001;
KMAX      = 1;
B         = zeros(4,1);
[~,B(1)]  = intersect(id,handles.T3{indT3,2}); fun1 = SMLIB(B(1)).func; % interface
[~,B(2)]  = intersect(id,handles.T3{indT3,3}); fun2 = SMLIB(B(2)).func; % slab
[~,B(3)]  = intersect(id,handles.T3{indT3,4}); fun3 = SMLIB(B(3)).func; % crustal
[~,B(4)]  = intersect(id,handles.T3{indT3,5}); fun4 = SMLIB(B(4)).func; % grid, others
Nsources  = getNsource(handles.model);
model     = handles.model(indT1);
%% run k-iterations
go = 1;
iter=0;

while go
    iter = iter+1;
    ky = KY(end);
    lambdaD   = zeros(1,Nsources);
    for source_ptr=1:Nsources
        mechanism = model.source(source_ptr).mechanism;
        
        switch mechanism
            case 'interface' , fun = fun1; Bs=B(1);
            case 'intraslab' , fun = fun2; Bs=B(2);
            case 'crustal'   , fun = fun3; Bs=B(3);
            case 'grid'      , fun = fun4; Bs=B(4);
        end
        
        param      = SMLIB(Bs).param;
        integrator = SMLIB(Bs).integrator;
        Safactor   = SMLIB(Bs).Safactor;
        IMslope    = Safactor*Ts.*(Safactor>=0)+Safactor.*(Safactor<0);
        
        if integrator==1 % magnitude dependent models
            [~,IM_ptr] = intersect(handles.haz.IMstandard,IMslope);
            im         = handles.haz.imstandard(:,IM_ptr);
            deagg      = handles.haz.deagg(site_ptr,:,IM_ptr,source_ptr,indT1);
            deagg      = permute(deagg ,[2,1]);
            if ~isempty(deagg{1})
                hd  = integrate_Mw_dependent(fun,d,ky,Ts,im,deagg,optimizeD);
            else
                continue
            end
        end
        
        if integrator==2 % magnitude independent models
            [~,IM_ptr] = intersect(handles.haz.IMstandard,IMslope);
            im         = handles.haz.imstandard(:,IM_ptr);
            lambda     = handles.haz.lambda(site_ptr,:,IM_ptr,source_ptr,indT1);
            lambda  = permute(lambda,[2,1]);
            if max(lambda)>0
                hd      = integrate_Mw_independent(fun,d,ky,Ts,im,lambda);
            else
                continue
            end
        end
        
        if integrator==3 % Ellen큦 rigid slope
            [~,rho_ptr]= intersect(handles.haz.corrlist,param.rho);
            im         = handles.haz.imvector;
            MRD        = handles.haz.MRD(site_ptr,:,:,source_ptr,indT1,rho_ptr);
            MRD        = permute(MRD,[2 3 1]);
            if max(MRD(:))>0
                hd         = fun(ky,[],im(:,1),im(:,2),d,'convolute',MRD);
            else
                continue
            end
        end
        
        if integrator==4 % Ellen큦 flexible slope
            [~,rho_ptr]= intersect(handles.haz.corrlist,param.rho);
            im         = handles.haz.imvector;
            MRD        = handles.haz.MRD(site_ptr,:,:,source_ptr,indT1,rho_ptr);
            MRD        = permute(MRD,[2 3 1]);
            [Tm,~,dP]  = trlognpdf_psda([param.Tm_mean,param.Tm_cov,param.Tm_Nsta]);
            if max(MRD(:))>0
                hd            = zeros(size(d));
                for ix = 1:length(Tm)
                    [im2,MRDkvkm]  = computeMRDkmkv(Ts, Tm(ix), im, MRD,param.rhok);
                    dhd            = fun(ky,Ts,im2(:,1),im2(:,2),d,'convolute',MRDkvkm);
                    hd             = hd+dP(ix)*dhd;
                end
            else
                continue
            end
        end
        
        lambdaD(:,source_ptr) = hd(:);
    end
    
    
    lambdaDa  = permute(nansum(lambdaD,2),[2,1]);
    ERROR    = lambdaDa-1/Tr;
    
    if iter==1
        if ERROR<0
            KMAX  = KY;
            KY    = sqrt(KY*KMIN);
        else
            KMIN = KY;
            KY   = sqrt(KY*KMAX);
        end
        OLDERROR=ERROR;
    else
        aa = abs(OLDERROR); bb = abs(ERROR);
        a  = aa/(aa+bb);    b  = bb/(aa+bb);
        if ERROR<0
            KMAX = KY;
            KY   = KY^a*KMIN^b;
        else
            KMIN = KY;
            KY   = KY^a*KMAX^b;
        end
        OLDERROR = ERROR;
    end
    
    if abs(1/lambdaDa-Tr)<1e-3
        go=0;
    end
end

%% reconstruction of the D hazard curve

d       = unique([handles.paramPSDA.d,Da]);
indDa   = find(d==Da);
indDa   = indDa(1);
Nd      = length(d);
lambdaD = zeros(Nd,Nsources);
for source_ptr=1:Nsources
        mechanism = model.source(source_ptr).mechanism;
        
        switch mechanism
            case 'interface' , fun = fun1; Bs=B(1);
            case 'intraslab' , fun = fun2; Bs=B(2);
            case 'crustal'   , fun = fun3; Bs=B(3);
            case 'grid'      , fun = fun4; Bs=B(4);
        end
        
        param      = SMLIB(Bs).param;
        integrator = SMLIB(Bs).integrator;
        Safactor   = SMLIB(Bs).Safactor;
        IMslope    = Safactor*Ts.*(Safactor>=0)+Safactor.*(Safactor<0);
        
        if integrator==1 % magnitude dependent models
            [~,IM_ptr] = intersect(handles.haz.IMstandard,IMslope);
            im         = handles.haz.imstandard(:,IM_ptr);
            deagg      = handles.haz.deagg(site_ptr,:,IM_ptr,source_ptr,indT1);
            deagg      = permute(deagg ,[2,1]);
            if ~isempty(deagg{1})
                hd         = integrate_Mw_dependent(fun,d,ky,Ts,im,deagg,optimizeD);
            else
                continue
            end
        end
        
        if integrator==2 % magnitude independent models
            [~,IM_ptr] = intersect(handles.haz.IMstandard,IMslope);
            im         = handles.haz.imstandard(:,IM_ptr);
            lambda     = handles.haz.lambda(site_ptr,:,IM_ptr,source_ptr,indT1);
            lambda  = permute(lambda,[2,1]);
            if max(lambda)>0
                hd      = integrate_Mw_independent(fun,d,ky,Ts,im,lambda);
            else
                continue
            end
        end
        
        if integrator==3 % Ellen큦 rigid slope
            [~,rho_ptr]= intersect(handles.haz.corrlist,param.rho);
            im         = handles.haz.imvector;
            MRD        = handles.haz.MRD(site_ptr,:,:,source_ptr,indT1,rho_ptr);
            MRD        = permute(MRD,[2 3 1]);
            if max(MRD(:))>0
                hd         = fun(ky,[],im(:,1),im(:,2),d,'convolute',MRD);
            else
                continue
            end
        end
        
        if integrator==4 % Ellen큦 flexible slope
            [~,rho_ptr]= intersect(handles.haz.corrlist,param.rho);
            im         = handles.haz.imvector;
            MRD        = handles.haz.MRD(site_ptr,:,:,source_ptr,indT1,rho_ptr);
            MRD        = permute(MRD,[2 3 1]);
            [Tm,~,dP]     = trlognpdf_psda([param.Tm_mean,param.Tm_cov,param.Tm_Nsta]);
            if max(MRD(:))>0
                hd            = zeros(size(d));
                for ix = 1:length(Tm)
                    [im2,MRDkvkm]  = computeMRDkmkv(Ts, Tm(ix), im, MRD,param.rhok);
                    dhd            = fun(ky,Ts,im2(:,1),im2(:,2),d,'convolute',MRDkvkm);
                    hd             = hd+dP(ix)*dhd;
                end
            else
                continue
            end
        end
        
        lambdaD(:,source_ptr) = hd(:);
end
    
lambdaD  = permute(nansum(lambdaD,2),[2,1]);

%%
scale          = 1/(Tr*lambdaD(indDa));
kydata.d       = d;
kydata.lambdaD = lambdaD*scale;
kydata.ky      = ky;
kydata.error   = ERROR;
kydata.iter    = iter;

