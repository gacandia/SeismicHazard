function[d,Sadef,Ddef,SMLIB,default_reg,default_cdm]=loadPSDADefaultParam(~,modelcdm)

d     = logsp(1,100,10); % displacement in CM
Sadef = 30; % default number of Sa simulations
Ddef  = 40; % default number of D simulations

% this part needs improvement to account for PSHA with non-Sa GMMs
% default regular displacement models
ME = pshatoolbox_methods(5);
SMLIB(1:0) = struct('id',[],'str',[],'func',[],'isregular',[],'integrator',[],'Safactor',[],'param',[]);
cont = 0;

[~,ind1] = intersect({ME.str},'psda_BMT2017M'); % default subduction
[~,ind2] = intersect({ME.str},'psda_BT2007M');  % default subductio
mth      = ME([ind1,ind2]);       % default for interface and slab sources
default_reg.T3= {'slope1','DEF1','DEF1','DEF2','DEF1',1};
for j=1:2
    cont=cont+1;
    SMLIB(cont).id         = sprintf('DEF%g',cont);
    SMLIB(cont).str        = mth(j).str;
    SMLIB(cont).func       = mth(j).func;
    SMLIB(cont).isregular  = mth(j).isregular;
    SMLIB(cont).integrator = mth(j).integrator;
    SMLIB(cont).primaryIM  = mth(j).primaryIM;
    SMLIB(cont).Safactor   = mth(j).Safactor;
    SMLIB(cont).param      = [];
end

default_reg.Ts_param  = [0.5 0.2 0];            % fundamental site period
default_reg.ky_param  = [0.2 0.2 0];            % slope yield coefficients

% default CDM Displacement models
[~,ind1] = intersect({ME.str},'psda_BT2007_cdm');  % default CDM all sources
mth      = ME(ind1);       % default for interface and slab sources
cont=cont+1;
DEFCDM                 = sprintf('CDM%g',cont);
SMLIB(cont).id         = DEFCDM;
SMLIB(cont).str        = mth.str;
SMLIB(cont).func       = mth.func;
SMLIB(cont).isregular  = mth.isregular;
SMLIB(cont).integrator = mth.integrator;
SMLIB(cont).primaryIM  = mth.primaryIM;
SMLIB(cont).Safactor   = mth.Safactor;


Ts = '0.5, 0.1';
ky = '0.1, 0.3';
if isempty(modelcdm)
    default_cdm = {'aux',Ts,ky,DEFCDM,DEFCDM,DEFCDM,DEFCDM};
else
    default_cdm = {modelcdm(1).id,Ts,ky,DEFCDM,DEFCDM,DEFCDM,DEFCDM};
end




