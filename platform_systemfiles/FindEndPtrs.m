function ptrs = FindEndPtrs(ptrs,data)
IND = [ptrs(:,1);size(data,1)];
IND(isnan(IND))=[];


for i=1:size(ptrs,1)
    if ~isnan(ptrs(i,1))
        ptrs(i,2)=nanmin(IND(IND>ptrs(i,1)));
    end
end

ptrs(:,1) = ptrs(:,1)+1; 
col2 = and(~isnan(ptrs(:,2)),ptrs(:,2)<size(data,1));
ptrs(col2,2) = ptrs(col2,2)-1;