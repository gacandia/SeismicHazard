%**************************************************************************
% This function returns the mean and std of Cumulative Absolute Velocity (CAV)
% Citation: Ground Motion Models for the Horizontal Components of Arias 
%           Intensity (AI) and Cumulative Absolute Velocity (CAV) Using
%           the NGA-West2 Database. Kenneth W. Campbell,a) M.EERI,
%           and Yousef Bozorgnia,b) M.EERI
% Coded by Qiwei Mao 05/24/2019
%          Georgia Institute of Technology, qmao36@gatech.edu
%**************************************************************************
% W (km) is the down-dip width of the fault rupture plane.
% M = Magnitude
% Rrup (km) is closest distance to the coseismic fault rupture plane (a.k.a. rupture distance).
% delta or ? (°) is the average dip angle of the fault rupture plane measured from horizontal.
% FRV is an indicator variable representing reverse and reverse-oblique faulting, where FRV = 1for 30°<?<150°andFRV =0 otherwise.
% FNM is an indicator variable representing normal and normal-oblique faulting, where FNM 1?4 1 for 150° < ? < 30° and FNM 1?4 0 otherwise.
% Rx (km) is closest distance to the surface projection of the top edge of the coseismic fault rupture plane measured perpendicular to its average strike (Ancheta et al. 2013).
% SJ is an indicator variable representing regional site effects, where SJ 1?4 1 for sites located in Japan and SJ 1?4 0 otherwise.

function [lny, std,tau,fi]= CB19(M,rup,Zhyp,delta,lamda,vs30,W,Rx,rjb,Ztor,Z25,SJ)

if lamda>30 && lamda<150
    Frv = 1;
else
    Frv = 0;
end

if lamda>-150 && lamda<-30
    Fnm = 1;
else
    Fnm = 0;
end

c_coef = [-4.75,1.397,0.282,-1.062,-0.170,-1.624,0.134,6.325,0.054,-0.1,0.469,1.015,1.208,1.777,0.1248,-0.191,1.087,0.0432,0.0127,0.00429,-0.0043];%contains c0~c20
c=1.88;
c0 = c_coef(1);
c1 = c_coef(2);
c2 = c_coef(3);
c3 = c_coef(4);
c4 = c_coef(5);
c5 = c_coef(6);
c6 = c_coef(7);
c7 = c_coef(8);
c8 = c_coef(9);
c9 = c_coef(10);
c10 = c_coef(11);
c11 = c_coef(12);
c12 = c_coef(13);
c13 = c_coef(14);
c14 = c_coef(15);
c15 = c_coef(16);
c16 = c_coef(17);
c17 = c_coef(18);
c18 = c_coef(19);
c19 = c_coef(20);
c20 = c_coef(21);
h1=0.241;
h2=1.474;
h3=-0.715;
h4=1;
h5=-0.337;
h6=-0.27;
a2=0.167;% assumed to be the same as a1
k1=400;
k2=-1.311;
k3=1;
delta_c20= 0.0015;% -0.0024 or 0.0027
n=1.18;
% standard deviation CAV
fi_lnAF_CAV=0.3;
fi1_CAV=0.514;
fi2_CAV=0.394;
tau1_CAV=0.276;
tau2_CAV=0.257;
sigma1_CAV=0.583;
sigma2_CAV=0.470;
% standard deviation PGA
fi_lnAF_PGA=0.3;
fi1_PGA=0.734;
fi2_PGA=0.492;
tau1_PGA=0.409;
tau2_PGA=0.322;
sigma1_PGA=0.840;
sigma2_PGA=0.588;

rou1=0.842;
rou2=0.780;
%% Magnitude Term
if  M <= 4.5
        fmag = c0 + c1*M;
elseif M > 4.5 && M <= 5.5
        fmag = c0 + c1*M + c2*(M-4.5);
elseif M > 5.5 && M <= 6.5
        fmag = c0 + c1*M + c2*(M-4.5) + c3*(M-5.5);
elseif M > 6.5
        fmag = c0 + c1*M + c2*(M-4.5) + c3*(M-5.5) + c4*(M-6.5);
end

%% Geometric Attenuation Term
fdis = (c5 + c6*M)*log(sqrt(rup^2+c7^2));

%% Style of Faulting Term
fflt_F = c8*Frv + c9*Fnm;
if M <= 4.5
    fflt_M = 0;
elseif M >4.5 && M <= 5.5
    fflt_M = M - 4.5;
elseif M > 5.5
    fflt_M = 1;
end
fflt = fflt_F * fflt_M;
%% Hanging Wall Term
R1 = W*cos(delta/180*pi);
R2 = 62*M-350;
f1_Rx=h1+h2*Rx/R1+h3*(Rx/R1)^2;
f2_Rx=h4+h5*(Rx-R1)/(R2-R1)+h6*((Rx-R1)/(R2-R1))^2;

if Rx<0
    fhng_Rx = 0;
elseif Rx>=0 && Rx<R1
    fhng_Rx = f1_Rx;
elseif Rx>=R1
    fhng_Rx = max(f2_Rx,0);
end

if rup == 0
    fhng_rup=1;
elseif rup >0
    fhng_rup = (rup-rjb)/rup;
end

if M<=5.5
    fhng_M = 0;
elseif M>5.5 && M<=6.5
    fhng_M=(M-5.5)*(1+a2*(M-6.5));
elseif M>6.5
    fhng_M=1+a2*(M-6.5);
end

if Ztor<=16.66
    fhng_Z=1-0.06*Ztor;
elseif Ztor>16.66
    fhng_Z=0;
end

fhng_delta=(90-delta)/45;

fhng=c10*fhng_Rx*fhng_rup*fhng_M*fhng_Z*fhng_delta;

%% Shallow Site Response Term
%*****************************************************************************
%solve for A1100 reciprocally using CB14


[A1100,~]=CB14(M,rup,Zhyp,delta,lamda,1100,W,Rx,rjb,Ztor,Z25,SJ);


% A1100=3.837E-01;
%*****************************************************************************
if vs30<=k1
    fsite_G=c11*log(vs30/k1)+k2*(log(A1100+c*(vs30/k1)^n)-log(A1100+c));
else
    fsite_G=(c11+k2*n)*log(vs30/k1);
end
if vs30<=200
    fsite_J=(c12+k2*n)*(log(vs30/k1)-log(200/k1));
else
    fsite_J=(c13+k2*n)*log(vs30/k1);
end 
fsite = fsite_G+SJ*fsite_J;
%% Basin Response Term
if Z25==999
    fsed=0;
elseif Z25<=1
    fsed=(c14+c15*SJ)*(Z25-1);
elseif Z25>1 &&Z25<=3
    fsed=0;
elseif Z25>3
    fsed=c16*k3*e^-0.75*(1-exp(-0.25*(Z25-3)));
end
%% Hypocentral Depth Term
if Zhyp<=7
    fhyph = 0;
elseif Zhyp > 7 && Zhyp <= 20
    fhyph = Zhyp-7;
elseif Zhyp>20
    fhyph = 13;
end

if M<=5.5
    fhypm = c17;
elseif M > 5.5 && M<=6.5
    fhypm = c17+(c18-c17)*(M-5.5);
elseif M >6.5
    fhypm = c18;
end

fhyp = fhyph*fhypm;

%% Fault Dip Term
if M<=4.5
    fdip = c19*delta;
elseif M > 4.5 && M<=5.5
    fdip = c19*(5.5-M)*delta;
elseif M >5.5
    fdip = 0;
end
%% Anelastic Attenuation Term
if rup>80
    fatn=(c20+delta_c20)*(rup-80);
else
    fatn=0;
end
%% standard deviation
if M<=4.5
    tau_ln_CAV=tau1_CAV;
    tau_ln_PGA=tau1_PGA;
    fi_ln_CAV=fi1_CAV;
    fi_ln_PGA=fi1_PGA;
    rou=rou1;
elseif M>4.5 && M<5.5
    tau_ln_CAV=tau2_CAV+(tau1_CAV-tau2_CAV)*(5.5-M);
    tau_ln_PGA=tau2_PGA+(tau1_PGA-tau2_PGA)*(5.5-M);
    fi_ln_CAV=fi2_CAV+(fi1_CAV-fi2_CAV)*(5.5-M);
    fi_ln_PGA=fi2_PGA+(fi1_PGA-fi2_PGA)*(5.5-M);
    rou=rou2+(rou1-rou2)*(5.5-M);
elseif M>=5.5
    tau_ln_CAV=tau2_CAV;
    tau_ln_PGA=tau2_PGA;
    fi_ln_CAV=fi2_CAV;
    fi_ln_PGA=fi2_PGA;
    rou=rou2;
end

if vs30<k1
    alpha=k2*A1100*((A1100+c*(vs30/k1)^n)^-1-(A1100+c)^-1);
else
    alpha=0;
end

tau=sqrt(tau_ln_CAV^2+alpha^2*tau_ln_PGA^2+2*alpha*rou*tau_ln_CAV*tau_ln_PGA);
%fi=sqrt(fi_ln_CAV^2+fi_lnAF_CAV^2+alpha^2*fi_ln_PGA^2+2*alpha*rou*fi_ln_CAV*fi_ln_PGA);
fi=sqrt(fi_ln_CAV^2+alpha^2*fi_ln_PGA^2+2*alpha*rou*fi_ln_CAV*fi_ln_PGA);

std=sqrt(tau^2+fi^2);

%% final result

lny = fmag + fdis+fflt+fhng+fsite+fsed+fhyp+fdip+fatn;

end


%**************************************************************
% CB14
%**************************************************************
% W (km) is the down-dip width of the fault rupture plane.
% M = Magnitude
% Rrup (km) is closest distance to the coseismic fault rupture plane (a.k.a. rupture distance).
% delta or ? (°) is the average dip angle of the fault rupture plane measured from horizontal.
% FRV is an indicator variable representing reverse and reverse-oblique faulting, where FRV = 1for 30°<?<150°andFRV =0 otherwise.
% FNM is an indicator variable representing normal and normal-oblique faulting, where FNM 1?4 1 for 150° < ? < 30° and FNM 1?4 0 otherwise.
% Rx (km) is closest distance to the surface projection of the top edge of the coseismic fault rupture plane measured perpendicular to its average strike (Ancheta et al. 2013).
% SJ is an indicator variable representing regional site effects, where SJ 1?4 1 for sites located in Japan and SJ 1?4 0 otherwise.

function [mean, std]= CB14(M,rup,Zhyp,delta,lamda,vs30,W,Rx,rjb,Ztor,Z25,SJ)
if lamda>30&&lamda<150
    Frv = 1;
else
    Frv = 0;
end

if lamda>-150&&lamda<-30
    Fnm = 1;
else
    Fnm = 0;
end

c=1.88;
c0 = -4.416;
c1 = 0.984;
c2 = 0.537;
c3 = -1.499;
c4 = -0.496;
c5 = -2.773;
c6 = 0.248;
c7 = 6.768;
c8 = 0;
c9 = -0.212;
c10 = 0.720;
c11 = 1.094;
c12 = 2.186;
c13 = 1.420;
c14 = -0.0064;
c15 = -0.202;
c16 = 0.393;
c17 = 0.0977;
c18 = 0.0333;
c19 = 0.00757;
c20 = -0.0055;
h1=0.241;
h2=1.474;
h3=-0.715;
h4=1;
h5=-0.337;
h6=-0.27;

a2=0.167;% assumed to be the same as a1
k1=865;
k2=-1.186;
k3=1.839;
delta_c20= 0.00005;% -0.0035 or 0.0036
n=1.18;
%% Magnitude Term
if  M <= 4.5
        fmag = c0 + c1*M;
elseif M > 4.5 && M <= 5.5
        fmag = c0 + c1*M + c2*(M-4.5);
elseif M > 5.5 && M <= 6.5
        fmag = c0 + c1*M + c2*(M-4.5) + c3*(M-5.5);
elseif M > 6.5
        fmag = c0 + c1*M + c2*(M-4.5) + c3*(M-5.5) + c4*(M-6.5);
end

%% Geometric Attenuation Term
fdis = (c5 + c6*M)*log(sqrt(rup^2+c7^2));

%% Style of Faulting Term
fflt_F = c8*Frv + c9*Fnm;
if M <= 4.5
    fflt_M = 0;
elseif M >4.5 && M <= 5.5
    fflt_M = M - 4.5;
elseif M > 5.5
    fflt_M = 1;
end
fflt = fflt_F * fflt_M;

%% Hanging Wall Term
R1 = W*cos(delta/180*pi);
R2 = 62*M-350;
f1_Rx=h1+h2*Rx/R1+h3*(Rx/R1)^2;
f2_Rx=h4+h5*(Rx-R1)/(R2-R1)+h6*((Rx-R1)/(R2-R1))^2;

if Rx<0
    fhng_Rx = 0;
elseif Rx>=0 && Rx<R1
    fhng_Rx = f1_Rx;
elseif Rx>=R1
    fhng_Rx = max(f2_Rx,0);
end

if rup == 0
    fhng_rup=1;
elseif rup >0
    fhng_rup = (rup-rjb)/rup;
end

if M<=5.5
    fhng_M = 0;
elseif M>5.5 && M<=6.5
    fhng_M=(M-5.5)*(1+a2*(M-6.5));
elseif M>6.5
    fhng_M=1+a2*(M-6.5);
end

if Ztor<=16.66
    fhng_Z=1-0.06*Ztor;
elseif Ztor>16.66
    fhng_Z=0;
end

fhng_delta=(90-delta)/45;

fhng=c10*fhng_Rx*fhng_rup*fhng_M*fhng_Z*fhng_delta;

%% Shallow Site Response Term
if vs30<=k1
    
    A1100=CB14_sub(M,rup,Zhyp,delta,W,Rx,rjb,Ztor,Z25,SJ);
    
    fsite_G=c11*log(vs30/k1)+k2*(log(A1100+c*(vs30/k1)^n)-log(A1100+c));
else
    fsite_G=(c11+k2*n)*log(vs30/k1);
end

if vs30<=200
    fsite_J=(c12+k2*n)*(log(vs30/k1)-log(200/k1));
else
    fsite_J=(c13+k2*n)*log(vs30/k1);
end

fsite = fsite_G+SJ*fsite_J;

%% Basin Response Term
if Z25==999
    fsed=0;
elseif Z25<=1
    fsed=(c14+c15*SJ)*(Z25-1);
elseif Z25>1 &&Z25<=3
    fsed=0;
elseif Z25>3
    fsed=c16*k3*e^-0.75*(1-exp(-0.25*(Z25-3)));
end

%% Hypocentral Depth Term
if Zhyp<=7
    fhyph = 0;
elseif Zhyp > 7 && Zhyp <= 20
    fhyph = Zhyp-7;
elseif Zhyp>20
    fhyph = 13;
end

if M<=5.5
    fhypm = c17;
elseif M > 5.5 && M<=6.5
    fhypm = c17+(c18-c17)*(M-5.5);
elseif M >6.5
    fhypm = c18;
end

fhyp = fhyph*fhypm;

%% Fault Dip Term
if M<=4.5
    fdip = c19*delta;
elseif M > 4.5 && M<=5.5
    fdip = c19*(5.5-M)*delta;
elseif M >5.5
    fdip = 0;
end
%% Anelastic Attenuation Term
if rup>80
    fatn=(c20+delta_c20)*(rup-80);
else
    fatn=0;
end

%%
mean = exp(fmag + fdis+fflt+fhng+fsite+fsed+fhyp+fdip+fatn);
std =0;
%{ std = 0.1;
% c_coefi_tau = [];%---************************************
% c_coefi_fi = [];
% 
% if M<=4.5
%     tau_lnY = tau1;
% elseif M>4.5&&M<5.5
%     tau_lnY = tau2+(tau1-tau2)*(5.5-M);
% elseif M>=5.5
%     tau_lnY = tau2;
% end
% 
% if M<=4.5
%     fi_lnY = fi1;
% elseif M>4.5&&M<5.5
%     fi_lnY = fi2+(fi1-fi2)*(5.5-M);
% elseif M>=5.5
%     fi_lnY = fi2;
% end
% 
% tau = sqrt()

end

function [A1100]=CB14_sub(M,rup,Zhyp,delta,lamda,W,Rx,rjb,Ztor,Z25,SJ)
    A1100=CB14(M,rup,Zhyp,delta,lamda,1100,W,Rx,rjb,Ztor,Z25,SJ);
end