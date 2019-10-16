function [d,x_poly,y_poly] = p_turbo_dist(x, y, xv0, yv0)

%close it.
xv = [xv0 ; xv0(1)];
yv = [yv0 ; yv0(1)];

xv1 = xv(1:end-1);
xv2 = xv(2:end);
yv1 = yv(1:end-1);
yv2 = yv(2:end);

% linear parameters of segments that connect the vertices
% Ax + By + C = 0
A = yv1-yv2;
B = xv2-xv1;
C = yv2.*xv1 - xv2.*yv1;

% find the projection of point (x,y) on each rib
AB = 1./(A.^2 + B.^2);
vv = (A*x+B*y+C);
xp = x - (A.*AB).*vv;
yp = y - (B.*AB).*vv;

% Test for the case where a polygon rib is
% either horizontal or vertical. From Eric Schmitz
id = xv1==xv2;
xp(id)=xv(id);

id = yv1==yv2;
yp(id)=yv(id);

% find all cases where projected point is inside the segment
idx_x = (((xp>=xv1) & (xp<=xv2)) | ((xp>=xv2) & (xp<=xv1)));
idx_y = (((yp>=yv1) & (yp<=yv2)) | ((yp>=yv2) & (yp<=yv1)));
idx = idx_x & idx_y;

% distance from point (x,y) to the vertices
dv = sqrt((xv1-x).^2 + (yv1-y).^2);

if(~any(idx)) % all projections are outside of polygon ribs
    [d,I] = min(dv);
    x_poly = xv(I);
    y_poly = yv(I);
else
    % distance from point (x,y) to the projection on ribs
    dp = sqrt((xp(idx)-x).^2 + (yp(idx)-y).^2);
    [min_dv,I1] = min(dv);
    [min_dp,I2] = min(dp);
    [d,I] = min([min_dv min_dp]);
    if I==1 %the closest point is one of the vertices
        x_poly = xv(I1);
        y_poly = yv(I1);
    elseif I==2 %the closest point is one of the projections
        idxs = find(idx);
        x_poly = xp(idxs(I2));
        y_poly = yp(idxs(I2));
    end
end

if d~=0 && inpoly(x,y,[xv yv])
    d = -d;
end


function [cn] = inpoly(x,y,node)

cn   = false;
for k = 1:4         % Loop through edges
    % Nodes in current edge
    n1 = k;
    n2 = k+1;
    y1 = node(n1,2);
    y2 = node(n2,2);
    if y1<y2
        x1 = node(n1,1);
        x2 = node(n2,1);
    else
        yt = y1;
        y1 = y2;
        y2 = yt;
        x1 = node(n2,1);
        x2 = node(n1,1);
    end
    
    if y>=y1 && y<=y2
        if x>=x1
            if x<=x2 && (y2-y1)*(x-x1)<(y-y1)*(x2-x1)
                cn = true;
            end
        elseif y<y2
            cn = ~cn;
        end
    end
end




