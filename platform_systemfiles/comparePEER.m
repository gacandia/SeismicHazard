function[]=comparePEER(handles)

IM         = handles.sys.IM;
lambdaTest = handles.sys.lambdaTest;
lambdaTest(lambdaTest==0)=nan;
im         = handles.opt.im';
lambda     = nansum(handles.MRE,4);
lambda(isnan(lambdaTest))=NaN;
Error      = abs((lambdaTest-lambda)./lambdaTest*100);
% Error(lambdaTest==lambda)=0;
Acc        = num2cell(Error<=5);
for i=1:numel(Acc)
    if Acc{i}==1 || isinf(Error(i))
        Acc{i}='Y';
    else
        Acc{i}='N';
    end
end
%%
fname = which(handles.sys.filename);
fname = strrep(fname,'.txt','.out');
fileID = fopen(fname,'w');

NN = sum(sum(~isnan(Error),1)>0);

fprintf(fileID,'%s\n',handles.sys.filename);
fprintf(fileID,'--------------------------------------------------------\n');
fprintf(fileID,'Benchmark Solution\n');
strpat = ['IM      ' repmat('%6.5e ',1,NN),'\n'];
fprintf(fileID,strpat,IM(1:NN));

for i=1:size(lambdaTest,1)
    NN = sum(~isnan(Error(i,:)));
    strpat = [sprintf('Site%-4g',i), repmat('%6.5e ',1,NN),'\n'];
    fprintf(fileID,strpat,lambdaTest(i,1:NN));
end


fprintf(fileID,'\nSeismicHazard Solution\n');
NN = sum(sum(~isnan(Error),1)>0);
strpat = ['IM      ' repmat('%6.5e ',1,NN),'\n'];
fprintf(fileID,strpat,im(1:NN));

for i=1:size(lambda,1)
    NN = sum(~isnan(Error(i,:)));
    strpat = [sprintf('Site%-4g',i), repmat('%6.5e ',1,NN),'\n'];
    fprintf(fileID,strpat,lambda(i,1:NN));
end
 
fprintf(fileID,'\nError (percentage)\n');
for i=1:size(lambda,1)
    NN = sum(~isnan(Error(i,:)));
    strpat = [sprintf('Site%-4g',i), repmat('%6.5e ',1,NN),'\n'];
    fprintf(fileID,strpat,Error(i,1:NN));
end

fprintf(fileID,'\nError less 5 percent(Y/N)\n');
for i=1:size(lambda,1)
    NN = sum(~isnan(Error(i,:)));
    strpat = sprintf('Site%-4g',i);
    for j=1:NN
        if j<NN
            strpat = [strpat,sprintf('%s',Acc{i,j}),'           '];
        else
            strpat = [strpat,sprintf('%s',Acc{i,j}),'\n'];
        end
    end
    fprintf(fileID,strpat);
end
fclose(fileID);
winopen(fname)



