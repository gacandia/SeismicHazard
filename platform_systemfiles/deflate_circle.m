function[pdef]=deflate_circle(source,DataR)

p      = source.geom.p(:,1:2);
M      = DataR{3};
model  = source.rupt.RA{1};
param  = source.rupt.RA{2};
A      = rupRelation(M,0,Inf,model,param);
R      = sqrt(A/pi);
pdef   = deflatep(p,R);