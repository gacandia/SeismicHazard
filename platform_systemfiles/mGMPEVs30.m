function source = mGMPEVs30(source,Vs30)

source.Vs30 = Vs30;
switch source.gmpe.type
    case 'regular'
        str             = func2str(source.gmpe.handle);
        source.gmpe.usp = mGMPEVs30str(source.gmpe.usp,Vs30,str);
    case 'cond'
        str              = func2str(source.gmpe.cond.conditioning);
        source.gmpe.usp  = mGMPEVs30str(source.gmpe.usp,Vs30,str);
    case 'udm'
        str  = 'udm'; % pending
        source.gmpe = mGMPEVs30udm(source.gmpe,Vs30);
    case 'pce'
        str              = func2str(source.gmpe.handle);
        source.gmpe.usp  = mGMPEVs30str(source.gmpe.usp,Vs30,str);
    case 'frn'
        Ndepend = source.gmpe.usp.Ndepend;
        for i=1:Ndepend
            str = sprintf('GMM%i',i);
            if isempty(source.gmpe.usp.(str).cond)
                gmmi = func2str(source.gmpe.usp.(str).handle);
            else
                gmmi = func2str(source.gmpe.usp.(str).cond.conditioning);
            end
            source.gmpe.usp.(str).usp = mGMPEVs30str(source.gmpe.usp.(str).usp,Vs30,gmmi);
        end
end

function usp=mGMPEVs30str(usp,Vs30,str)
switch str
    case 'Youngs1997' % assumptions made
        if Vs30<760 , usp.media='soil';
        else        , usp.media='rock';
        end
        
    case 'AtkinsonBoore2003'
        if  Vs30<180                      ,usp.media='nehrpe';
        elseif and(180<=Vs30,Vs30<=360)   ,usp.media='nehrpd';
        elseif and(360< Vs30,Vs30<=760)   ,usp.media='nehrpc';
        elseif 760<Vs30                   ,usp.media='nehrpb';
        end
        
    case 'Zhao2006'
        usp.Vs30=Vs30;
        
    case 'Mcverry2006' % assumptions made
        % used the NEHRP definition
        if     Vs30<180                  ,usp.media='E';
        elseif and(180<=Vs30,Vs30< 270)  ,usp.media='D';
        elseif and(270<=Vs30,Vs30< 360)  ,usp.media='C';
        elseif and(360<=Vs30,Vs30<1500)  ,usp.media='B';
        elseif 1500<=Vs30                ,usp.media='A';
        end
        
    case 'ContrerasBoroschek2012' % assumptions made
        if Vs30<760 , usp.media='soil';
        else        , usp.media='rock';
        end
        
    case 'BCHydro2012'
        usp.Vs30=Vs30;
        
    case 'Arteta2018'
        if Vs30<760 , usp.media='soil';
        else        , usp.media='rock';
        end
        
    case 'MontalvaBastias2017'
        usp.Vs30=Vs30;
        
    case 'SiberRisk2019'
        usp.Vs30=Vs30;
        
    case 'Sadigh1997'
        if Vs30<760 , usp.media='deepsoil';
        else         , usp.media='rock';
        end
        
    case 'Idini2016'
        usp.Vs30=Vs30;
        
    case 'Idriss2008_nga'
        usp.Vs30=Vs30;
        
    case 'ChiouYoungs2008_nga'
        usp.Vs30=Vs30;
        
    case 'BooreAtkinson_2008_nga'
        usp.Vs30=Vs30;
        
    case 'CampbellBozorgnia_2008_nga'
        usp.Vs30=Vs30;
        
    case 'AbrahamsonSilva2008_nga'
        usp.Vs30=Vs30;
        
    case 'AS1997h'
        if Vs30<760 , usp.media='deepsoil';
        else        , usp.media='rock';
        end
        
    case 'Campbell1997h'
        if     Vs30<760                  , usp.media='soil';
        elseif and(760<=Vs30,Vs30<1500)  , usp.media='softrock';
        end                              , usp.media='hardrock';
        
    case 'I_2014_nga'
        usp.Vs30=Vs30;
        
    case 'CY_2014_nga'
        usp.Vs30=Vs30;
        
    case 'CB_2014_nga'
        usp.Vs30=Vs30;
        
    case 'BSSA_2014_nga'
        usp.Vs30=Vs30;
        
    case 'ASK_2014_nga'
        usp.Vs30=Vs30;
        
    case 'PCE_nga'
        usp.Vs30=Vs30;
        
    case 'PCE_bchydro'
        usp.Vs30=Vs30;
end

function gmpe=mGMPEVs30udm(gmpe,Vs30)

if isfield(gmpe.var,'Vs30')
    gmpe.usp.Vs30 = Vs30;
end

if isfield(gmpe.var,'media')
    val = gmpe.var.media.value;
    val = strtrim(regexp(val,'\;','split'));
    Nlim = length(val);
    for jj=1:Nlim
        line = strtrim(regexp(val{jj},'\ ','split'));
        if eval(line{1})
            gmpe.usp.media = line{2};
        end
    end
end


