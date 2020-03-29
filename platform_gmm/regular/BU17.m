function [lnY,sigma,tau,phi] = BU17(To,Mw, Rrup, H,environment,mechanism)

% Bullock, Z., Dashti, S., Liel, A., Porter, K., Karimi, Z., & Bradley, B. (2017).
% Ground?motion prediction equations for Arias intensity, cumulative absolute
% velocity, and peak incremental ground velocity for rock sites in different
% tectonic environments.
% Bulletin of the Seismological Society of America, 107(5), 2293-2309.
% https://doi.org/10.1785/0120160388

% To=-4   CAV, CAVt5 or CAVSTD
% To=-5   AI
% To=-6   VGI

lnY   = nan(size(Mw));
sigma = nan(size(Mw));
tau   = nan(size(Mw));
phi   = nan(size(Mw));

if ~ismember(To,[-4 -5 -6])
    return
end

FR=0;
FN=0;

switch environment
    case 'crustal'
        switch mechanism
            case 'normal',  FN = 1;%normal
            case 'reverse', FR = 1;%reverse
        end
        switch To
            case -5   , Coef=[-18.784 7.758 -0.576 -4.013 0.435 -0.0213 nan 0.005 -0.58 0.786 0.747 1.084  ];
            case -4   , Coef=[-5.8 3.593 -0.231 -1.415 0.138 -0.007 nan -0.155 -0.343 0.398 0.331 0.518    ];
            case -4.1 , Coef=[-9.397 5.356 -0.395 -3.372 0.381 -0.011 nan -0.197 -0.231 0.49 0.53 0.722    ];
            case -4.2 , Coef=[-10.836 5.165 -0.335 -1.563 0.087 -0.0019 nan -0.129 -0.273 0.529 0.392 0.658];
            case -6   , Coef=[-8.283 4.48 -0.353 -2.724 0.294 -0.0064 nan 0.071 -0.39 0.545 0.452 0.708    ];
        end
    case 'intraplate'
        switch To
            case -5   , Coef=[-33.761 11.016 -0.717 -0.421 -0.125 -0.0093 nan 0 0 0.534 0.325 0.625];
            case -4   , Coef=[-13.063 5.078 -0.273 0.439 -0.145 -0.0047 nan 0 0 0.262 0.411 0.487  ];
            case -4.1 , Coef=[-28.527 8.034 -0.157 2.913 -0.825 -0.0089 nan 0 0 0.463 0.553 0.721  ];
            case -4.2 , Coef=[nan nan nan nan nan nan nan 0 0 nan nan nan                          ];
            case -6   , Coef=[-3.029 0.931 0.04 -0.828 0.048 -0.0034 nan 0 0 0.34 0.483 0.591      ];
        end
    case 'subduction-interface'
        switch To
            case -5   , Coef=[-15.39 3.704 0.201 0.692 -0.774 0.0107 0 nan nan 0.582 0.675 0.891];
            case -4   , Coef=[-3.674 1.74 0.098 0.381 -0.334 0.0047 0 nan nan 0.319 0.298 0.437 ];
            case -4.1 , Coef=[-5.796 1.876 0.311 0.484 -0.699 0.0067 0 nan nan 0.752 0.567 0.942];
            case -4.2 , Coef=[3.684 -0.575 0.335 0.565 -0.503 0.0071 0 nan nan 0.406 0.222 0.463];
            case -6   , Coef=[-8.735 2.454 0.052 0.231 -0.354 0.006 0 nan nan 0.343 0.425 0.546 ];
        end
    case 'subduction-intraslab'
        switch To
            case -5   , Coef=[-15.39 3.704 0.201 0 -0.615 0 0.018 nan nan 0.582 0.675 0.891 ];
            case -4   , Coef=[-3.674 1.74 0.098 0 -0.25 0 0.0066 nan nan 0.319 0.298 0.437  ];
            case -4.1 , Coef=[-5.796 1.876 0.311 0 -0.572 0 0.0161 nan nan 0.752 0.567 0.942];
            case -4.2 , Coef=[3.684 -0.575 0.335 0 -0.357 0 0.0089 nan nan 0.406 0.222 0.463];
            case -6   , Coef=[-8.735 2.454 0.052 0 -0.289 0 0.0095 nan nan 0.343 0.425 0.546];
        end
    case 'subduction-unknown'
        switch To
            case -5   , Coef=[-15.969 4.203 0.092 -0.383 -0.538 0.0051 0.0195 nan nan 0.659 0.683 0.949];
            case -4   , Coef=[-4.865 2.108 0.036 -0.009 -0.22 0.0014 0.0074 nan nan 0.312 0.302 0.434  ];
            case -4.1 , Coef=[-0.902 2.471 0.131 -2.611 -0.289 0.0087 0.0268 nan nan 0.876 0.869 1.234 ];
            case -4.2 , Coef=[-9.658 0.705 0.314 3.364 -0.702 -0.0035 0.0191 nan nan 0.423 0.247 0.49  ];
            case -6   , Coef=[1.126 1.343 -0.062 -2.737 0.182 0.0013 0.011 nan nan 0.384 0.421 0.57    ];
        end
end

a0    = Coef(1);
a1    = Coef(2);
a2    = Coef(3);
b1    = Coef(4);
b2    = Coef(5);
b3    = Coef(6);
b4    = Coef(7);
f1    = Coef(8);
f2    = Coef(9);
tau   = Coef(10);
phi   = Coef(11);
sigma = Coef(12);
delta = 0.00724*10.^(0.507*min(Mw,8));
D      = sqrt(delta.^2+Rrup.^2);

switch environment
    case 'crustal'             ,  lnY = a0 + a1*Mw + a2*Mw.^2 + (b1 + b2*Mw).*log(Rrup) +b3*Rrup+f1*FR+f2*FN;
    case 'intraplate'          ,  lnY = a0 + a1*Mw + a2*Mw.^2 + (b1 + b2*Mw).*log(Rrup) +b3*Rrup+f1*FR+f2*FN;
    case 'subduction-interface',  lnY = a0 + a1*Mw + a2*Mw.^2 + (b1 + b2*Mw).*log(D)    +b3*D+b4*H; % subduction
    case 'subduction-intraslab',  lnY = a0 + a1*Mw + a2*Mw.^2 + (b1 + b2*Mw).*log(D)    +b3*D+b4*H; % subduction
    case 'subduction-unknown'  ,  lnY = a0 + a1*Mw + a2*Mw.^2 + (b1 + b2*Mw).*log(D)    +b3*D+b4*H; % subduction
end

lnY = lnY-log(100);  %cm/s to m/s

