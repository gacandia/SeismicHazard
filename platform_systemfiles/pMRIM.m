function [PIM] = pMRIM (dchart, lambda)

[Nm,Nr,Nim] = size(dchart);
lambda      = repmat(permute(lambda,[2 3 1]),[Nm Nr]);
PIMz        = dchart.*lambda;
PIM         = zeros(Nm,Nr,Nim) ;

for  B = 1:Nim
    if B == 1
        PIM(:,:,B) = (PIMz(:,:,B) - PIMz(:,:,B+1))/2;
    elseif B == Nim
        PIM(:,:,B) = (PIMz(:,:,B-1)- PIMz(:,:,B))/2 + PIMz(:,:,B);
    else
        PIM(:,:,B) = (PIMz(:,:,B-1)- PIMz(:,:,B+1))/2;
    end
end

% ERROR = sum(sum(sum(PIM(:,:,:)))) - sum(sum(PIMz(:,:,1)));
% fprintf('    ERROR = %s <<-- SHOULD BE ZERO OR A VERY SMALL NUMBER\n',...
%     num2str(ERROR, 6));
