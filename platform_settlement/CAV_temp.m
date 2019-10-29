function [lnY] = CAV_temp(To,Mw, Rrup, H,Environment, mechanism)

FR=0;
FN=0;
delta = 0.00724*10^(0.507*min(Mw,8));
D=sqrt(delta^2+Rrup^2);
switch Environment
    case 'crustal'
        a0 =-5.8;
        a1 = 3.593;
        a2 =-0.231;
        b1 =-1.415;
        b2 = 0.138;
        b3 =-0.007;
        b4 = 0;
        f1 =-0.155;
        f2 =-0.343;
        
        switch mechanism
            case 'normal',  FN = 1;%normal
            case 'reverse', FR = 1;%reverse
        end
        
    case 2 % Subduction
        switch mechanism
            case 'interface'
                a0 =-3.674;
                a1 = 1.74;
                a2 = 0.098;
                b1 = 0.381;
                b2 =-0.334;
                b3 = 0.0047;
                b4 = 0;
                f1 = 0;
                f2 = 0;
            case 'intraslab'
                a0	=-3.674;
                a1	= 1.74;
                a2	= 0.098;
                b1	= 0;
                b2	=-0.25;
                b3	= 0;
                b4	= 0.0066;
                f1	= 0;
                f2	= 0;
            case 'unknown'
                a0 =-4.865;
                a1 = 2.108;
                a2 = 0.036;
                b1 =-0.009;
                b2 =-0.22;
                b3 = 0.0014;
                b4 = 0.0074;
                f1 = 0;
                f2 = 0;
        end
    case 'intraplate'
        a0 =-13.063;
        a1 = 5.078;
        a2 =-0.273;
        b1 = 0.439;
        b2 =-0.145;
        b3 =-0.0047;
        b4 = 0;
        f1 = 0;
        f2 = 0;
end

switch Environment
    case  'subduction'   , lnY = a0 + a1*Mw + a2*Mw^2 + (b1 + b2*Mw)*log(D) +b3*D+b4*H; % subduction
    otherwise            , lnY = a0 + a1*Mw + a2*Mw^2 + (b1 + b2*Mw)*log(Rrup) +b3*Rrup+f1*FR+f2*FN;
end

