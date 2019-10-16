function[offset_i]=get_offset(model)

nxyz  = 1;
nconn = [];
npts  = 1;
for j=1:length(model.source)
    nxyz = [nxyz;size(model.source(j).geom.xyzm,1)]; %#ok<AGROW>
    nconn = [nconn;size(model.source(j).geom.conn,1)]; %#ok<AGROW>
    npts  = max(npts,size(model.source(j).geom.conn,2));
end
nxyzcum = cumsum(nxyz);
offset_i = zeros(0,npts);

for j=1:length(model.source)
    ind = nxyzcum(j)-1;
    offset_i=[offset_i;ind*ones(nconn(j),npts)]; %#ok<AGROW>
end

