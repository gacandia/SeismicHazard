function p=nanprod(x,dim)

x(isnan(x))=1;
p = prod(x,dim);