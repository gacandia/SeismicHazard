clearvars
clc

%S = shaperead('Model_Mod_Final_Rev_Reservoirs');

G(1:10)=struct('ID','IDtest','Geometry','Point','X',1,'Y',2,'Vs30',760,'To',0.4);
shapewrite(G,'Test');

R = shaperead('Test');