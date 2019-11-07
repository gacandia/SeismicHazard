function[pdef]=deflate_rectangle(source,DataR)

rupt   = source.rupt;
p      = source.geom.p(:,1:2);
M      = DataR{3};
model  = rupt.RA{1};
param  = rupt.RA{2};
aratio = rupt.aratio;
RA     = rupRelation(M,0,Inf,model,param);
RL     = sqrt(RA*aratio);
RW     = sqrt(RA/aratio);
pdef   = p;
pdef(:,1)=p(:,1)-RL/2*sign(p(:,1));
pdef(:,2)=p(:,2)-RW/2*sign(p(:,2));

