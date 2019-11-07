function[M,dPm]=getMdPm(deagg)

dPm = cell(size(deagg));

for ii=1:length(deagg)
    M    = unique(deagg{ii}(:,1));
    dpm  = zeros(size(M));
    rate = deagg{ii}(:,3);
    for i=1:length(M)
        dpm(i) =sum(rate(deagg{ii}(:,1)==M(i)));
    end
    dpm = dpm/sum(dpm);
    dPm {ii} = dpm;
end
