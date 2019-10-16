function[deaggD]=DeaggPSDA_regular(handles)
delete(findall(handles.ax1,'type','line'));drawnow

d         = handles.d;
T1        = handles.T1;
T2        = handles.T2;
T3        = handles.T3;
[~,IJK]   = main_psda(T1,T2,T3);
SMLIB     = handles.sys.SMLIB;
Nsources  = getNsource(handles.model);
id        = {handles.sys.SMLIB.id};
site_ptr  = 1;
indT1     = IJK(1); % pointer to scenario and Tm value
indT2     = IJK(2); % pointer to Ky and Ts values
indT3     = IJK(3); % pointer to analyses models
Ts        = T2{indT2,2};
ky        = T2{indT2,3};
B         = zeros(4,1);
[~,B(1)]  = intersect(id,T3{indT3,2}); fun1 = SMLIB(B(1)).func; % interface
[~,B(2)]  = intersect(id,T3{indT3,3}); fun2 = SMLIB(B(2)).func; % slab
[~,B(3)]  = intersect(id,T3{indT3,4}); fun3 = SMLIB(B(3)).func; % crustal
[~,B(4)]  = intersect(id,T3{indT3,5}); fun4 = SMLIB(B(4)).func; % grid, others

deaggD = zeros(0,3);

% run sources
for source_ptr=1:Nsources
    mechanism = handles.model(indT1).source(source_ptr).mechanism;
    
    switch mechanism
        case 'interface' , fun = fun1; Bs=B(1);
        case 'intraslab' , fun = fun2; Bs=B(2);
        case {'crustal','shallowcrustal'}   , fun = fun3; Bs=B(3);
        case 'grid'      , fun = fun4; Bs=B(4);
    end
    
    % param      = SMLIB(Bs).param;
    integrator = SMLIB(Bs).integrator;
    Safactor   = SMLIB(Bs).Safactor;
    IMslope    = Safactor*Ts.*(Safactor>=0)+Safactor.*(Safactor<0);
    
    if integrator==1 % magnitude dependent models
        [~,IM_ptr] = intersect(handles.haz.IMstandard,IMslope);
        im         = handles.haz.imstandard(:,IM_ptr);
        deagg      = handles.haz.deagg(site_ptr,:,IM_ptr,source_ptr,indT1);
        deagg      = permute(deagg ,[2,1]);
        if ~isempty(deagg{1})
            rateD    = deagg_Mw_dependent(fun,d,ky,Ts,im,deagg);
            deaggD   = [deaggD;[deagg{1}(:,1:2),rateD]]; %#ok<AGROW>
        end
    end
    
    if integrator==2 % magnitude independent models
        [~,IM_ptr] = intersect(handles.haz.IMstandard,IMslope);
        im         = handles.haz.imstandard(:,IM_ptr);
        deagg      = handles.haz.deagg(site_ptr,:,IM_ptr,source_ptr,indT1);
        deagg      = permute(deagg,[2,1]);
        if ~isempty(deagg{1})
            rateD  = deagg_Mw_independent(fun,d,ky,Ts,im,deagg);
            deaggD = [deaggD;[deagg{1}(:,1:2),rateD]]; %#ok<AGROW>
        end
    end
end



