function [lnS,sigma] = B18_S(soil,build,cav)
                                            
bType      = build.bType;
numStories = build.numStories;
h          = bHeight(build.h,numStories);
Df         = build.Df;
B          = build.B;
L          = build.L;

Method =soil.Method;
switch soil.LPC
    case 'Yes', LPC =1;
    case 'No' , LPC =0;
end
N      =soil.N;
Hs     =soil.Hs;
Ds     =soil.Ds;

switch bType
    case 'Masonry',             Mst = 455*B*L*h; q = 455*h*9.81/1000; % Foundation bearing pressure, q (kPa)
    case 'Reinforced-Concrete', Mst = 455*B*L*h; q = 455*h*9.81/1000;
    case 'Timber',              Mst =  51*B*L*h; q =  51*h*9.81/1000;
    case 'Steel',               Mst = 242*B*L*h; q = 242*h*9.81/1000;
end

%% coefficient
a0	= 1;
sigma = 0.6746;
if strcmp(Method,'SPT')
    a1 = -0.2174;
    alpha0	=28.695;
    alpha1	=-5.0571;
    alpha2	=-12.574;
    density_threshold_1=12.6;
    density_threshold_2=17.2;
else % CPT
    a1 = -0.036;
    alpha0	=24.666;
    alpha1	=-26.39;
    alpha2	=-4.4152;
    density_threshold_1=112.4;
    density_threshold_2=140.2;
end
b0	=0.3026;
b1	=-0.0205;
c0	=1.3558;
c1	=-0.134;
d0	=-1.3446;
d1	=0.2303;
d2	=0.4189;
e0	=-0.8727;
e1	=0.1137;
e2	=-0.0947;
e3	=-0.2148;
f0	=-0.0137;
f1	=0.0021;
f2	=0.1703;
s1	=0.4973;

if LPC ==1 % Yes
    FSC = 1;
else
    FSC = 0;
end

k0	=-1.544;
k1	=0.025;
k2	=0.0295;
k3	=-0.0218;

%% Calculation
fs = nan*zeros(1,10);
fH = zeros(1,10);
H_Hs= nan*zeros(1,10);
layerTerm1= nan*zeros(1,10);
critLayer1=  zeros(1,10);
for i = 1:10
    % fs
    if N(i)<density_threshold_1
        fs(i)=a0;
    elseif N(i)<density_threshold_2
        fs(i)=a0+a1*(N(i)-density_threshold_1);
    else
        fs(i)=a0+a1*(density_threshold_2-density_threshold_1);
    end
    %fH
    fH(i)=b0*Hs(i)*exp(b1*(max(Ds(i),2)^2-4));
    %H_Hs
    if Hs(i)>=1
        H_Hs(i)=1;
    else
        H_Hs(i)=0;
    end
    layerTerm1(i)=fs(i)*fH(i)*H_Hs(i);
end
for i = 1:10
    if layerTerm1(i) == max(layerTerm1)
        critLayer1(i)=1;
    end
end
fsc = (c0+c1*log(cav))*FSC;
Fso = fsc + sum(layerTerm1);

%
fq = (d0+d1*log(min(cav,1000)))*log(q)*exp(d2*min(0,B-max(Ds(1),2)));
fA = (e0+e1*log(max(cav,1500)))*(log(B))^2+e2*(L/B)+e3*Df;
fh = (f0+f1*log(min(cav,1000)))*(0.7*h)^2+f2*min(Mst/(10^6),1);
Fst = fq+fA+fh;

log_Snum=Fso+Fst+s1*log(cav);

% if strcmp(Method,'SPT')
%     N1_60_1_equivalent=N(1);
% else
%     N1_60_1_equivalent=46*(0.478*N(1)^0.264-1.063)^2;
% end

lnS=log_Snum+k0+k1*(min(sum(critLayer1.*Hs),12))^2+k2*min(q,61)+k3*max(q-61,0);

fl=nan*zeros(1,10);
fH=zeros(1,10);
for i = 1:10
    if N<density_threshold_2
        fl(i)=1;
    else
        fl(i)=0;
    end
    try
        fH(i)=Hs(i)/Ds(i)/N(i);
    catch
        fH(i)=0;
    end
end
% idx =isnan(fH);
% fH(idx)=0;
% score_S_lessthan_10mm = alpha0+alpha1*sum(fl.*fH)+alpha2*log(min(cav,1000));
% pd = makedist('Normal','mu',0,'sigma',1);
% prob_S_lessthan_10mm = cdf(pd,score_S_lessthan_10mm);

end