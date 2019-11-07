function[data]=readBin(filename)

fid=fopen(filename);
data=fread(fid,'double');
fclose(fid);

Ncol = sum(data==-999);
Nrow = numel(data)/Ncol;
data = reshape(data,Nrow,Ncol);
data(end,:)=[];
