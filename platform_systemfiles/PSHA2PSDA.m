function[Sa,Mag,deriv,Deag]=PSHA2PSDA(deagg,Sa,lambda,applycorr)

Hao    = lambda;
Sa     = Sa(:); Sa=Sa';
Sao    = Sa(:); Sao=Sao';

Nim  = length(Sa);
M    = NaN(97,Nim);
Deag = NaN(97,Nim);
for col=1:Nim
    unM = unique(deagg{col}(:,1));
    unN = length(unM);
    M(1:unN,col)=unM;
    deag_col = deagg{col};
    for row=1:unN
        disc = (deag_col(:,1)==unM(row)).*deag_col(:,3);
        Deag(row,col)=nansum(disc)/Hao(col)*100;
    end
end

ind=find(prod(isnan(M),2));
M(ind,:)=[];
Deag(ind,:)=[];

Mbins   = round([5:0.2:9.4;5.2:0.2:9.6]'*1e6)/1e6;
Mag     = 0.5*(Mbins(:,1)+Mbins(:,2));
nM      = size(Mbins,1);
nSa     = size(Sa,2);
Deag2    = zeros(nM,nSa);

for i=1:nM
    for j=1:nSa
        ind = and(Mbins(i,1)<=M(:,j),M(:,j)<Mbins(i,2));
        Deag2(i,j) = sum(Deag(ind,j));
    end
end
Deag   = 1/2*(Deag2(:,1:end-1)+Deag2(:,2:end));
Sa     = sqrt(Sao(1:end-1).*Sao(2:end));
% dsa    = log(Sao(2:end))-log(Sao(1:end-1));
% Ha     = sqrt(Hao(1:end-1).*Hao(2:end));
deriv  = -diff(Hao);

if applycorr
    deriv = deriv';
    inSa=0.001;
    deltaSa=0.2; %delta in Ln units
    numsa=size(Sao,2);
    countad=ceil((log(min(Sao))-log(inSa))/deltaSa);
    Sa_ad=zeros(1,countad);
    Sa_adgeo=zeros(1,countad);
    Ha_ad=zeros(1,countad);
    Ha_adgeo=zeros(1,countad);
    dsa_ad=zeros(1,countad);
    deriv_ad=zeros(1,countad);
    
    Sa_ad(1)=inSa;
    for ad=1:1:countad-1
        Sa_adit=log(inSa)+deltaSa*ad;
        Sa_ad(ad+1)=exp(Sa_adit);
    end
    
    for ad=1:1:countad
        Ha_ad(ad)=exp(log(Hao(2))-(log(Sao(2))-log(Sa_ad(ad)))*(log(Hao(2))-log(Hao(1)))/(log(Sao(2))-log(Sao(1))));
    end
    for ad=1:1:countad-1
        Sa_adgeo(ad)= sqrt(Sa_ad(ad)*Sa_ad(ad+1));
        Ha_adgeo(ad)=sqrt(Ha_ad(ad)*Ha_ad(ad+1));
        dsa_ad(ad)=log(Sa_ad(ad+1))-log(Sa_ad(ad));
        %dsa_ad(ad)=Sa_ad(ad+1)-Sa_ad(ad);
        
        deriv_ad(ad)=Ha_ad(ad)-Ha_ad(ad+1);
    end
    Sa_adgeo(countad)=sqrt(Sa_ad(countad)*Sao(1));
    Ha_adgeo(countad)=sqrt(Ha_ad(countad)*Hao(1));
    %dsa_ad(countad)=log(Sao(1))-log(Sa_ad(countad));
    %dsa_ad(countad)=Sao(1)-Sa_ad(countad);
    
    deriv_ad(countad)=Ha_ad(countad)-Hao(1);
    deriv_ad=deriv_ad';
    %deriv_ad=zeros(countad,1);activate only in the case of horizontal hazard
    %curve for low Sa values
    
    Deag_adgeo=zeros(size(Mag,1),countad);
    for jjj=1:1:countad
        for iii=1:1:size(Mag,1)
            Deag_adgeo(iii,jjj)=Deag(iii,1);
        end
    end
    
    HaM_adgeo=zeros(size(Mag,1),countad);
    for jjj=1:1:countad
        for iii=1:1:size(Mag,1)
            HaM_adgeo(iii,jjj)=Deag(iii,1)/100*Ha_adgeo(jjj);
        end
    end
    
    % Sa=[Sa_adgeo,Sa];
    % Ha=[Ha_adgeo,Ha];
    % dsa=[dsa_ad,dsa];
    % deriv=[deriv_ad;deriv];
    % Deag=[Deag_adgeo,Deag];
    % HaM=[HaM_adgeo,HaM];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%BEGIN ADDED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%added for the final
    maxSa=5;
    deltaSaf=0.5; %delta in Ln units
    countadf=ceil((log(maxSa)-log(max(Sao)))/deltaSaf);
    Sa_adf=zeros(1,countadf);
    Sa_adgeof=zeros(1,countadf);
    Ha_adf=zeros(1,countadf);
    Ha_adgeof=zeros(1,countadf);
    dsa_adf=zeros(1,countadf);
    deriv_adf=zeros(1,countadf);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end of added
    Sa_adf(1)=exp(log(max(Sao))+deltaSaf);
    for ad=1:1:countadf-1
        Sa_adit=log(Sa_adf(1))+deltaSaf*ad;
        Sa_adf(ad+1)=exp(Sa_adit);
    end
    
    for ad=1:1:countadf
        Ha_adf(ad)=exp(log(Hao(numsa-1))+(log(Sa_adf(ad))-log(Sao(numsa-1)))*(log(Hao(numsa))-log(Hao(numsa-1)))/(log(Sao(numsa))-log(Sao(numsa-1))));
    end
    for ad=1:1:countadf-1
        Sa_adgeof(ad+1)= sqrt(Sa_adf(ad)*Sa_adf(ad+1));
        Ha_adgeof(ad+1)=sqrt(Ha_adf(ad)*Ha_adf(ad+1));
        dsa_adf(ad+1)=log(Sa_adf(ad+1))-log(Sa_adf(ad));
        %dsa_adf(ad)=Sa_adf(ad+1)-Sa_adf(ad);
        
        deriv_adf(ad+1)=Ha_adf(ad)-Ha_adf(ad+1);
    end
    Sa_adgeof(1)=sqrt(Sa_adf(1)*Sao(numsa));
    Ha_adgeof(1)=sqrt(Ha_adf(1)*Hao(numsa));
    %dsa_adf(1)=-log(Sao(numsa))+log(Sa_adf(1));
    %dsa_adf(1)=-Sao(numsa)+Sa_adf(1);
    
    deriv_adf(1)=Hao(numsa)-Ha_adf(1);
    
    deriv_adf=deriv_adf';
    
    
    %deriv_ad=zeros(countad,1);activate only in the case of horizontal hazard
    %curve for low Sa values
    
    %%%%%%%%%%%%%%%%%%%%%%%%added
    Sa=[Sa_adgeo,Sa,Sa_adgeof];
    %Ha=[Ha_adgeo(:);Ha(:);Ha_adgeof(:)]';
    %dsa=[dsa_ad,dsa,dsa_adf];
    deriv=[deriv_ad;deriv(:);deriv_adf];
    %%%%%%%%%%%%%%%%%%%%%%%end added
    Deag_adgeof=zeros(size(Mag,1),countadf);
    for jjj=1:1:countadf
        for iii=1:1:size(Mag,1)
            Deag_adgeof(iii,jjj)=Deag(iii,numsa-1);
        end
    end
    
    HaM_adgeof=zeros(size(Mag,1),countadf);
    for jjj=1:1:countadf
        for iii=1:1:size(Mag,1)
            HaM_adgeof(iii,jjj)=Deag(iii,numsa-1)/100*Ha_adgeof(jjj);
        end
    end
    
    Deag=[Deag_adgeo,Deag,Deag_adgeof];
%     HaM=[HaM_adgeo,HaM,HaM_adgeof];
    
end

deriv=deriv';