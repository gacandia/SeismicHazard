function [lny,sigma,tau,sig] = condPGV(T,M,Rrup,func,mechanism,~,varargin)

% T         = -1; %not used
% M         = Moment magnitude
% func      = function handle to Sa model
% mechanism = 1 for interface earthquakes
%             2 for intraslab earthquakes
% un        = units of Sa
% varargin  = input parameters that follow T in the matlab function that
%              runs the Sa GMPE

if T~=-1
    lny   = nan(size(M));
    sigma = nan(size(M));
    tau   = nan(size(M));
    sig   = nan(size(M));
    %IM    = IM2str(T);
    %h=warndlg(sprintf('GMPE %s not available for %s',mfilename,IM{1}));
    %uiwait(h);
    return
end

[lny,sigma,tau,sig] = deal(M*nan);
bin1 = and(5.0<=M,M<5.5);
bin2 = and(5.5<=M,M<6.0);
bin3 = and(6.0<=M,M<6.5);
bin4 = and(6.5<=M,M<7.0);
bin5 = and(7.0<=M,M<9.0);

switch mechanism
    case 'interface'
        data = [0.28	0.28	0.36	0.45	0.57
            -2.104	-1.678	-1.563	-1.340	-0.843
            0.840	0.937	0.900	0.896	0.925
            0.320	0.331	0.341	0.309	0.309];
        Ts   = data(1,:);
        A    = data(2,:);
        B    = data(3,:);
        sPGV = data(4,:);
        
    case 'intraslab'
        data = [0.22	0.28	0.57	0.57	0.45
            -2.557	-1.946	-0.958	-1.875	-0.793
            0.799	0.860	0.927	0.772	1.023
            0.287	0.304	0.293	0.204	0.112];
        Ts   = data(1,:);
        A    = data(2,:);
        B    = data(3,:);
        sPGV = data(4,:);
end


if any(bin1)
    [lnSa,sig]  = func(Ts(1),varargin{:});
    lny(bin1)   = A(1)+B(1)*lnSa(bin1);
    sigma(bin1) = sqrt(B(1)^2*sig(bin1).^2+sPGV(1)^2);
end
if any(bin2)
    [lnSa,sig]  = func(Ts(2),varargin{:});
    lny(bin2)   = A(2)+B(2)*lnSa(bin2);
    sigma(bin2) = sqrt(B(2)^2*sig(bin2).^2+sPGV(2)^2);
end
if any(bin3)
    [lnSa,sig]  = func(Ts(3),varargin{:});
    lny(bin3)   = A(3)+B(3)*lnSa(bin3);
    sigma(bin3) = sqrt(B(3)^2*sig(bin3).^2+sPGV(3)^2);
end
if any(bin4)
    [lnSa,sig]  = func(Ts(4),varargin{:});
    lny(bin4)   = A(4)+B(4)*lnSa(bin4);
    sigma(bin4) = sqrt(B(4)^2*sig(bin4).^2+sPGV(4)^2);
end
if any(bin5)
    [lnSa,sig]  = func(Ts(5),varargin{:});
    lny(bin5)   = A(5)+B(5)*lnSa(bin5);
    sigma(bin5) = sqrt(B(5)^2*sig(bin5).^2+sPGV(5)^2);
end
