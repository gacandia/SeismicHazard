function [pdef] = reduceGG(p,R)
tol = 1e-10;

if norm(p(1,:)-p(end,:))<tol
    p(end,:)=[];
end
pplus  = p([2:end,1],:);
pminus = p([end,1:end-1],:);
Nsides = size(p,1);
pdef = zeros(Nsides,2);

for i=1:Nsides
    v1 = pminus(i,:)-p(i,:); v1 = v1/norm(v1);
    v2 = pplus (i,:)-p(i,:); v2 = v2/norm(v2);
    n  = 1/2*(v1+v2);        n  = n/norm(n);
    alfa = acosd(v1*v2');
    X    = R/sind(alfa/2);
    pdef(i,:) = p(i,:)+X*n;
    
    INSIDE = inpolygon(pdef(i,1),pdef(i,2),p(:,1),p(:,2));
    if INSIDE==0
        pdef(i,:) = p(i,:)-R*n;
    end
end
Nsides= size(pdef,1);
if Nsides>5
    d = zeros(Nsides,1);
    for i=1:Nsides
        d(i) = -p_poly_dist(pdef(i,1), pdef(i,2), p(:,1), p(:,2));
    end
    IND = d<0.5*R;
    pdef(IND,:)=[];
    P1 = pdef;
    P2 = pdef([2:end,1],:);
    DIST = sum((P1-P2).^2,2).^0.5;
    disc = DIST<0.8*R;
    pdef(disc,:)=[];
end

