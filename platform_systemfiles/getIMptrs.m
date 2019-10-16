function iptrs = getIMptrs(IM,T)

IM    = IM(:)';
iptrs = ones(size(IM));

Nmax = 0;
nT   = length(T);
for i=1:nT
    Nmax=max(Nmax,length(T{i}));
end

Tbin = zeros(nT,Nmax);
for i=1:nT
    ni = length(T{i});
    Tbin(i,1:ni) = T{i};
    if ni<Nmax
        Tbin(i,ni+1:end) = Tbin(i,ni);
    end
end

for i=1:length(IM)
    if IM(i)<0
        disc = min(abs(IM(i)-Tbin),[],2);
        ind  = find(disc==0);
    else
        disc = (IM(i)>=Tbin(:,1)).*(IM(i)<=Tbin(:,end));
        ind  = find(disc==1);
    end
    
    if ~isempty(ind)
        iptrs(i)=ind(1);
    end
end
