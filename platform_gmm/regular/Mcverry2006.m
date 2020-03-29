function [lny,sigma,tau,phi]=Mcverry2006(To,M,Rrup,Hc,mechanism,media,rvol)

%McVerry GH, Zhao JX, Abrahamson NA, Somerville PG. New Zealand
%Accelerations Response Spectrum Attenuation Relations for Crustal and
%Subduction Zone Earthquakes.  Bulletin of the New Zealand Society of
%Earthquake Engineering. Vol 39, No 4. March 2006

lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if  and(To<0 || To> 3,To~=-1)
    return
end

if To>=0
    To      = max(To,0.001); %PGA is associated to To=0.01;
end

period  = [-1.0, 0.001, 0.075,      0.1,      0.2,      0.3,      0.4,      0.5,     0.75,      1.0,      1.5,      2.0,      3.0];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma,tau,phi] = gmpe(index,M,Rrup,Hc,mechanism,media,rvol);
else
    [lny_lo,sigma_lo,tau_lo] = gmpe(index,  M,Rrup,Hc,mechanism,media,rvol);
    [lny_hi,sigma_hi,tau_hi] = gmpe(index+1,M,Rrup,Hc,mechanism,media,rvol);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_tau      = [tau_lo,tau_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    tau        = interp1(x,Y_tau,log(To))';
    phi        = sqrt(sigma.^2-tau.^2);
end


function[lny,sigma,tau,sig]=gmpe(index,M,R,Hc,mechanism,media,rvol)

C1        = [  0.14274    0.07713     1.2205    1.53365    1.22565    0.21124   -0.10541    -0.1426   -0.65968   -0.51404   -0.95399   -1.24167     -1.5657];
C3AS      = [        0          0       0.03      0.028    -0.0138     -0.036    -0.0518    -0.0635    -0.0862     -0.102      -0.12      -0.12     -0.1726];
C5        = [ -0.00989   -0.00898   -0.00914   -0.00903   -0.00975   -0.01032   -0.00941   -0.00878   -0.00802   -0.00647   -0.00713   -0.00713    -0.00623];
C8        = [ -0.68744   -0.73728   -0.93059   -0.96506   -0.75855     -0.524   -0.50802   -0.52214   -0.47264   -0.58672   -0.49268   -0.49268    -0.52257];
C10AS     = [      5.6        5.6       5.58        5.5        5.1        4.8       4.52        4.3        3.9        3.7       3.55       3.55         3.5];
C11       = [  8.57343    8.08611    8.69303      9.304   10.41628    9.21783     8.0115    7.87495    7.26785    6.98741    6.77543    6.48775     5.05424];
C13y      = [        0          0          0    -0.0011    -0.0027    -0.0036    -0.0043    -0.0048    -0.0057    -0.0064    -0.0073    -0.0073     -0.0089];
C15       = [   -2.552     -2.552     -2.707     -2.655     -2.528     -2.454     -2.401      -2.36     -2.286     -2.234      -2.16      -2.16      -2.033];
C17       = [ -2.56592   -2.49894   -2.55903   -2.61372   -2.70038   -2.47356   -2.30457   -2.31991    -2.2846   -2.28256   -2.27895   -2.27895     -2.0556];
C20       = [  0.01545     0.0159    0.01821    0.01737    0.01531    0.01304    0.01426    0.01277    0.01055    0.00927    0.00748    0.00748    -0.00273];
C24       = [ -0.49963   -0.43223   -0.52504   -0.61452   -0.65966   -0.56604   -0.33169   -0.24374   -0.01583    0.02009   -0.07051   -0.07051    -0.23967];
C29       = [  0.27315     0.3873    0.27879    0.28619    0.34064    0.53213    0.63272    0.58809    0.50708    0.33002    0.07445    0.07445     0.09869];
C30AS     = [    -0.23      -0.23      -0.28      -0.28     -0.245     -0.195      -0.16     -0.121      -0.05          0       0.04       0.04        0.04];
C33AS     = [     0.26       0.26       0.26       0.26       0.26      0.198      0.154      0.119      0.057      0.013     -0.049     -0.049      -0.156];
C43       = [ -0.33716   -0.31036   -0.49068   -0.46604   -0.31282   -0.07565    0.17615    0.34775     0.7238    0.89239    0.77743    0.77743     0.60938];
C46       = [ -0.03255    -0.0325   -0.03441   -0.03594   -0.03823   -0.03535   -0.03354   -0.03211   -0.02857     -0.025   -0.02008   -0.02008    -0.01587];
Sigma6    = [   0.4871     0.5099     0.5297     0.5401     0.5599     0.5456     0.5556     0.5658     0.5611     0.5573     0.5419     0.5419      0.5809];
Sigslope  = [  -0.1011    -0.0259    -0.0703    -0.0292     0.0172    -0.0566    -0.1064    -0.1123    -0.0836     -0.062     0.0385     0.0385      0.1403];
Tau       = [   0.2677     0.2469     0.3139     0.3017     0.2583     0.1967     0.1802      0.144     0.1871     0.2073     0.2405     0.2405      0.2053];
C4AS      = -0.144;
C6AS      = 0.17;
C12y      = 1.414;
C18y      = 1.7818;
C19y      = 0.554;
C32       = 0.2;

%site class
delC=0;
delD=0;
switch media
    case 'A'
    case 'B'
    case 'C',delC=1;
    case 'D',delD=1;
    case 'E'      
end

switch mechanism
    case 'normal'      ,CN=-1; CR=0;   CS=0;
    case 'reverse'     ,CN= 0; CR=1;   CS=0;
    case 'oblique'     ,CN= 0; CR=0.5; CS=0;
    case 'strike-slip' ,CN= 0; CR=0;   CS=0;
    case 'intraslab'   ,SI= 0; DS=1;   CS=1; rvol=0;
    case 'interface'   ,SI= 1; DS=0;   CS=1;
end

i = index;
if CS==0 %crustal prediction equation
    PGA_AB=     exp(C1(1)+C4AS*(M-6)+C3AS(1)*(8.5-M).^2+C5(1)*R+(C8(1)+C6AS*(M-6)).*log(sqrt(R.^2+C10AS(1)^2))+C46(1)*rvol+C32*CN+C33AS(1)*CR);
    PGA_primeAB=exp(C1(2)+C4AS*(M-6)+C3AS(2)*(8.5-M).^2+C5(2)*R+(C8(2)+C6AS*(M-6)).*log(sqrt(R.^2+C10AS(2)^2))+C46(2)*rvol+C32*CN+C33AS(2)*CR);
    Sa_primeAB= exp(C1(i)+C4AS*(M-6)+C3AS(i)*(8.5-M).^2+C5(i)*R+(C8(i)+C6AS*(M-6)).*log(sqrt(R.^2+C10AS(i)^2))+C46(i)*rvol+C32*CN+C33AS(i)*CR);
    
elseif CS==1 %subduction attenuation
    PGA_AB=     exp(C11(1)+(C12y+(C15(1)-C17(1))*C19y)*(M-6)+C13y(1)*(10-M).^3+C17(1)*log(R+C18y*exp(C19y*M))+C20(1)*Hc+C24(1)*SI+C46(1)*rvol*(1-DS));
    PGA_primeAB=exp(C11(2)+(C12y+(C15(2)-C17(2))*C19y)*(M-6)+C13y(2)*(10-M).^3+C17(2)*log(R+C18y*exp(C19y*M))+C20(2)*Hc+C24(2)*SI+C46(2)*rvol*(1-DS));
    Sa_primeAB= exp(C11(i)+(C12y+(C15(i)-C17(i))*C19y)*(M-6)+C13y(i)*(10-M).^3+C17(i)*log(R+C18y*exp(C19y*M))+C20(i)*Hc+C24(i)*SI+C46(i)*rvol*(1-DS));
end

PGA_CD      =      PGA_AB.*exp(C29(1)*delC+(C30AS(1)*log(PGA_primeAB+0.03)+C43(1))*delD);
PGA_primeCD = PGA_primeAB.*exp(C29(2)*delC+(C30AS(2)*log(PGA_primeAB+0.03)+C43(2))*delD);
Sa_primeCD  =  Sa_primeAB.*exp(C29(i)*delC+(C30AS(i)*log(PGA_primeAB+0.03)+C43(i))*delD);
Sa          =  Sa_primeCD.*PGA_CD./PGA_primeCD;

%standard deviation
lny   = log(Sa);
tau   = Tau(i)*ones(size(M));
sig   = Sigma6(i)-Sigslope(i)*(M<5)+Sigslope(i)*(M-6).*and(M>=5,M<=7)+Sigslope(i)*(M>7);
sigma = sqrt(tau.^2+sig.^2);
