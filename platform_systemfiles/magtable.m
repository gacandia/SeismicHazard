% function[mpdf,mcdf,Mo]=magtable(M,param)
% 
% lambdaM = param.lambdaM;
% 
% 
% function[u]=timeDer22(time,u,n)
% 
% time=time(:)';
% u=u(:)';
% 
% Np = length(time);
% h  = mean(diff(time));
% e = ones(Np,1)/2;
% A = spdiags([-e,e*0,e],[-1 0 1],Np,Np);
% A(1,1:2)=[-1,1];
% A(Np,Np-1:Np)=[-1,1];
% 
% for jj=1:n
%     u   = (A*u')'/h;
% end
% 
% u=u'; % reported as column vector
% 
% % trick to differentiate accelarations 
% meanv = mean(abs(u));
% ind = abs(u)/meanv>40;
% u(ind)=nan;
