function var=udmTest_method

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


var.syntax    = 'udmTest(To,M,Rhyp,media,region)';
var.vector    = true;
var.residuals = 'lognormal';
var.IM        = struct('control' , 'system' , 'type' , 'double' , 'tag' , 'IM',         'value' , [0.01 0.02 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.75 1 1.5 2 2.5 3 4 5 6 7.5 10]);
var.M         = struct('control' , 'system' , 'type' , 'double' , 'tag' , 'Magnitude',  'value' , []);
var.Rhyp      = struct('control' , 'system' , 'type' , 'double' , 'tag' , 'Distance',   'value' , [0 1 0 0 0 0 0 0 0 0 0]);
var.media     = struct('control' , 'user'   , 'type' , 'string' , 'tag' , 'Param',      'value' , 'rock ; soil');
var.region    = struct('control' , 'user'   , 'type' , 'string' , 'tag' , 'Param',      'value' , 'forearc ; backarc');


