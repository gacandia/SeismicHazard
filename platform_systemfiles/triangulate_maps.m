function[p,t]=triangulate_maps(pv,pvadd)

ptol = 0.000001;
pv(isnan(pv(:,1)),:)=[];
if any(pv(1,:)~=pv(end,:))
    pv(end+1,:)=pv(1,:);
end

p = [pv(1:end-1,:);pvadd];
p = unique(p,'rows');
t = delaunay(p);
[p,t]=fixmesh(p,t,ptol);
t=removeoutsidetris(p,t,pv);


function t=removeoutsidetris(p,t,pv)

pmid=(p(t(:,1),:)+p(t(:,2),:)+p(t(:,3),:))/3;
isinside=inpolygon(pmid(:,1),pmid(:,2),pv(:,1),pv(:,2));
t=t(isinside,:);

