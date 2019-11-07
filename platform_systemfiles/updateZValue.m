function[]=updateZValue(b,deagg)

[NR,NE,NM] = size(deagg);
tol = 0.1;

for kkk=1:NM
    Zval = cumsum([zeros(NR,1),deagg(:,:,kkk)],2)';
    nulc = Zval(end,:)<tol;
    Zval(:,nulc)=NaN;
    for i=1:NR
        ind=(1:6)+6*(i-1);
        for j=1:NE
            Z1 = Zval(j,i);
            Z2 = Zval(j+1,i);
            b{kkk}(j).ZData(ind,:)=[
                NaN    Z1    Z1   NaN
                Z1    Z2    Z2    Z1
                Z1    Z2    Z2    Z1
                NaN    Z1    Z1   NaN
                NaN    Z1    Z1   NaN
                NaN   NaN   NaN   NaN];
        end
    end
end