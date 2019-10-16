function[Mmax]=getMMax(source,m,X,Y)

geom = source.geom;
vertices = geom.p(:,1:2);
rupt = source.rupt;
switch rupt.type
    case 'circular'
        r = p_poly_dist(X, Y, vertices(:,1), vertices(:,2));
        r = abs(r);
        Amax  = pi*r^2;
        model = rupt.RA{1};
        param = rupt.RA{2};
        Mr    = magRelation(Amax,0,model,param);
    case 'rectangular'
        rx = abs(p_poly_dist(X, Y, vertices(:,1), 1e10*vertices(:,2)));
        ry = abs(p_poly_dist(X, Y, 1e10*vertices(:,1), vertices(:,2)));
        aratio = rupt.aratio;
        if rx<=ry
            L     = 2*rx;
            W     = L/aratio;
        elseif rx>ry
            W     = 2*ry;
            L     = W*aratio;

        end
        Amax  = W*L;
        model = rupt.RA{1};
        param = rupt.RA{2};
        Mr    = magRelation(Amax,0,model,param);
    case 'adaptive'
        
end

mtol = 0.005;
if m<=Mr+mtol
    Mmax = m;
else
    Mmax  = Mr;
end
