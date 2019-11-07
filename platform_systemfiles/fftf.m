function[f]=fftf(time)

[rows,columns]=size(time);
N  = length(time);
h  = mean(diff(time));
f  = (0:N-1)/(h*N);
f  = reshape(f,rows,columns);
mid=ceil(N/2)+1;
f(mid:N)=f(mid:N)-1/h;