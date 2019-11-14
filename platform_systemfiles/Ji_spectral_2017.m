function [rho] = Ji_spectral_2017(T1, T2,param)

% Azarbakht, A., Mousavi, M., Nourizadeh, M. and Shahri, M., 2014. 
% Dependence of correlations between spectral accelerations at multiple 
% periods on magnitude and distance. Earthquake Engineering & Structural 
% Dynamics, 43(8), 1193-1204.
%
% ---- help for CP_spectral_2018 ---
% Developed by G.Candia, March 2018. Santiago.
% National Research Center for Integrated Natural Disaster Management
% CONICYT/FONDAP/15110017. FONDECYT N� 1170836 �SIBER-RISK: SImulation
% Based Earthquake Risk and Resilience of Interdependent Systems and NetworKs

T1(and(T1>=0,T1<0.01))=0.01;
T2(and(T2>=0,T2<0.01))=0.01;

T = [0.01;0.02;0.05;0.07;0.1; 0.2 ;0.3 ;0.5 ;0.7 ;1.0 ;1.5 ;1.7 ;2.0 ];
M = param.M;

if and(5.50 <= M,M < 6.00), V=Bin1; end
if and(6.00 <= M,M < 6.50), V=Bin2; end
if and(6.50 <= M,M <=7.00), V=Bin3; end
% if and(5.50 <= M,M < 6.00), V=Bin1; end

T_min = min(T1, T2); 
T_max = max(T1, T2); 
[X,Y] = meshgrid(T);
rho   = interp2(X,Y,V,T_min,T_max,'spline');
rho(T_min==T_max)=1;
rho   = min(rho,1);
rho   = max(rho,min(V(:)));
rho(T_min<0.01) = nan;
rho(T_max>2)    = nan;

function V=Bin1()
V=[1.000 1.000 0.947 0.908 0.912 0.882 0.807 0.609 0.539 0.445 0.391 0.390 0.365
1.000 1.000 0.952 0.914 0.916 0.877 0.801 0.600 0.531 0.437 0.384 0.383 0.358
0.947 0.952 1.000 0.958 0.913 0.776 0.690 0.467 0.401 0.316 0.267 0.270 0.256
0.908 0.914 0.958 1.000 0.928 0.727 0.624 0.377 0.302 0.215 0.178 0.180 0.166
0.912 0.916 0.913 0.928 1.000 0.746 0.626 0.402 0.337 0.255 0.227 0.229 0.209
0.882 0.877 0.776 0.727 0.746 1.000 0.875 0.688 0.600 0.509 0.456 0.452 0.421
0.807 0.801 0.690 0.624 0.626 0.875 1.000 0.806 0.699 0.599 0.539 0.526 0.502
0.609 0.600 0.467 0.377 0.402 0.688 0.806 1.000 0.906 0.822 0.747 0.730 0.708
0.539 0.531 0.401 0.302 0.337 0.600 0.699 0.906 1.000 0.920 0.853 0.837 0.810
0.445 0.437 0.316 0.215 0.255 0.509 0.599 0.822 0.920 1.000 0.931 0.917 0.892
0.391 0.384 0.267 0.178 0.227 0.456 0.539 0.747 0.853 0.931 1.000 0.981 0.952
0.390 0.383 0.270 0.180 0.229 0.452 0.526 0.730 0.837 0.917 0.981 1.000 0.974
0.365 0.358 0.256 0.166 0.209 0.421 0.502 0.708 0.810 0.892 0.952 0.974 1.000];

function V=Bin2()
V=[1.000 1.000 0.969 0.945 0.946 0.910 0.872 0.716 0.495 0.299 0.132 0.107 0.067   
1.000 1.000 0.972 0.948 0.949 0.909 0.869 0.710 0.487 0.290 0.124 0.099 0.059   
0.969 0.972 1.000 0.972 0.954 0.878 0.813 0.611 0.369 0.161 0.004 -0.014 -0.048 
0.945 0.948 0.972 1.000 0.969 0.869 0.783 0.556 0.292 0.081 -0.076 -0.100 -0.132
0.946 0.949 0.954 0.969 1.000 0.888 0.786 0.569 0.305 0.086 -0.077 -0.104 -0.140 
0.910 0.909 0.878 0.869 0.888 1.000 0.898 0.685 0.429 0.196 -0.009 -0.031 -0.070 
0.872 0.869 0.813 0.783 0.786 0.898 1.000 0.819 0.578 0.366 0.164 0.141 0.102    
0.716 0.710 0.611 0.556 0.569 0.685 0.819 1.000 0.842 0.652 0.444 0.413 0.369    
0.495 0.487 0.369 0.292 0.305 0.429 0.578 0.842 1.000 0.865 0.688 0.667 0.632    
0.299 0.290 0.161 0.081 0.086 0.196 0.366 0.652 0.865 1.000 0.867 0.843 0.811    
0.132 0.124 0.004 -0.076 -0.077 -0.009 0.164 0.444 0.688 0.867 1.000 0.972 0.935 
0.107 0.099 -0.014 -0.100 -0.104 -0.031 0.141 0.413 0.667 0.843 0.972 1.000 0.969
0.067 0.059 -0.048 -0.132 -0.140 -0.070 0.102 0.369 0.632 0.811 0.935 0.969 1.000];

function V=Bin3()
V=[
1.000 1.000 0.977 0.945 0.941 0.928 0.889 0.766 0.635 0.569 0.497 0.458 0.418
1.000 1.000 0.979 0.949 0.943 0.927 0.886 0.762 0.630 0.563 0.492 0.453 0.412
0.977 0.979 1.000 0.979 0.954 0.892 0.832 0.696 0.549 0.482 0.413 0.372 0.329
0.945 0.949 0.979 1.000 0.964 0.876 0.788 0.621 0.468 0.410 0.339 0.299 0.255
0.941 0.943 0.954 0.964 1.000 0.891 0.782 0.597 0.452 0.398 0.338 0.299 0.264 
0.928 0.927 0.892 0.876 0.891 1.000 0.876 0.681 0.537 0.481 0.425 0.394 0.366 
0.889 0.886 0.832 0.788 0.782 0.876 1.000 0.817 0.687 0.599 0.552 0.529 0.491 
0.766 0.762 0.696 0.621 0.597 0.681 0.817 1.000 0.887 0.769 0.686 0.661 0.619 
0.635 0.630 0.549 0.468 0.452 0.537 0.687 0.887 1.000 0.883 0.788 0.764 0.722 
0.569 0.563 0.482 0.410 0.398 0.481 0.599 0.769 0.883 1.000 0.890 0.870 0.833 
0.497 0.492 0.413 0.339 0.338 0.425 0.552 0.686 0.788 0.890 1.000 0.969 0.924 
0.458 0.453 0.372 0.299 0.299 0.394 0.529 0.661 0.764 0.870 0.969 1.000 0.950 
0.418 0.412 0.329 0.255 0.264 0.366 0.491 0.619 0.722 0.833 0.924 0.950 1.000];

% function V=Bin4()
% V=[1.000 1.000 0.962 0.929 0.930 0.902 0.845 0.677 0.550 0.437 0.346 0.330 0.295
% 1.000 1.000 0.966 0.934 0.933 0.900 0.840 0.670 0.543 0.430 0.339 0.323 0.289
% 0.962 0.966 1.000 0.968 0.937 0.838 0.760 0.564 0.429 0.317 0.230 0.216 0.188
% 0.929 0.934 0.968 1.000 0.951 0.812 0.711 0.489 0.341 0.229 0.146 0.131 0.103
% 0.930 0.933 0.937 0.951 1.000 0.832 0.712 0.498 0.355 0.243 0.165 0.149 0.120 
% 0.902 0.900 0.838 0.812 0.832 1.000 0.881 0.683 0.534 0.411 0.311 0.299 0.266 
% 0.845 0.840 0.760 0.711 0.712 0.881 1.000 0.812 0.663 0.536 0.441 0.426 0.394 
% 0.677 0.670 0.564 0.489 0.498 0.683 0.812 1.000 0.886 0.767 0.654 0.635 0.602 
% 0.550 0.543 0.429 0.341 0.355 0.534 0.663 0.886 1.000 0.897 0.796 0.778 0.745 
% 0.437 0.430 0.317 0.229 0.243 0.411 0.536 0.767 0.897 1.000 0.904 0.886 0.856 
% 0.346 0.339 0.230 0.146 0.165 0.311 0.441 0.654 0.796 0.904 1.000 0.976 0.941 
% 0.330 0.323 0.216 0.131 0.149 0.299 0.426 0.635 0.778 0.886 0.976 1.000 0.967 
% 0.295 0.289 0.188 0.103 0.120 0.266 0.394 0.602 0.745 0.856 0.941 0.967 1.000 ];
