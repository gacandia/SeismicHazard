function source=build_empty_source(name)

name                  = lower(name);
source.label          = name;
source.type           = name;
source.mechanism      = name;
source.vertices       = nan(4,3);
source.hickness       = [];
source.gptr           = 1;
source.geom.strike    = [];
source.geom.dip       = [];
source.geom.W         = [];
source.geom.L         = [];
source.geom.Area      = [];
source.geom.p         = nan(4,3);
source.geom.pmean     = nan(1,3);
source.geom.rot       = nan(3,3);
source.geom.spacing   = [];
source.geom.slices    = [];
source.geom.xyzm      = nan(4,3);
source.geom.conn      = [1 2 3 4];
source.geom.aream     = [];
source.geom.hypm      = nan(1,3);
source.geom.normal    = nan(1,3);
source.gmpe.label     = [];
source.gmpe.handle    = @voidgmpe;
source.gmpe.un        = [];
source.gmpe.T         = [];
source.gmpe.usp       = [];
source.gmpe.Rmetric   = [];
source.gmpe.Residuals = [];
source.mscl.source    = name;
source.mscl.handle    = [];
source.mscl.msparam   = [];
source.mscl.M         = [];
source.mscl.dPm       = [];
source.mscl.meanMo    = [];
source.mscl.SlipRate  = [];
source.rupt.id        = name;
source.rupt.type      = [];
source.rupt.spacing   = [];
source.rupt.slices    = [];
source.rupt.taper     = [];
source.rupt.RA        = [];
source.rupt.aratio    = [];