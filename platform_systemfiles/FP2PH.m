function [haz]=FP2PH(handles)

haz = handles.haz;
w   = handles.sys.WEIGHT(:,4);
% Hazard Curves
if ~isempty(haz.lambda)
    for i=1:length(w)
        haz.lambda(:,:,:,:,i)=haz.lambda(:,:,:,:,i)*w(i);
    end
    haz.lambda = nansum(haz.lambda,5);
end


% Hazard deaggregation
SIZ    = size(haz.deagg);
if ~isempty(haz.deagg) && length(SIZ)>=5
    deagg  = haz.deagg(:,:,:,:,1);
    for i=1:SIZ(1)
        for j=1:SIZ(2)
            for k=1:SIZ(3)
                for l=1:SIZ(4)
                    for m=1:SIZ(5)
                        if ~isempty(haz.deagg{i,j,k,l,m})
                            if m==1
                                aux = deagg{i,j,k,l}(:,3)*w(m);
                                aux(isnan(aux))=0;
                                deagg{i,j,k,l}(:,3)=aux;
                            else
                                aux = haz.deagg{i,j,k,l,m}(:,3)*w(m);
                                aux(isnan(aux))=0;
                                deagg{i,j,k,l}(:,3)=deagg{i,j,k,l}(:,3)+aux;
                            end
                        end
                    end
                end
            end
        end
    end
    haz.deagg=deagg;
end

% Mean Rate Density
if ~isempty(haz.MRD)
    haz.MRD(isnan(haz.MRD))=0;
    for i=1:length(w)
        if i==1
            MRD = haz.MRD(:,:,:,:,1)*w(i);
        else
            MRD = MRD+(haz.MRD(:,:,:,:,i)*w(i));
        end
    end
    haz.MRD=MRD;
end
