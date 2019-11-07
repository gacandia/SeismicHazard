function[pdef]=deflatep(p,R)
% clear all
% close all
% load mydata2

[lat,lon]=reducem(p(:,1),p(:,2),1);
p=[lat,lon];

pdef = p;
for i=1:5
    pdef = reduceGG(pdef,0.2*R);
end


% figure(1)

% clf
% hold on
% plot(p([1:end,1],1),p([1:end,1],2),'b.-')
% plot(pdef([1:end,1],1),pdef([1:end,1],2),'r.-')
% % % N1 = size(p,1); N2 = size(pdef,1);
% % % text(   p(1:N1,1),   p(1:N1,2),num2cell(1:N1))
% % % text(pdef(1:N2,1),pdef(1:N2,2),num2cell(1:N2))
% axis equal
