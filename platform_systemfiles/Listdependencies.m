clc

% fun = 'SeismicHazard.m';
fun = 'GMselect.m';
% fun = 'PSDA2.m';
% fun = 'pshatoolbox_methods.m';
list  = matlab.codetools.requiredFilesAndProducts(fun)';
for i=1:size(list,1)
copyfile(list{i},'C:\Users\Gabriel\Desktop\GMSelect')
end

%% Pcode
D=dir('*.m'); for i=1:size(D,1); pcode(D(i).name); end