function[rate,Y]=dsha_is(handles)

IM         = [handles.opt.IM1;handles.opt.IM2(:)];
NIM        = length(IM);
Nscenarios = length(handles.shakefield);
Nsim       = str2double(handles.NumSim.String);
Nsites     = size(handles.h.p,1);
shakefield = handles.shakefield;
rateMR     = prod(cell2mat(handles.scenarios(:,10:12)),2);

% writes scenario simulations
Y    = zeros(Nsim*Nscenarios,Nsites*NIM);
rate = zeros(Nsim*Nscenarios,1);
for i=1:NIM
    IND     = (1:Nsites)+Nsites*(i-1);
    fprintf('Computing shakefield: %g\n',i)
    for j = 1:Nscenarios
        mulogIM  = shakefield(j).mulogIM(IND);
        L        = handles.L(IND,:,shakefield(j).Lptr);
        Zij      = normrnd(0,1,[Nsites*NIM,Nsim]);
        ptr      = (1:Nsim)+Nsim*(j-1);
        Y(ptr,IND) = exp(bsxfun(@plus,mulogIM,L*Zij))';
        if i==1
            rate(ptr)=1/Nsim*rateMR(j);
        end
    end
end
