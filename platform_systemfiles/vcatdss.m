function conn=vcatdss(source)
Ns = length(source);
nr = zeros(Ns,1);
nc = zeros(Ns,1);
for i=1:Ns
    [nr(i),nc(i)]=size(source(i).geom.conn);
end
maxnc = max(nc);
conn  = zeros(0,maxnc);
for i=1:Ns
    conn_i=nan(size(source(i).geom.conn,1),maxnc);
    conn_i(:,1:nc(i)) = source(i).geom.conn;
    conn = [conn;conn_i]; %#ok<AGROW>
end

