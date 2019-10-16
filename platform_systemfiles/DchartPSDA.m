function[dchart]=DchartPSDA(deaggD,Mbin,Rbin)

Mcenter = mean(Mbin,2); NM  = length(Mcenter); dm = Mcenter(2)-Mcenter(1);
Rcenter = mean(Rbin,2); NR  = length(Rcenter); dr = Rcenter(2)-Rcenter(1);
dm      = round(dm*100)/100;
[Mcenter,Rcenter]=meshgrid(Mcenter,Rcenter);

M  = deaggD(:,1);
R  = deaggD(:,2);
dg = deaggD(:,3);
lambdaD = sum(dg);
dchart = zeros(NR,NM);
for i=1:NR
    if i<NR
        for j=1:NM
            ind1 = and(Rcenter(i,j)-dr/2<R,R<=Rcenter(i,j)+dr/2);
            ind2 = and(Mcenter(i,j)-dm/2<M,M<=Mcenter(i,j)+dm/2);
            dchart(i,j) = sum(dg(ind1&ind2))/lambdaD*100;
        end
    else
        for j=1:NM
            ind1 = (Rcenter(i,j)-dr/2<=R);
            ind2 = and(Mcenter(i,j)-dm/2<M,M<=Mcenter(i,j)+dm/2);
            dchart(i,j) = sum(dg(ind1&ind2))/lambdaD*100;
        end
    end
end
dchart = dchart*100/sum(dchart(:));



