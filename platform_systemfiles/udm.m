function[lny,sigma,tau,sig]=udm(To,varargin)

gmpe             = varargin{1};
isvectorized     = varargin{2};
% un               = varargin{3};
% residuals        = varargin{4};
if isvectorized
    [lny,sigma,tau,sig] = gmpe(To,varargin{5:end});
else
    var  = varargin(5:end);
    nvar = length(var);
    svar = zeros(1,nvar);
    for i=1:nvar
        svar(i)=size(var{i},1);
    end
    N   = max(svar);
    ind = find(svar==N); 
    [lny,sigma,tau,sig] = deal(nan(N,1));
    kvar = var;
    for k=1:N
        for kk=1:length(ind)
            ii = ind(kk);
            kvar{ii}=var{ii}(k);
        end
        [lny(k),sigma(k),tau(k),sig(k)] = gmpe(To,kvar{:});
    end
end