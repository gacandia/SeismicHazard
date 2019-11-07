function[rate,Y,idx]=dsha_kmeans(handles,optkm)

[rateIS,YIS]=dsha_is(handles);
Nclust  = optkm(1);
Replic  = optkm(2);
stream  = RandStream('mlfg6331_64');  % Random number stream
options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);

[idx,Y] = kmeans(YIS,Nclust,'Options',options,'MaxIter',10000,'Display','final','Replicates',Replic);

rate    = zeros(Nclust,1);
for i=1:Nclust
    rate(i)=sum(rateIS(idx==i));
end
    