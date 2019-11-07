function [param,rate]=mGMPEassembleLine(r0,source,Rmetric,ellipsoid)

geom = source.geom;
mscl = source.mscl;
gmpe = source.gmpe;
rupt = source.rupt;

M         = mscl.M;
nM        = size(M,1);
rf        = geom.hypm;
nR        = size(rf,1);
[iR,iM]   = meshgrid(1:nR,1:nM);
M         = M(iM(:));
rf        = rf(iR(:),:);
rateM     = mscl.dPm(iM(:));
rateR     = geom.aream(iR(:))/geom.Area;
rate      = rateM.*rateR/(rateM'*rateR);
rupArea   = zeros(size(M));
n         = [];

if Rmetric(1), rrup  = dist_rrup(r0,rf,rupArea,n); end
if Rmetric(2), rhyp  = dist_rhyp(r0,rf); end
if Rmetric(8), zhyp  = dist_zhyp(r0,rf,ellipsoid); end


%% GMM Parameters
usp      = source.gmpe.usp;
switch source.gmpe.type
    case 'regular', str_test = func2str(gmpe.handle);
    case 'cond',    str_test = func2str(gmpe.cond.conditioning);
    case 'udm' ,    str_test = 'udm';
    case 'pce' ,    str_test = func2str(gmpe.handle);
end

switch str_test
    case 'Arteta2018',             param   = {M,rhyp,usp.media,usp.region};
    case 'Youngs1997',             param   = {M,rrup,zhyp,usp.mechanism,usp.media};
    case 'AtkinsonBoore2003',      param   = {M,rrup,zhyp,usp.mechanism,usp.media,usp.region};
    case 'Zhao2006',               param   = {M,rrup,zhyp,usp.mechanism,usp.Vs30};
    case 'Mcverry2006',            param   = {M,rrup,zhyp,usp.mechanism,usp.media,usp.rvol};
    case 'Sadigh1997',             param   = {M,rrup,usp.mechanism,usp.media};
    case 'Bernal2014'
        param   = {M,rrup,zhyp,usp.mechanism};
    case 'ContrerasBoroschek2012', param   = {M,rrup,zhyp,usp.media};
    case 'Garcia2005',             param   = {M,rrup,rhyp,zhyp,usp.direction};
    case 'Jaimes2006',             param   = {M,rrup};
    case 'Jaimes2015',             param   = {M,rrup,usp.station};
    case 'Jaimes2016',             param   = {M,rrup};
    case 'GarciaJaimes2017',       param   = {M,rrup,usp.component};
    case 'Idriss2008_nga',         param   = {M,rrup,usp.mechanism,usp.Vs30};
    case 'AS1997h'
        usp.location = 'footwall';
        param   = {M,rrup,usp.media,usp.mechanism,usp.location,usp.sig};
    case 'BCHydro2012'
        switch usp.mechanism
            case 'interface',    param     = {M,rrup,zhyp,usp.mechanism,usp.region,usp.DeltaC1,usp.Vs30};
            case 'intraslab',    param     = {M,rhyp,zhyp,usp.mechanism,usp.region,usp.DeltaC1,usp.Vs30};
        end
    case 'MontalvaBastias2017'
        switch usp.mechanism
            case 'interface',    param   = {M,rrup,zhyp,usp.mechanism,usp.region,usp.Vs30};
            case 'intraslab',    param   = {M,rhyp,zhyp,usp.mechanism,usp.region,usp.Vs30};
        end
    case 'SiberRisk2019'
        switch usp.mechanism
            case 'interface'
                param   = {M,rrup,zhyp,usp.mechanism,usp.Vs30};
            case 'intraslab'
                param   = {M,rhyp,zhyp,usp.mechanism,usp.Vs30};
        end
    case 'Idini2016'
        switch usp.mechanism
            case 'interface'
                Mcorr = M;
                Mcorr(M<7.7)=-inf;
                rupArea = rupRelation(Mcorr ,0,geom.Area,rupt.RA{1},rupt.RA{2});
                rrup    = dist_rrup(r0,rf,rupArea,n);
                param   = {M,rrup,zhyp,usp.mechanism,usp.spectrum,usp.Vs30};
            case 'intraslab'
                param   = {M,rhyp,zhyp,usp.mechanism,usp.spectrum,usp.Vs30};
        end
    case 'udm'
        var  = gmpe.var;
        txt  = regexp(var.syntax,'\(','split');
        args = regexp(txt{2}(1:end-1),'\,','split');
        args = strtrim(args);
        args(1)  = [];
        param    = cell(1,4+length(args));
        param{1} = str2func(strtrim(txt{1}));
        param{2} = var.vector;
        param{3} = var.units;
        param{4} = var.residuals;
        for cont=1:length(args)
            f = var.(args{cont});
            if strcmpi(f.tag,'magnitude')
                param{4+cont}=M;
            end
            
            if strcmpi(f.tag,'distance')
                fval = find(f.value);
                switch fval
                    case 1 , param{4+cont}=rrup;
                    case 2 , param{4+cont}=rhyp;
                    case 3 , param{4+cont}=rjb;
                    case 4 , param{4+cont}=repi;
                    case 5 , param{4+cont}=rseis;
                    case 6 , param{4+cont}=rx;
                    case 7 , param{4+cont}=ry0;
                    case 8 , param{4+cont}=zhyp;
                    case 9 , param{4+cont}=rztor;
                    case 10, param{4+cont}=rzbor;
                    case 11, param{4+cont}=rzbot;
                end
            end
            
            if strcmpi(f.tag,'param')
                switch f.type
                    case 'string'
                        param{4+cont}=gmpe.usp.(args{cont});
                    case 'double'
                        if isnumeric(gmpe.usp.(args{cont}))
                            param{4+cont}=gmpe.usp.(args{cont});
                        else
                            param{4+cont}=str2double(gmpe.usp.(args{cont}));
                        end
                end
            end
        end
    case 'PCE_nga'
        dip     = geom.dip;
        W       = source.geom.W;
        param={M, rrup, rjb, rx, ry0, ztor, dip, W, usp.mechanism, usp.event, usp.Z10, usp.Vs30, usp.Vs30type, usp.region};
    case 'PCE_bchydro'
        param     = {M,rrup,usp.Vs30};
        
    case 'DW12'
        param = {M,rrup,ups.mechanism,usp.media};
end

if strcmpi(gmpe.type,'cond')
    func = gmpe.cond.conditioning;
    switch usp.mechanism
        case 'interface',mechanism = 1;
        case 'intraslab',mechanism = 2;
    end
    un   = gmpe.cond.saunits;
    param = [{M,func,mechanism,un},param];
end