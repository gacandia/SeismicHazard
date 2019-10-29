function [lnY] = VGI_temp(To,Mw, Rrup, H,Environment, mechanism)

FR=0;
FN=0;
delta = 0.00724*10^(0.507*min(Mw,8));
D=sqrt(delta^2+Rrup^2);

switch Environment
    case 'crustal'
        a0 =-8.283;
        a1 = 4.48;
        a2 =-0.353;
        b1 =-2.724;
        b2 = 0.294;
        b3 =-0.0064;
        b4 = 0;
        f1 = 0.071;
        f2 =-0.39;
        
        switch mechanism
            case 'normal',  FN = 1;%normal
            case 'reverse', FR = 1;%reverse
        end
        
    case 2 % Subduction
        switch mechanism
            case 'interface'
                a0 =-8.735;
                a1 = 2.454;
                a2 = 0.052;
                b1 = 0.231;
                b2 =-0.354;
                b3 = 0.006;
                b4 = 0;
                f1 = 0;
                f2 = 0;
            case 'intraslab'
                a0 =-8.735;
                a1 = 2.454;
                a2 = 0.052;
                b1 = 0;
                b2 =-0.289;
                b3 = 0;
                b4 = 0.0095;
                f1 = 0;
                f2 = 0;
            case 'unknown'
                a0 = 1.126;
                a1 = 1.343;
                a2 =-0.062;
                b1 =-2.737;
                b2 = 0.182;
                b3 = 0.0013;
                b4 = 0.011;
                f1 = 0;
                f2 = 0;
        end
    case 'intraplate'
        a0 =-3.029;
        a1 = 0.931;
        a2 = 0.04;
        b1 =-0.828;
        b2 = 0.048;
        b3 =-0.0034;
        b4 = 0;
        f1 = 0;
        f2 = 0;
end

switch Environment
    case  'subduction'   , lnY = a0 + a1*Mw + a2*Mw^2 + (b1 + b2*Mw)*log(D) +b3*D+b4*H;
    otherwise            , lnY = a0 + a1*Mw + a2*Mw^2 + (b1 + b2*Mw)*log(Rrup) +b3*Rrup+f1*FR+f2*FN;
end

% function [logmedian] = VGI(Mw, Rrup, H,TectonicEnvironment, RuptureMechanism)
% 
% FR=0;
% FN=0;
% delta = 0.00724*10^(0.507*min(Mw,8));
% D=sqrt(delta^2+Rrup^2); 
% 
%     if TectonicEnvironment == 1 % crustal
%         a0= -8.283;
%         a1=	4.48;
%         a2=	-0.353;
%         b1=	-2.724;
%         b2=	0.294;
%         b3=	-0.0064;
%         b4=	0;
%         f1=	0.071;
%         f2=	-0.39;
%         if RuptureMechanism == 1%normal
%             FN = 1;
%         elseif RuptureMechanism == 4%reverse
%             FR = 1;
%         end
% 
%     elseif TectonicEnvironment == 2 % Subduction
%         if RuptureMechanism == 2 % interface
%             a0	=-8.735;
%             a1	=2.454;
%             a2	=0.052;
%             b1	=0.231;
%             b2	=-0.354;
%             b3	=0.006;
%             b4	=0;
%             f1	=0;
%             f2	=0;
%         elseif RuptureMechanism == 3 % intraslab
%             a0	=-8.735;
%             a1	=2.454;
%             a2	=0.052;
%             b1	=0;
%             b2	=-0.289;
%             b3	=0;
%             b4	=0.0095;
%             f1	=0;
%             f2	=0;
%         elseif RuptureMechanism == 5 % unknow
%             a0	=1.126;
%             a1	=1.343;
%             a2	=-0.062;
%             b1	=-2.737;
%             b2	=0.182;
%             b3	=0.0013;
%             b4	=0.011;
%             f1	=0;
%             f2	=0;
%         end
%     elseif TectonicEnvironment == 3 % Intraplate
%         a0	=-3.029;
%         a1	= 0.931;
%         a2	= 0.04;
%         b1	= -0.828;
%         b2	= 0.048;
%         b3	= -0.0034;
%         b4	= 0;
%         f1	= 0;
%         f2	= 0;
%     end
%     
%     if TectonicEnvironment == 2 % subduction
%         logmedian = a0 + a1*Mw + a2*Mw^2 + (b1 + b2*Mw)*log(D) +b3*D+b4*H;
%     else % shallow crustal or intraplate
%         logmedian = a0 + a1*Mw + a2*Mw^2 + (b1 + b2*Mw)*log(Rrup) +b3*Rrup+f1*FR+f2*FN;
%     end 
% end