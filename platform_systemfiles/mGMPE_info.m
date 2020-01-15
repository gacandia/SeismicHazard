function [IM,Rmetric,Residuals]=mGMPE_info(model)
%
% [IM,Rmetric,Residuals]=mGMPE_info(model)
%
% Function that retuns information about GMPEs
%
% IM = Intensity Measure Id.
%    = To    for Sa       (Pseudoacceleration at period To, To>0)
%    =  0    for PGA      (Peak Ground Acceleration)
%    = -1    for PGV      (Peak Ground Velocity)
%    = -2    for MMI      (Modified Mercaly Intensity)
%    = -3    for Duration (Duration)
%    = -4    for CAV      (Cummulative Absolute Velocity)
%    = -4.1  for CAV5     (Cummulative Absolute Velocity)
%    = -4.2  for CAVSTD   (Cummulative Absolute Velocity)
%    = -5    for AI       (Arias Intensity)
%    = -6    for VGI      (Incremental Ground Velocity)
%    = -10   for PGD      (Permanent Ground Displacement)
%
% Rmetric is a vector of the distance metrics used by the GMPE (1 or 0)
% if Rmetric(i)=1 means that the i-th metric will be computed, and 0 will
% not be computed. The metris available are:
%
% Rmetric    = [Rrup Rhyp Rjb Repi Zseis Rx Ry0 zhyp ztor zbor zbot]
% 1.-  rrup  = closest diatance from site to rupture plane
% 2.-  rhyp  = distance from the site to the hypocenter
% 3.-  rjb   = Joyner-Boore distance, i.e., closest distance from site to
%              surface projection of rupture area
% 4.-  repi  = epicentral distance
% 5.-  rseis = Shortest distance between the recording site and the presumed
%              zone of seismogenic rupture on the fault
% 6.-  rx    = Horizontal distance from top of rupture measured perpendicular
%              to fault strike
% 7.-  ry0   = Horizontal distance off the end of the rupture measured
%              parallel to strike
% 8.-  zhyp  = depth of hypocenter
% 9.-  ztor  = Depth to top of coseismic rupture (km)
% 10.- zbor  = Depth to the bottom of the rupture plane (km)
% 11.- zbot  = The depth to the bottom of the seismogenic crust (km)

%
% Residuals = Probability distribution of IM rsiduals, e.g., lognormal
switch lower(model)
    case 'youngs1997',                 IM = [0 0.075 0.1 0.2 0.3 0.4 0.5 0.75 1 1.5 2 3];
    case 'atkinsonboore2003',          IM = [0 0.04 0.1 0.2 0.4 1 2 1/0.33];
    case 'zhao2006',                   IM = [0 0.05 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.25 1.5 2 2.5 3 4 5];
    case 'mcverry2006',                IM = [0 0.075 0.1 0.2 0.3 0.4 0.5 0.75 1.0 1.5 2.0 3.0];
    case 'bchydro2012',                IM = [0 0.02 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.75 1 1.5 2 2.5 3 4 5 6 7.5 10];
    case 'arteta2018',                 IM = [0.01 0.02 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.75 1 1.5 2 2.5 3 4 5 6 7.5 10];
    case 'montalvabastias2017',        IM = [0 0.02 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.75 1 1.5 2 2.5 3 4 5 6 7.5 10];
    case 'siberrisk2019',              IM = [-1 0.01 0.02 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.75 1 1.5 2 2.5 3 4 5 6 7.5 10];    
    case 'idini2016',                  IM = [0 0.01 0.02 0.03 0.05 0.07 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
    case 'contrerasboroschek2012',     IM = [0 0.04 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 2];
    case 'garcia2005',                 IM = [-1 0 1/25 1/20 1/13.33 1/10 1/5 1/3.33 1/2.5 1/2 1/1.33 1/1 1/0.67 1/0.5 1/0.33 1/0.25 1/0.2];
    case 'jaimes2006',                 IM = [0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5 5.2 5.4 5.6 5.8 6];
    case 'jaimes2015',                 IM = [-1 0.01 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5];
    case 'jaimes2016',                 IM = [-1 0.00 0.01 0.02 0.03 0.04 0.05 0.08 0.1 0.12 0.15 0.17 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
    case 'garciajaimes2017',           IM = [-1 0 0.01 0.02 0.04 0.06 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 4 5];
    case 'bernal2014',                 IM = [0 0.05 0.1 0.15 0.3 0.5 1 1.5 2 2.5 3 7 8];
    case 'sadigh1997',                 IM = [0.00 0.075 0.10 0.20 0.30 0.40 0.50 0.75 1.00 1.50 2.00 3.00 4.00];
    case 'idriss2008_nga',             IM = [0.01 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
    case 'chiouyoungs2008_nga',        IM = [-1 0 0.01 0.02 0.03 0.04 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1.0 1.5 2.0 3.0 4.0 5.0 7.5 10.0];
    case 'booreatkinson_2008_nga',     IM = [0 0.01 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
    case 'campbellbozorgnia_2008_nga', IM = [-10 -1 0 0.01 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
    case 'abrahamsonsilva2008_nga',    IM = [-1 0 0.01 0.02 0.03 0.04 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
    case 'as1997h',                    IM = [0.01 0.02 0.03 0.04 0.05 0.06 0.075 0.09 0.1 0.12 0.15 0.17 0.2 0.24 0.3 0.36 0.4 0.46 0.5 0.6 0.75 0.85 1 1.5 2 3 4 5];
    case 'campbell1997h',              IM = [0.05 0.075 0.10 0.15 0.20 0.30 0.50 0.75 1.00 1.50 2.00 3.00 4.00];
    case 'i_2014_nga',                 IM = [0 0.01	0.02	0.03	0.05	0.075	0.1	0.15	0.2	0.25	0.3	0.4	0.5	0.75	1	1.5	2	3	4	5	7.5	10];
    case 'cy_2014_nga',                IM = [-1 0 0.01 0.02 0.03 0.04 0.05 0.075 0.1 0.12 0.15 0.17 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
    case 'bssa_2014_nga',              IM = [-1 0 0.01 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
    case 'cb_2014_nga',                IM = [-1 0 0.010 0.020 0.030 0.050 0.075 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.75 1.0 1.5 2.0 3.0 4.0 5.0 7.5 10];
    case 'ask_2014_nga',               IM = [-1 0 0.01 0.02	0.03	0.05	0.075	0.1	0.15	0.2	0.25	0.3	0.4	0.5	0.75	1	1.5	2	3	4	5	6	7.5	10];
    
        
    case 'dw12',                       IM = -4;
    case 'fg15',                       IM = [-5 -4];
    case 'bta03',                      IM = -5;
    case 'bu17',                       IM = [-6 -5 -4.2 -4.1 -4];
    case 'cb19',                       IM = [-5 -4];
    case 'km06',                       IM = -4.1;
        
    
    case 'ma19',                       IM = -4;
    case 'condsa',                     IM = 1;
    case 'condpgv',                    IM = -1;
    case 'macedo2019',                 IM = -5;
    case 'cav_temp',                   IM = -4;
    case 'vgi_temp',                   IM = -6;
    case 'pce_nga',                    IM = [0.001 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 6 7 8 10];
    case 'pce_bchydro',                IM = [0.01 0.02 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.75 1 1.5 2 2.5 3];
    case 'udm',                        IM = [];
    case 'franky',                     IM = [];
end

if nargout>=2
    switch lower(model)
        case 'youngs1997',                 Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'atkinsonboore2003',          Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'zhao2006',                   Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'mcverry2006',                Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'bchydro2012',                Rmetric=[1 1 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'arteta2018',                 Rmetric=[0 1 0 0 0 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'montalvabastias2017',        Rmetric=[1 1 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'siberrisk2019',              Rmetric=[1 1 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'idini2016',                  Rmetric=[1 1 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'contrerasboroschek2012',     Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'garcia2005',                 Rmetric=[1 1 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'jaimes2006',                 Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'jaimes2015',                 Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'jaimes2016',                 Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'garciajaimes2017',           Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'bernal2014',                 Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';    
        case 'sadigh1997',                 Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'idriss2008_nga',             Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'chiouyoungs2008_nga',        Rmetric=[1 0 1 0 0 1 0 0 1 0 0];  Residuals = 'lognormal';
        case 'booreatkinson_2008_nga',     Rmetric=[0 0 1 0 0 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'campbellbozorgnia_2008_nga', Rmetric=[1 0 1 0 0 0 0 0 1 0 0];  Residuals = 'lognormal';
        case 'abrahamsonsilva2008_nga',    Rmetric=[1 0 1 0 0 1 0 0 1 0 0];  Residuals = 'lognormal';
        case 'as1997h',                    Rmetric=[1 0 0 0 0 0 0 1 0 0 0];  Residuals = 'lognormal';
        case 'campbell1997h',              Rmetric=[0 0 0 0 1 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'i_2014_nga',                 Rmetric=[1 0 0 0 0 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'cy_2014_nga',                Rmetric=[1 0 1 0 0 1 0 0 1 0 0];  Residuals = 'lognormal';
        case 'bssa_2014_nga',              Rmetric=[0 0 1 0 0 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'cb_2014_nga',                Rmetric=[1 0 1 0 0 1 0 1 1 0 1];  Residuals = 'lognormal';
        case 'ask_2014_nga',               Rmetric=[1 0 1 0 0 1 1 0 1 0 0];  Residuals = 'lognormal';
        case 'dw12'        ,               Rmetric=[1 0 0 0 0 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'condsa',                     Rmetric=[0 0 0 0 0 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'condpgv',                    Rmetric=[0 0 0 0 0 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'macedo2019',                 Rmetric=[1 0 0 0 0 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'pce_nga',                    Rmetric=[1 0 1 0 0 1 1 0 1 0 0];  Residuals = 'lognormal';
        case 'pce_bchydro',                Rmetric=[1 0 0 0 0 0 0 0 0 0 0];  Residuals = 'lognormal';
        case 'udm',                        Rmetric=[];                       Residuals = '';
        case 'franky',                     Rmetric=[];                       Residuals = '';            
    end
end

