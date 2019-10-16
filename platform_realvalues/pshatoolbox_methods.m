function ME = pshatoolbox_methods(group,varargin)

% regular = typical GMPEs
% cond    = conditional GMPE
% udm     = user defined models, GMPEs defined in user specified m-files
% pce     = polynomial chaos expansion GMPE

% ground motion models (gmpe)
if group ==1
    i = 0;
    ME(1:28,1)=struct('label',[],'str',[],'func',[],'type',[],'ref',[]);
    i=i+1; ME(i).label = 'Youngs et al. 1997';           ME(i).func = @Youngs1997;                 ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/gssrl.68.1.58';
    i=i+1; ME(i).label = 'Atkinson & Boore, 2003';       ME(i).func = @AtkinsonBoore2003;          ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/0120020156';
    i=i+1; ME(i).label = 'Zhao et al. 2006';             ME(i).func = @Zhao2006;                   ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/0120050122';
    i=i+1; ME(i).label = 'McVerry et al. 2006';          ME(i).func = @Mcverry2006;                ME(i).type='regular';  ME(i).ref='http://www.nzsee.org.nz/db/Bulletin/Archive/39(1)0001.pdf';
    i=i+1; ME(i).label = 'Boroschek et al. 2012';        ME(i).func = @ContrerasBoroschek2012;     ME(i).type='regular';  ME(i).ref='https://nisee.berkeley.edu/elibrary/files/documents/elib/www/documents/201204/PISELL/boroschek-maule-eq.pdf';
    i=i+1; ME(i).label = 'Abrahamson et al. 2016';       ME(i).func = @BCHydro2012;                ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/051712EQS188MR';
    i=i+1; ME(i).label = 'Arteta et al. 2018';           ME(i).func = @Arteta2018;                 ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/102116EQS176M';
    i=i+1; ME(i).label = 'Idini et al. 2016';            ME(i).func = @Idini2016;                  ME(i).type='regular';  ME(i).ref='https://doi.org/10.1007/s10518-016-0050-1';
    i=i+1; ME(i).label = 'Montalva et al. 2017';         ME(i).func = @MontalvaBastias2017;        ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/0120160221';
    i=i+1; ME(i).label = 'SIBER-RISK 2019';              ME(i).func = @SiberRisk2019;              ME(i).type='regular';  ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'Garcia et al. 2005';           ME(i).func = @Garcia2005;                 ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/0120050072';
    i=i+1; ME(i).label = 'Jaimes et al. 2006';           ME(i).func = @Jaimes2006;                 ME(i).type='regular';  ME(i).ref='https://doi.org/10.1080/13632460609350622';
    i=i+1; ME(i).label = 'Jaimes et al. 2015';           ME(i).func = @Jaimes2015;                 ME(i).type='regular';  ME(i).ref='https://doi.org/10.1080/13632469.2015.1025926';
    i=i+1; ME(i).label = 'Jaimes et al. 2016';           ME(i).func = @Jaimes2016;                 ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/0120150283';
    i=i+1; ME(i).label = 'Garcia-Soto Jaimes 2017';      ME(i).func = @GarciaJaimes2017;           ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/0120160273';
    i=i+1; ME(i).label = 'Bernal et al. 2014';           ME(i).func = @Bernal2014;                 ME(i).type='regular';  ME(i).ref='https://doi.org/10.13140/2.1.2693.6641';
    i=i+1; ME(i).label = 'Sadigh et al. 1997';           ME(i).func = @Sadigh1997;                 ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/gssrl.68.1.180';
    i=i+1; ME(i).label = 'Idriss 2008 - NGA';            ME(i).func = @Idriss2008_nga;             ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/1.2924362';
    i=i+1; ME(i).label = 'Chiou Youngs 2008 - NGA';      ME(i).func = @ChiouYoungs2008_nga;        ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/1.2894832';
    i=i+1; ME(i).label = 'Boore Atkinson 2008 - NGA';    ME(i).func = @BooreAtkinson_2008_nga;     ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/1.2830434';
    i=i+1; ME(i).label = 'Campbell Bozorgnia 2008 - NGA';ME(i).func = @CampbellBozorgnia_2008_nga; ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/1.2857546';
    i=i+1; ME(i).label = 'Abrahamson Silva 2008 - NGA';  ME(i).func = @AbrahamsonSilva2008_nga;    ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/1.2924360';
    i=i+1; ME(i).label = 'Abrahamson Silva 1997 (Horz)'; ME(i).func = @AS1997h;                    ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/gssrl.68.1.94';
    i=i+1; ME(i).label = 'Campbell 1997 (Horz)';         ME(i).func = @Campbell1997h;              ME(i).type='regular';  ME(i).ref='https://doi.org/10.1785/gssrl.68.1.154';
    i=i+1; ME(i).label = 'Idriss 2014 - NGAW2';          ME(i).func = @I_2014_nga;                 ME(i).type='regular';  ME(i).ref ='https://doi.org/10.1193/070613EQS195M';
    i=i+1; ME(i).label = 'CY 2014 - NGAW2';              ME(i).func = @CY_2014_nga;                ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/072813eqs219m';
    i=i+1; ME(i).label = 'CB 2014 - NGAW2';              ME(i).func = @CB_2014_nga;                ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/062913eqs175m';
    i=i+1; ME(i).label = 'BSSA 2014 - NGAW2';            ME(i).func = @BSSA_2014_nga;              ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/070113eqs184m';
    i=i+1; ME(i).label = 'ASK 2014 - NGAW2';             ME(i).func = @ASK_2014_nga;               ME(i).type='regular';  ME(i).ref='https://doi.org/10.1193/070913eqs198m';
    i=i+1; ME(i).label = 'Conditional Sa';               ME(i).func = @condSa;                     ME(i).type='cond';     ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'Conditional PGV (CM2019)';     ME(i).func = @condPGV;                    ME(i).type='cond';     ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'Conditional Ia (Macedo2019)';  ME(i).func = @Macedo2019;                 ME(i).type='cond';     ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'User Defined Model';           ME(i).func = @udm;                        ME(i).type='udm';      ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'PCE NGA';                      ME(i).func = @PCE_nga;                    ME(i).type='pce';      ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'PCE BCHydro';                  ME(i).func = @PCE_bchydro;                ME(i).type='pce';      ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'Franky';                       ME(i).func = @franky;                     ME(i).type='frn';      ME(i).ref='www.google.com';
end

% magnitude scaling models
if group == 2
    i = 0;
    ME(1:4,1)=struct('label',[],'str',[],'func',[],'ref',[]);
    i=i+1;ME(i).label = 'Delta';                   ME(i).func = @delta;
    i=i+1;ME(i).label = 'Truncated Exponential';   ME(i).func = @truncexp;
    i=i+1;ME(i).label = 'Truncated Normal';        ME(i).func = @truncnorm;
    i=i+1;ME(i).label = 'Characteristic';          ME(i).func = @youngscoppersmith;
end

% spatial correlation models
if group ==3
    ME(1:4,1)=struct('label',[],'str',[],'func',[],'ref',[]);
    i = 0;
    i=i+1;ME(i).label = 'none';                              ME(i).func= @none_spatial;     ME(i).ref='www.google.com';
    i=i+1;ME(i).label = 'Jayaram N. and Baker J.W. (2009)';  ME(i).func= @JB_spatial_2009;  ME(i).ref='https://doi.org/10.1002/eqe.922';
    i=i+1;ME(i).label = 'Loth, C., and Baker, J. W. (2013)'; ME(i).func= @LB_spatial_2013;  ME(i).ref='https://doi.org/10.1002/eqe.2212';
    i=i+1;ME(i).label = 'Candia et al. (2019)';              ME(i).func= @SR_spatial_2019;  ME(i).ref='www.google.com';
end

% interperiod correlation models
if group == 4
    ME(1:13,1)=struct('label',[],'str',[],'func',[],'ref',[]);
    i = 0;
    i=i+1; ME(i).label = 'none';                     ME(i).func = @none_spectral;               ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'Baker & Cornell 2006';     ME(i).func = @BC_spectral_2006;            ME(i).ref='https://doi.org/10.1785/0120050060';
    i=i+1; ME(i).label = 'Baker & Jayaram 2008';     ME(i).func = @BJ_spectral_2008;            ME(i).ref='https://doi.org/10.1193/1.2857544';
    i=i+1; ME(i).label = 'Jayaram et al. 2011';      ME(i).func = @JB_spectral_2011;            ME(i).ref='https://doi.org/10.12989/eas.2011.2.4.357';
    i=i+1; ME(i).label = 'Cimellaro 2013';           ME(i).func = @Cimellaro_2013;              ME(i).ref='https://doi.org/10.1002/eqe.2248';
    i=i+1; ME(i).label = 'ASK2014 - NGA West2';      ME(i).func = @ASK14_spectral_2014;         ME(i).ref='https://doi.org/10.1193/070913eqs198m';
    i=i+1; ME(i).label = 'Abrahamanson et al. 2016'; ME(i).func = @BCHhydro_spectral_2016;      ME(i).ref='https://doi.org/10.1193/051712EQS188MR';
    i=i+1; ME(i).label = 'Baker & Bradley 2017';     ME(i).func = @BakerBradley_spectral_2017;  ME(i).ref='https://doi.org/10.1193/060716EQS095M';
    i=i+1; ME(i).label = 'Jaimes & Candia 2019';     ME(i).func = @JC_spectral_2018;            ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'Candia et al. 2019';       ME(i).func = @SR_spectral_2019;            ME(i).ref='www.google.com';
    i=i+1; ME(i).label = 'Goda & Atkinson 2009';     ME(i).func = @GodaAtkinson_spectral_2009;  ME(i).ref='https://doi.org/10.1785/0120090007';
    i=i+1; ME(i).label = 'Akkar & Sandikkaya 2014';  ME(i).func = @Akkar_spectral_2014;         ME(i).ref='https://doi.org/10.1007/s10518-013-9537-1';
    i=i+1; ME(i).label = 'Ji et al. 2017';           ME(i).func = @Ji_spectral_2017;            ME(i).ref='https://doi.org/10.1785/0120160291';
end

% psda
if group == 5
    ME(1:11,1)=struct('label',[],'str',[],'isregular',[],'func',[],'integrator',[],'primaryIM',[],'Safactor',[],'ref',[]);
    i=0;
    % subduction
    i=i+1;ME(i).label = 'BMT 2017 Sa(M)';      ME(i).func = @psda_BMT2017M;     ME(i).mechanism = 'subduction'; ME(i).integrator=1;  ME(i).primaryIM='Sa(1.5Ts)';     ME(i).isregular=true;  ME(i).ref = 'https://doi.org/10.1061/(ASCE)GT.1943-5606.0001833';
    i=i+1;ME(i).label = 'BMT 2017 (PCE-M)';    ME(i).func = @psda_BMT2017_cdmM; ME(i).mechanism = 'subduction'; ME(i).integrator=6;  ME(i).primaryIM='Sa(1.5Ts)';     ME(i).isregular=false; ME(i).ref = 'https://doi.org/10.1061/(ASCE)GT.1943-5606.0001833';
    
    % shallow crustal (bray et al)
    i=i+1;ME(i).label = 'BT 2007 Sa';          ME(i).func = @psda_BT2007;       ME(i).mechanism = 'crustal'; ME(i).integrator=2;  ME(i).primaryIM='Sa(1.5Ts)';     ME(i).isregular=true;  ME(i).ref = 'https://doi.org/10.1061/(ASCE)1090-0241(2007)133:4(381)';
    i=i+1;ME(i).label = 'BT 2007 Sa(M)';       ME(i).func = @psda_BT2007M;      ME(i).mechanism = 'crustal'; ME(i).integrator=1;  ME(i).primaryIM='Sa(1.5Ts)';     ME(i).isregular=true;  ME(i).ref = 'https://doi.org/10.1061/(ASCE)1090-0241(2007)133:4(381)';
    i=i+1;ME(i).label = 'BT 2007 (PCE)';       ME(i).func = @psda_BT2007_cdm;   ME(i).mechanism = 'crustal'; ME(i).integrator=5;  ME(i).primaryIM='Sa(1.5Ts)';     ME(i).isregular=false; ME(i).ref = 'https://doi.org/10.1061/(ASCE)1090-0241(2007)133:4(381)';
    i=i+1;ME(i).label = 'BT 2007 (PCE-M)';     ME(i).func = @psda_BT2007_cdmM;  ME(i).mechanism = 'crustal'; ME(i).integrator=6;  ME(i).primaryIM='Sa(1.5Ts)';     ME(i).isregular=false; ME(i).ref = 'https://doi.org/10.1061/(ASCE)1090-0241(2007)133:4(381)';
    i=i+1;ME(i).label = 'BM 2019 NonNF (M)';   ME(i).func = @psda_BM2019M;      ME(i).mechanism = 'crustal'; ME(i).integrator=1;  ME(i).primaryIM='Sa(1.3Ts)';     ME(i).isregular=true;  ME(i).ref = 'https://www.ce.berkeley.edu/people/faculty/bray/research';
    %i=i+1;ME(i).label = 'BM 2019 NF';         ME(i).func = @psda_BM2019_NF;    ME(i).integrator=7;  ME(i).primaryIM='PGV-Sa(1.3Ts)'; ME(i).isregular=true;  ME(i).ref = 'http://www.google.com';
    
    % shallow crustal (other)
    i=i+1;ME(i).label = 'Jibson  2007 (M)';    ME(i).func = @psda_J07M;         ME(i).mechanism = 'crustal'; ME(i).integrator=1;  ME(i).primaryIM='PGA';           ME(i).isregular=true;  ME(i).ref = 'https://www.sciencedirect.com/science/article/pii/S0013795207000300?via%3Dihub';
    i=i+1;ME(i).label = 'Jibson  2007 Ia';     ME(i).func = @psda_J07Ia;        ME(i).mechanism = 'crustal'; ME(i).integrator=2;  ME(i).primaryIM='AI';            ME(i).isregular=true;  ME(i).ref = 'https://www.sciencedirect.com/science/article/pii/S0013795207000300?via%3Dihub';
    i=i+1;ME(i).label = 'RA 2011 (Rigid)';     ME(i).func = @psda_RA2011R;      ME(i).mechanism = 'crustal'; ME(i).integrator=3;  ME(i).primaryIM='PGV-PGA';       ME(i).isregular=true;  ME(i).ref = 'https://www.sciencedirect.com/science/article/pii/S0013795210002553';
    i=i+1;ME(i).label = 'RA 2011 (Flexible)';  ME(i).func = @psda_RA2011F;      ME(i).mechanism = 'crustal'; ME(i).integrator=4;  ME(i).primaryIM='PGV-PGA';       ME(i).isregular=true;  ME(i).ref = 'https://www.sciencedirect.com/science/article/pii/S0013795210002553';
    i=i+1;ME(i).label = 'RS 2009 (Scalar-M)';  ME(i).func = @psda_RS09M;        ME(i).mechanism = 'crustal'; ME(i).integrator=1;  ME(i).primaryIM='PGA';           ME(i).isregular=true;  ME(i).ref = 'http://www.nzsee.org.nz/db/Bulletin/Archive/42(1)0018.pdf';
    i=i+1;ME(i).label = 'RS 2009 (Vector)';    ME(i).func = @psda_RS09V;        ME(i).mechanism = 'crustal'; ME(i).integrator=4;  ME(i).primaryIM='PGV-PGA';       ME(i).isregular=true;  ME(i).ref = 'http://www.nzsee.org.nz/db/Bulletin/Archive/42(1)0018.pdf';    
    i=i+1;ME(i).label = 'AM 1988';             ME(i).func = @psda_AM1988;       ME(i).mechanism = 'crustal'; ME(i).integrator=2;  ME(i).primaryIM='PGA';           ME(i).isregular=true;  ME(i).ref = 'https://doi.org/10.1002/eqe.4290160704';
    
    
    for j=1:length(ME)
        ME(j).Safactor=str2IM(regexp(ME(j).primaryIM,'\-','split'));
        ME(j).Safactor=ME(j).Safactor(:)';
    end
    
end

for i=1:length(ME)
    ME(i).str=func2str(ME(i).func);
end


%% selective method
if nargin==2
    val = varargin{1};
    ME = ME(val);
end