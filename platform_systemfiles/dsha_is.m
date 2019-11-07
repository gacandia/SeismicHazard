function[rate,Y]=dsha_is(handles)

IM         = [handles.opt.IM1;handles.opt.IM2(:)];
NIM        = length(IM);
Nscenarios = size(handles.pop_scenario.String,1);
Nsim       = str2double(handles.NumSim.String);
Nsites     = size(handles.h.p,1);
rateMR     = prod(handles.scenarios(:,6:8),2);

% writes scenario simulations
Y    = zeros(Nsim*Nscenarios,Nsites*NIM);
rate = zeros(Nsim*Nscenarios,1);
ptrs = handles.ptrs;
for i=1:NIM
    IND     = (1:Nsites)+Nsites*(i-1);
    fprintf('Computing shakefield: %g\n',i)
    for j = 1:Nscenarios
        mptr     = ptrs(j,1);
        scen_ptr = ptrs(j,2);
        mulogIM  = handles.shakefield(mptr).mulogIM(:,i,scen_ptr);
        L        = handles.L(IND,:,handles.shakefield(mptr).Lptr(scen_ptr));
        Zij      = normrnd(0,1,[Nsites*NIM,Nsim]);
        ptr      = (1:Nsim)+Nsim*(j-1);
        Y(ptr,IND) = exp(bsxfun(@plus,mulogIM,L*Zij))';
        if i==1
            rate(ptr)=1/Nsim*rateMR(j);
        end
    end
end
