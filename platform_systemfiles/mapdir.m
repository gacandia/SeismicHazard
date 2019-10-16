function [matfiles]=mapdir(path1)


matfiles=dir(path1);

ind = false(1,length(matfiles));
for i=1:length(matfiles)
   fname = fullfile (matfiles(i).folder,matfiles(i).name);
   I  = true(1,5);
   I(1) =~isempty(who('-file', fname, 'XLIM'));
   I(2) =~isempty(who('-file', fname, 'YLIM'));
   I(3) =~isempty(who('-file', fname, 'cc'));
   I(4) =~isempty(who('-file', fname, 'xx'));
   I(5) =~isempty(who('-file', fname, 'yy'));
   ind(i)=all(I);
end

matfiles = matfiles(ind);
