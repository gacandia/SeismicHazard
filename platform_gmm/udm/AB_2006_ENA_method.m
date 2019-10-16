function var=AB_2006_ENA_method

% Rmetric    = [Rrup Rhyp H Rjb Rx Ztor Zseis Ry0 zhyp ztor zbor zbot]
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


var.syntax    = 'AB_2006_ENA(T, M,Rcd, stress, Vs30)';
var.vector    = false;
var.residuals = 'lognormal';
var.IM        = struct('control' , 'system' , 'type' , 'double' , 'tag' , 'IM',         'value' , [-1 0.025 0.031 0.04 0.05 0.063 0.079 0.1 0.125 0.158 0.199 0.251 0.315 0.397 0.5 0.629 0.794 1 1.25 1.59 2 2.5 3.13 4 5]);
var.M         = struct('control' , 'system' , 'type' , 'double' , 'tag' , 'Magnitude',  'value' , []);
var.Rcd       = struct('control' , 'system' , 'type' , 'double' , 'tag' , 'Distance',   'value' , [1 0 0 0 0 0 0 0 0 0 0]);
var.stress    = struct('control' , 'user'   , 'type' , 'double' , 'tag' , 'Param',      'value' , []);
var.Vs30      = struct('control' , 'user'   , 'type' , 'double' , 'tag' , 'Param',      'value' , []);


