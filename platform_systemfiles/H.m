function [Hx] = H(n,x)

switch n
    case  0,  Hx = x.^0;
    case  1,  Hx = x.^1;
    case  2,  Hx = x.^2-1;
    case  3,  Hx = x.^3 - 3.*x;
    case  4,  Hx = x.^4 - 6.*x.^2 + 3;
    case  5,  Hx = x.^5 - 10.*x.^3 + 15.*x;
    case  6,  Hx = x.^6 -15.*x.^4 + 45.*x.^2 - 15;
    case  7,  Hx = x.^7 - 21.*x.^5 +105.*x.^3 - 105.*x;
    case  8,  Hx = x.^8 - 28.*x.^6 + 210.*x.^4 - 420.*x.^2 + 105;
    case  9,  Hx = x.^9 - 36.*x.^7 + 378.*x.^5 - 1260.*x.^3 + 945.*x;
    case  10, Hx = x.^10 - 45.*x.^8 + 630.*x.^6 - 3150.*x.^4 + 4725.*x.^2 - 945;
    otherwise
        Hx = 2^(-n/2)*hermiteH(n,x/sqrt(2));
end


