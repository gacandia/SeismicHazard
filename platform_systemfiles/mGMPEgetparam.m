function [param,val] = mGMPEgetparam(handles) %#ok<*INUSD,*DEFNU>

ch=get(handles.panel2,'children');
ch2=ch(handles.edit);
val=vertcat(ch2.Value);
str=cell(length(ch2),1);
for i=1:length(ch2)
    str{i}=ch2(i).String;
    if val(i)~=0 && size(str{i},1)>1
        str{i}=str{i}{val(i)};
    end
end
val = [val;handles.GMPEselect.Value];
methods = pshatoolbox_methods(1);
val2    = handles.GMPEselect.Value;

switch methods(val2).str
    case 'Youngs1997'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        h         = str2double(str{3});
        mechanism = str{4};
        media     = str{5};
        param     = {M,rrup,h,mechanism,media};
        
    case 'AtkinsonBoore2003'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        h         = str2double(str{3});
        mechanism = str{4};
        media     = str{5};
        region    = str{6};
        param     = {M,rrup,h,mechanism,media,region};
        
    case 'Zhao2006'
        M         = str2double(str{1});
        R         = str2double(str{2});
        h         = str2double(str{3});
        mechanism = str{4};
        Vs30      = str2double(str{5});
        param     = {M,R,h,mechanism,Vs30};
        
    case 'Mcverry2006'
        M         = str2double(str{1});
        R         = str2double(str{2});
        Hc        = str2double(str{3});
        mechanism = str{4};
        media     = str{5};
        rvol      = str2double(str{6});
        param     = {M,R,Hc,mechanism,media,rvol};
        
    case 'ContrerasBoroschek2012'
        M         = str2double(str{1});
        R         = str2double(str{2});
        h         = str2double(str{3});
        media     = str{4};
        param     = {M,R,h,media};
        
    case 'BCHydro2012'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        h         = str2double(str{3});
        mechanism = str{4};
        region    = str{5};
        DeltaC1   = str{6};
        Vs30      = str2double(str{7});
        param     = {M,rrup,h,mechanism,region,DeltaC1,Vs30};
        
    case 'Arteta2018'
        M         = str2double(str{1});
        rhyp      = str2double(str{2});
        media     = str{3};
        region    = str{4};
        param     = {M,rhyp,media,region};
        
    case 'Idini2016'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        h         = str2double(str{3});
        mechanism = str{4};
        spectrum  = str{5};
        Vs30      = str2double(str(6));
        param     = {M,rrup,h,mechanism,spectrum,Vs30};
        
    case 'MontalvaBastias2017'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        h         = str2double(str{3});
        mechanism = str{4};
        region    = str{5};
        Vs30      = str2double(str{6});
        param     = {M,rrup,h,mechanism,region,Vs30};
        
    case 'SiberRisk2019'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        h         = str2double(str{3});
        mechanism = str{4};
        Vs30      = str2double(str{5});
        param     = {M,rrup,h,mechanism,Vs30};
        
    case 'Garcia2005'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        rhyp      = str2double(str{3});
        H         = str2double(str{4});
        Direction = str{5};
        param     = {M,rrup,rhyp,H,Direction};
        
    case 'Jaimes2006'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        param     = {M,rrup};
        
    case 'Jaimes2015'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        station   = str{3};
        param     = {M,rrup,station};
        
    case 'Jaimes2016'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        param     = {M,rrup};
        
    case 'GarciaJaimes2017'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        component = str{3};
        param     = {M,rrup,component};
        
    case 'Bernal2014'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        zhyp      = str2double(str{3});
        mechanism = str{4};
        param     = {M,rrup,zhyp,mechanism};
        
    case 'Sadigh1997'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        mechanism = str{3};
        media     = str{4};
        param     = {M,rrup,mechanism,media};
        
    case 'Idriss2008_nga'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        mechanism = str{3};
        Vs30      = str2double(str{4});
        param     = {M,rrup,mechanism,Vs30};
        
    case 'ChiouYoungs2008_nga'
        M      = str2double(str{1});
        rrup   = str2double(str{2});
        rjb    = str2double(str{3});
        rx     = str2double(str{4});
        ztor   = str2double(str{5});
        dip    = str2double(str{6});
        if strcmp(str{7},'unk')
            Z10   = Z10_default_AS08_NGA(1100);
        else
            Z10   = str2double(str{7});
        end
        
        mechanism = str{8};
        event     = str{9};
        Vs30      = str2double(str{10});
        Vs30type  = str{11};
        param  = {M, rrup, rjb, rx, ztor, dip, Z10, mechanism, event, Vs30, Vs30type};
        
    case 'BooreAtkinson_2008_nga'
        M      = str2double(str{1});
        Rjb    = str2double(str{2});
        mechanism =str{3};
        Vs30   = str2double(str{4});
        param  = {M, Rjb, mechanism, Vs30};
        
    case 'CampbellBozorgnia_2008_nga'
        M      = str2double(str{1});
        rrup   = str2double(str{2});
        rjb    = str2double(str{3});
        ztor   = str2double(str{4});
        dip    = str2double(str{5});
        mechanism =str{6};
        Vs30   = str2double(str{7});
        Z25    = str2double(str{8});
        sigmatype= str{9};
        param  = {M, rrup, rjb, ztor, dip, mechanism, Vs30, Z25, sigmatype};
        
    case 'AbrahamsonSilva2008_nga'
        M     = str2double(str{1});
        rrup  = str2double(str{2});
        rjb   = str2double(str{3});
        rx    = str2double(str{4});
        ztor  = str2double(str{5});
        dip   = str2double(str{6});
        W     = str2double(str{7});
        
        if strcmp(str{8},'unk')
            Z10   = Z10_default_AS08_NGA(1100);
        else
            Z10   = str2double(str{8});
        end
        Vs30  = str2double(str{9});
        mechanism = str{10};
        event     = str{11};
        Vs30type  = str{12};
        param={M, rrup, rjb, rx, ztor,dip, W, Z10, Vs30,mechanism, event, Vs30type};
        
    case 'AS1997h'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        media     = str{3};
        mechanism = str{4};
        location  = str{5};
        sig       = str{6};
        param={M, rrup, media, mechanism, location, sig};
        
    case 'Campbell1997h'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        media     = str{3};
        mechanism = str{4};
        brdepth   = str2double(str{5});
        sig       = str{7};
        param={M, rrup, media, mechanism, brdepth, sig};
        
    case 'I_2014_nga'
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        mechanism = str{3};
        Vs30      = str2double(str{4});
        param     = {M,rrup,mechanism,Vs30};
        
    case 'CY_2014_nga'
        %M, Rup, Rjb, Rx, Ztor, dip, mechanism, Z10, Vs30, Vs30type, region
        M         = str2double(str{1});
        rrup      = str2double(str{2});
        rjb       = str2double(str{3});
        rx        = str2double(str{4});
        ztor      = str2double(str{5});
        dip       = str2double(str{6});
        mechanism = str{7};
        if strcmp(str{8},'unk')
            Z10 = 'unk';
        else
            Z10 = str2double(str{8});
        end
        Vs30      = str2double(str{9});
        Vs30type  = str{10};
        region    = str{11};
        param     = {M, rrup, rjb, rx, ztor, dip, mechanism, Z10, Vs30, Vs30type, region};
        
    case 'CB_2014_nga'
        %M, Rrup, Rjb, Rx, W, Ztor, Zbot, Zhyp, delta, mechanism, Fhw, Vs30, Z25, region
        M      = str2double(str{1});
        Rrup   = str2double(str{2});
        Rjb    = str2double(str{3});
        Rx     = str2double(str{4});
        W      = str2double(str{5});
        Ztor   = str2double(str{6});
        Zbot   = str2double(str{7});
        delta  = str2double(str{8});
        mechanism = str{9};
        HWeffect = str{10};
        Vs30   = str2double(str{11});
        Z25    = str2double(str{12});
        Zhyp   = str2double(str{13});
        region= str{14};
        param  = {M, Rrup, Rjb, Rx, W, Ztor, Zbot, delta, mechanism, HWeffect, Vs30, Z25, Zhyp, region};
        
    case 'BSSA_2014_nga'
        %M, rjb, mechanism, reg, BasinDepth, Vs30
        M          = str2double(str{1});
        Rjb        = str2double(str{2});
        mechanism  = str{3};
        region     = str{4};
        if strcmp(str{5},'unk')
            BasinDepth = 'unk';
        else
            BasinDepth = str2double(str{5});
        end
        Vs30       = str2double(str{6});
        param      = {M, Rjb, mechanism, region, BasinDepth, Vs30};
        
    case 'ASK_2014_nga'
        %M, Rrup, Rjb, Rx, Ry0, Ztor, delta, mechanism, event, W, Z10, Vs30, Vs30type, reg
        M      = str2double(str{1});
        Rrup   = str2double(str{2});
        Rjb    = str2double(str{3});
        Rx     = str2double(str{4});
        Ry0    = str2double(str{5});
        Ztor   = str2double(str{6});
        delta  = str2double(str{7});
        W      = str2double(str{8});
        mechanism = str{9};
        event     = str{10};
        if strcmp(str{11},'unk')
            Z10   = 'unk';
        else
            Z10   = str2double(str{11});
        end
        Vs30   = str2double(str{12});
        Vs30type = str{13};
        region   = str{14};
        param    = {M, Rrup, Rjb, Rx, Ry0, Ztor, delta, W, mechanism, event, Z10, Vs30, Vs30type, region};
        
    case 'DW12'
        M      = str2double(str{1});
        Rrup   = str2double(str{2});
        mechanism = str{3};
        media     = str{4};
        param    = {M, Rrup, mechanism, media};
        
    case 'FG15'
        %
        M      = str2double(str{1});
        Rrup   = str2double(str{2});
        H      = str2double(str{3});
        mechanism = str{4};
        style    = str{5};
        Vs30   = str2double(str{6});
        region = str{7};
        model  = str{8};
        param  = {M,Rrup,H,mechanism,style,Vs30,region,model};
        
    case 'udm'
        param = cell(0,0);
end
