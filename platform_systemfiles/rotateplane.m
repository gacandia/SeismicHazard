function [p,mp,V,vertices] = rotateplane(vertices,ellipsoid,W,L)

if nargin==2
    pv      = gps2xyz(vertices,ellipsoid);
    mp      = mean(pv);
    pv_mov  = bsxfun(@minus,pv,mp);
    covar   = pv_mov'*pv_mov;
    [~,~,V] = svd(covar);
    pv_rot  = pv_mov*V;
    p       = pv_rot;
    if size(p,1)==4
        sigp    = sign(p(:,1:2));
        [~,~,C] = intersect([-1 -1;1 -1;1 1;-1 1],sigp,'rows','stable');
        p       = p(C,:);
    end
    
else
    pv      = gps2xyz(vertices,ellipsoid);
    mp      = mean(pv);
    pv_mov  = bsxfun(@minus,pv,mp);
    covar   = pv_mov'*pv_mov;
    [~,~,V] = svd(covar);
    pv_rot  = pv_mov*V;
    p       = pv_rot;
    if size(p,1)==4
        sigp    = sign(p(:,1:2));
        [~,~,C] = intersect([-1 -1;1 -1;1 1;-1 1],sigp,'rows','stable');
%         p       = p(C,:);
    end
    p        = [-L/2 -W/2 0;L/2 -W/2 0;L/2 W/2 0;-L/2 W/2 0];
    vertices = xyz2gps(bsxfun(@plus,p(C,:)*V',mp),ellipsoid);
    
end



