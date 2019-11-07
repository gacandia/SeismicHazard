function [isregular] = runhazcheck(model)

% Determines the logic tree branches that use the method
% runhazard1 or runhazard1PCE

Nbranches = length(model);
isregular = nan(1,Nbranches);

for i=1:Nbranches
    Nsource = length(model(i).source);
    stype   = cell(Nsource,1);
    for j=1:Nsource
        stype{j}=model(i).source(j).gmpe.type;
    end
    [~,B]=ismember(stype,'pce');
    isregular(i) = all(B==0);
end

