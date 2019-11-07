function[deaggIM]=deagghazard(deagg,lambda,Mcenter,Rcenter)

NR  = length(Rcenter);
NM  = length(Mcenter);
NB  = length(deagg);
deaggIM   = zeros(NR,NM,NB);
dr = Rcenter(2)-Rcenter(1);
dm = Mcenter(2)-Mcenter(1);
dm = round(dm*100)/100;
[Mcenter,Rcenter]=meshgrid(Mcenter,Rcenter);

for B=1:NB
    M  = deagg{B}(:,1);
    R  = deagg{B}(:,2);
    dg = deagg{B}(:,3);
    dIM = zeros(NR,NM);
    for i=1:NR
        if i<NR
            for j=1:NM
                ind1 = and(Rcenter(i,j)-dr/2<R,R<=Rcenter(i,j)+dr/2);
                ind2 = and(Mcenter(i,j)-dm/2<M,M<=Mcenter(i,j)+dm/2);
                dIM(i,j) = nansum(dg(ind1&ind2))/lambda(B)*100;
            end
        else
            for j=1:NM
                ind1 = (Rcenter(i,j)-dr/2<=R);
                ind2 = and(Mcenter(i,j)-dm/2<M,M<=Mcenter(i,j)+dm/2);
                dIM(i,j) = nansum(dg(ind1&ind2))/lambda(B)*100;
            end
        end
    end
    dIM = dIM*100/sum(dIM(:));
    deaggIM(:,:,B) = dIM;

end

