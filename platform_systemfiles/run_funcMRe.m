function handles=run_funcMRe(handles,dg3)

Rbin = handles.Rbin;
Mbin = handles.Mbin;
Ebin = handles.Ebin;
Ebin = Ebin+1e-7;
NR   = size(handles.Rbin,1);
NM   = size(handles.Mbin,1);
NE   = size(handles.Ebin,1);

deagg3 = zeros(NR,NE,NM);
lam3   = sum(dg3(:,5));

for j=1:NM
    deagg3(:,:,j)= deagghazardMRe3(dg3,Mbin(j,:),Rbin,Ebin);
end

deagg3 = deagg3/lam3*100;
updateZValue(handles.b,deagg3);
Zmax = nansum(deagg3,2);
Zmax = max(Zmax(:));
handles.ax1.ZLim=[0,min(ceil(Zmax),100)];

function[deaggIM]=deagghazardMRe3(deagg,Mbin,Rbin,Ebin)

NR = size(Rbin,1); 
NE = size(Ebin,1);
deaggIM = zeros(NR,NE);

M  = deagg(:,1);
R  = deagg(:,2);
e  = deagg(:,4);
dg = deagg(:,5);
M1 = Mbin(1);
M2 = Mbin(2);

for i=1:NR
    R1 = Rbin(i,1);
    R2 = Rbin(i,2);
    for j=1:NE
        ind1 = and(R1<R,R<=R2);
        ind2 = and(M1<M,M<=M2);
        ind3 = and(e>Ebin(j,1),e<=Ebin(j,2));
        deaggIM(i,j) = sum(dg(ind1&ind2&ind3));
    end
end



