clearvars
clc
NMmin  = 2;
M      = 6.7;
Rad    = 10;
Area   = pi*Rad^2;
r0     = linspace(0,Rad,30);
rint   = r0(1:end-1);
rext   = r0(2:end);
rmid   = 1/2*(rint+rext);
theta0  = linspace(0,2*pi,360);
theta  = (theta0(1:end-1)+theta0(2:end))/2;
x      = rmid'*cos(theta);
y      = rmid'*sin(theta);
rate   = 1/2*(rext.^2-rint.^2)'*diff(theta0)/Area;
RA     = 10^(1*M-4);
r      = sqrt((x(:)-30).^2+y(:).^2)-sqrt(RA/pi);
mu     = -1.274+1.1*M-2.1*log(r+exp(-0.48451+0.5240*M));
sigma  = 1.39-0.14*M;
z      = logsp(0.01,3,20);
lambda = zeros(size(z));
for i=1:length(z)
    P  = (1-normcdf((log(z(i)) - mu)/sigma));
    lambda(i) = NMmin*rate(:)'*P;
end

loglog(z,lambda)
th=(0:5:355)';
MAT=[Rad*cosd(th),Rad*sind(th),th*0]';
MAT = MAT(:);
fprintf('%g ',MAT);
fprintf('\n');
fprintf('%g ',z);
fprintf('\n');
fprintf('%g ',lambda);