function [x,c]=gaussquad(n,ab)
%GAUSSQUAD  Gaussian quadrature

P=zeros(n+1,n+1);
P([1,2],1)=1;
for k=1:n-1
  P(k+2,1:k+2)=((2*k+1)*[P(k+1,1:k+1) 0]-k*[0 0 P(k,1:k)])/(k+1);
end
x=sort(roots(P(n+1,1:n+1)));

A=zeros(n,n);
for i=1:n
  A(i,:)=polyval(P(i,1:i),x)';
end
c=A\[2;zeros(n-1,1)];

% Scaling gauss points to fit interval [a,b]
a=ab(1);
b=ab(2);
x = a+(x+1)*(b-a)/2;
c = c*(b-a)/2;