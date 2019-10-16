function[h]=computeh(site)

X = site(:,1);
Y = site(:,2);
Z = site(:,3);
[XX,YY]= meshgrid(X,Y);
[~,ZZ]= meshgrid(X,Z);
h = ((XX-XX').^2+(YY-YY').^2+(ZZ-ZZ').^2).^0.5;