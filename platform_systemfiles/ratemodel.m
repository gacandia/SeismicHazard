function[hazard]=ratemodel(model,prob,twin)

switch model
    case 'poisson' , hazard = -log(1-prob)/twin;
    case 'binomial' %hazard = -log(1-prob)/twin;
    case 'renewal'  %hazard = -log(1-prob)/twin;
end