function[handles]=runPSDA_regular(handles)
delete(findall(handles.ax1,'type','line'));
drawnow
d         = handles.paramPSDA.d;
Nd        = length(d);
T1        = handles.T1;
T2        = handles.T2;
T3        = handles.T3;
[~,IJK]   = main_psda(T1,T2,T3);
Nbranches = size(IJK,1);
SMLIB     = handles.sys.SMLIB;
h         = handles.h;
Nsites    = size(h.p,1);
Nsources  = getNsource(handles.model);
id        = {handles.sys.SMLIB.id};
optimizeD = handles.paramPSDA.optimize;
lambdaD   = nan(Nsites,Nd,Nsources,Nbranches);


fprintf('\n');
spat  = 'Site %-17g | Branch %-3g of %-49g Runtime:  %-4.3f s\n';
t0 = tic;
fprintf('                               SLOPE DISPLACEMENT HAZARD \n');
fprintf('-----------------------------------------------------------------------------------------------------------\n');

hd0 = zeros(size(d));
opt = handles.opt;

for site_ptr=1:Nsites
    xyz     = gps2xyz(handles.h.p(site_ptr,:),opt.ellipsoid);
    
    brptr =1:Nbranches;
    brptr((cell2mat(T1(:,2))==0))=[];
    for branch_ptr=brptr
        ti=tic;
        indT1    = IJK(branch_ptr,1); % pointer to scenario and Tm value
        indT2    = IJK(branch_ptr,2); % pointer to Ky and Ts values
        indT3    = IJK(branch_ptr,3); % pointer to analyses models
        
        Ts       = T2{indT2,2};
        ky       = T2{indT2,3};
        B        = zeros(4,1);
        
        [~,B(1)] = intersect(id,T3{indT3,2}); fun1 = SMLIB(B(1)).func; % interface
        [~,B(2)] = intersect(id,T3{indT3,3}); fun2 = SMLIB(B(2)).func; % slab
        [~,B(3)] = intersect(id,T3{indT3,4}); fun3 = SMLIB(B(3)).func; % crustal
        [~,B(4)] = intersect(id,T3{indT3,5}); fun4 = SMLIB(B(4)).func; % grid, others
        
        % run sources
        indlist = selectsource(opt.MaxDistance,xyz,handles.model(indT1).source,opt.ellipsoid);
        indlist = find(indlist);
        for source_ptr = indlist
            mechanism = handles.model(indT1).source(source_ptr).mechanism;
            
            switch mechanism
                case 'interface'      , fun = fun1; Bs=B(1);
                case 'intraslab'      , fun = fun2; Bs=B(2);
                case 'crustal'        , fun = fun3;
                    Bs=B(3);
                case 'shallowcrustal' , fun = fun3; Bs=B(3); % this (3) is not an error
                case 'grid'           , fun = fun4; Bs=B(4);
            end
            
            param      = SMLIB(Bs).param;
            integrator = SMLIB(Bs).integrator;
            Safactor   = SMLIB(Bs).Safactor;
            IMslope    = Safactor*Ts.*(Safactor>=0)+Safactor.*(Safactor<0);
            hd         = hd0;
            
            if integrator==1 % magnitude dependent models
                [~,IM_ptr] = intersect(handles.haz.IMstandard,IMslope);
                im         = handles.haz.imstandard(:,IM_ptr);
                deagg      = handles.haz.deagg(site_ptr,:,IM_ptr,source_ptr,indT1);
                deagg      = permute(deagg ,[2,1]);
                if ~isempty(deagg{1})
                    hd  = integrate_Mw_dependent(fun,d,ky,Ts,im,deagg,optimizeD);
                end
            end
            
            if integrator==2 % magnitude independent models
                [~,IM_ptr] = intersect(handles.haz.IMstandard,IMslope);
                im         = handles.haz.imstandard(:,IM_ptr);
                lambda     = handles.haz.lambda(site_ptr,:,IM_ptr,source_ptr,indT1);
                lambda     = permute(lambda,[2,1]);
                if max(lambda)>0
                    hd      = integrate_Mw_independent(fun,d,ky,Ts,im,lambda);
                end
            end
            
            if integrator==3 % Ellen´s rigid slope
                [~,rho_ptr]= intersect(handles.haz.corrlist,param.rho);
                im         = handles.haz.imvector;
                MRD        = handles.haz.MRD(site_ptr,:,:,source_ptr,indT1,rho_ptr);
                MRD        = permute(MRD,[2 3 1]);
                if max(MRD(:))>0
                    hd     = fun(ky,[],im(:,1),im(:,2),d,'convolute',MRD);
                end
                
            end
            
            if integrator==4 % Ellen´s flexible slope
                [~,rho_ptr]= intersect(handles.haz.corrlist,param.rho);
                im         = handles.haz.imvector;
                MRD        = handles.haz.MRD(site_ptr,:,:,source_ptr,indT1,rho_ptr);
                MRD        = permute(MRD,[2 3 1]);
                [Tm,~,dP]  = trlognpdf_psda([param.Tm_mean,param.Tm_cov,param.Tm_Nsta]);
                if max(MRD(:))>0
                    for ix = 1:length(Tm)
                        [im2,MRDkvkm]  = computeMRDkmkv(Ts, Tm(ix), im, MRD,param.rhok);
                        dhd            = fun(ky,Ts,im2(:,1),im2(:,2),d,'convolute',MRDkvkm);
                        hd             = hd+dP(ix)*dhd;
                    end
                end
            end
            lambdaD(site_ptr,:,source_ptr,branch_ptr) = hd;
        end
        fprintf(spat,site_ptr,branch_ptr,Nbranches,toc(ti))
    end
end
handles.lambdaD=lambdaD;
fprintf('-----------------------------------------------------------------------------------------------------------\n');
fprintf('%-88sTotal:     %-4.3f s\n','',toc(t0));
handles.butt2.Value=1;
