function[x,pdf,dP]=trlognpdf_psda(param)

x     = param(1);
covx  = param(2);
Nsta  = param(3);

sig =(log(1+(covx)^2))^0.5;
mu  =log(x)-0.5*sig^2;

if all(param(2:3)>0)
   
   % truncated lognormal pdf
   param = logninv([0.0005 0.9995],mu,sig);
   
   % log normal pdf
   xo = logsp(param(1),param(2),Nsta+1)';
   x  = 1/2*(xo(1:end-1)+xo(2:end));
   pdf  = lognpdf(x,mu,sig);
   
   area = logncdf(xo(end),mu,sig)-logncdf(xo(1),mu,sig);
   dP   = logncdf(xo(2:end),mu,sig)-logncdf(xo(1:end-1),mu,sig);
   
   % area correction
   pdf = pdf / area;
   dP  = dP/area;
   
else
   x   = param(1);
   pdf = 1;
   dP  = 1;
end

% if all(param(2:3)>0)                                             
%                                                                  
%     % truncated lognormal pdf                                    
%     %mu    = log(param(1));                                      
%     mu    = param(1);                                            
%     sig   = param(2);                                            
%     Nsta  = param(3);                                            
%     param = logninv([0.0005 0.9995],mu,sig);                     
%                                                                  
%     % log normal pdf                                             
%     xo = logsp(param(1),param(2),Nsta+1)';                       
%     x  = 1/2*(xo(1:end-1)+xo(2:end));                            
%     pdf  = lognpdf(x,mu,sig);                                    
%                                                                  
%     area = logncdf(xo(end),mu,sig)-logncdf(xo(1),mu,sig);        
%     dP   = logncdf(xo(2:end),mu,sig)-logncdf(xo(1:end-1),mu,sig);
%                                                                  
%     % area correction                                            
%     pdf = pdf / area;                                            
%     dP  = dP/area;                                               
%                                                                  
% else                                                             
%     x   = param(1);                                              
%     pdf = 1;                                                     
%     dP  = 1;                                                     
% end                                                              
                                                                 