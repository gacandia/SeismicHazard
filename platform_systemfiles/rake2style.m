function[style]=rake2style(rake,gmm)
% clc
% clearvars
% rake = -90; %normal
% rake = 90; %reverse
% rake=180; %strike slip

% style of faulting from rake angle
% positive rake
if and(0<=rake,rake<30) || and(150<=rake,rake<=180) || and(rake<0,-30<=rake) || and(rake<-150,-180<=rake)
    STYLE='strike-slip';
end

if and(30<=rake,rake<60) || and(120<=rake,rake<150)
    STYLE='reverse/oblique';
end

if and(60<=rake,rake<120)
    STYLE='reverse';
end

if and(-60<=rake,rake<-30) || and(-150<=rake,rake<-120)
    STYLE='normal/oblique';
end

if and(-120<=rake,rake<-60)
    STYLE='normal';
end
STYLE

%% style of faulting for GMM input

switch gmm
    case 'zhao2006'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
        
    case 'mcverry2006'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
        
    case 'sadigh1997'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
        
    case 'idriss2008_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
        
    case 'chiouyoungs2008_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'booreatkinson_2008_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'campbellbozorgnia_2008_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
        
    case 'abrahamsonsilva2008_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'as1997h'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'campbell1997h'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'i_2014_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'cy_2014_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'bssa_2014_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'cb_2014_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'ask_2014_nga'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
    case 'dw12'
        switch STYLE
            case 'strike-slip'     , style='';
            case 'reverse/oblique' , style='';
            case 'reverse'         , style='';
            case 'normal/oblique'  , style='';
            case 'normal'          , style='';
        end
end
