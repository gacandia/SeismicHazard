function[Nsource]=getNsource(model)
Nsource   = 0;
for i=1:length(model)
    Nsource = max(Nsource,length(model(i).source));
end