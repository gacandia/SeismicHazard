function[lambdaD]=psda_BT2007_cdmM(Ts_param, ky_param, psda_param,im,M,dPm,Cz,varargin)

% Bray, J. D., & Travasarou, T. (2007). Simplified procedure for estimating
% earthquake-induced deviatoric slope displacements. Journal of Geotechnical
% and Geoenvironmental Engineering, 133(4), 381-392.

%%
d      = psda_param.d;
dPm    = horzcat(dPm{:});
realSa = psda_param.realSa;
realD  = psda_param.realD;
Nd     = length(d);     % N° of displacement values of lambdaD
Nim    = length(im);    % N° of acceleration values of lambdaSa

if nargin==7
    pd   = makedist('Normal');
    t    = truncate(pd,-2,2);
    xrnd = random(t,1,realD  * realSa);
    zrnd = random(t,1,realSa * realD);
else
    xrnd = varargin{1}; realD  = length(xrnd);
    zrnd = varargin{2}; realSa = length(zrnd);
end

if length(Ts_param)==2, Ts_param = [Ts_param,100]; end; NTs = Ts_param(3);
if length(ky_param)==2, ky_param = [ky_param,100]; end; Nky = ky_param(3);

[ky,Ts]  = meshgrid(trlognpdf_psda(ky_param),trlognpdf_psda(Ts_param));
ky       = ky(:)';
Ts       = Ts(:)';
Nmag     = length(M);
lnd      = zeros(Nim,Nky*NTs,Nmag);
Tlow     = Ts<0.05;

for m=1:Nmag
    for j=1:Nim
        lnd(j, Tlow,m) = -0.22-2.83*log(ky( Tlow))-0.333*(log(ky( Tlow))).^2+0.566*log(ky( Tlow))*log(im(j))+3.04*log(im(j))-0.244*(log(im(j))).^2+1.5*Ts( Tlow)+ 0.278*(M(m)-7);
        lnd(j,~Tlow,m) = -1.10-2.83*log(ky(~Tlow))-0.333*(log(ky(~Tlow))).^2+0.566*log(ky(~Tlow))*log(im(j))+3.04*log(im(j))-0.244*(log(im(j))).^2+1.5*Ts(~Tlow)+ 0.278*(M(m)-7);
    end
end

mean_d  = mean(lnd, 2);
std_d   = std(lnd,[], 2);
sigmaD  = 0.67;
logd    = log(d(:));

switch psda_param.method
    case 'MC'
        %         WORK IN  PROGRESS
        %         lambdaD = zeros(realSa*realD,Nd);
        %         for i=1:Nd % Loop over Displacement vector values
        %             for j=1:realD*realSa % Loop over realizations of Median Displacement
        %                 for m = 1:Nmag
        %                     PSA = 1 - normcdf((logd(i) - (mean_d(:, 1, m) + std_d(:, 1, m)* xrnd(j)))./sigmaD);
        %                     Prob_of_exceed_times_DLambda_along_SA = PSA.*Delta_lambda_times_Delta_SA' .* dPm(:, m);
        %                     Integral_Prob_exceed_at_di_sample = sum(Prob_of_exceed_times_DLambda_along_SA);
        %                     lambdaD(j,i) = lambdaD(j,i) + Integral_Prob_exceed_at_di_sample;
        %                 end
        %             end % End loop over displacement values
        %         end % End loop over realizations
        
    case 'PC'
        PC_term_0_GM = Cz(1:Nim, 1)';
        PC_term_1_GM = Cz(1:Nim, 2)';
        PC_term_2_GM = Cz(1:Nim, 3)';
        PC_term_3_GM = Cz(1:Nim, 4)';
        PC_term_4_GM = Cz(1:Nim, 5)';
        
        Hazard_PC_samples = zeros(realSa * realD, Nim);
        for i = 1:Nim
            Hazard_PC_samples(:, i) = ...
                PC_term_0_GM(i) + ...
                PC_term_1_GM(i) * zrnd + ...
                PC_term_2_GM(i) * (zrnd.^2-1) + ...
                PC_term_3_GM(i) * (zrnd.^3 - 3*zrnd) + ...
                PC_term_4_GM(i) * (zrnd.^4 - 6*zrnd.^2 + 3);
        end
        
        dlambdaPC        = diff(-prctile(Hazard_PC_samples,50),1,2);
        dlambdaPC(end+1) = dlambdaPC(end);
        
        PC_term_0_array = zeros(Nim,Nd);
        PC_term_1_array = zeros(Nim,Nd);
        PC_term_2_array = zeros(Nim,Nd);
        PC_term_3_array = zeros(Nim,Nd);
        PC_term_4_array = zeros(Nim,Nd);
        
        PC_term_0_summed = zeros(1, Nd);
        PC_term_1_summed = zeros(1, Nd);
        PC_term_2_summed = zeros(1, Nd);
        PC_term_3_summed = zeros(1, Nd);
        PC_term_4_summed = zeros(1, Nd);
        
        for m=1:length(M)
            for i = 1:Nim
                A_s = - std_d(i,1,m)^2/(2*sigmaD^2) - 1/2;
                B_s = (logd - mean_d(i,1,m))*std_d(i,1,m)/(sigmaD^2);
                C_s = -(logd - mean_d(i,1,m)).^2 * 1/(2*sigmaD^2);
                PC_term_0_array(i,:) = 1/1 * (1 - normcdf((logd - mean_d(i,1,m))/(sqrt(sigmaD^2 + std_d(i)^2))))*dlambdaPC(i);
                PC_term_1_array(i,:) = 1/1 * (std_d(i,1,m)/(sigmaD *2*pi) .* (sqrt(pi)/sqrt(-A_s))* exp(C_s -B_s.^2/(4*A_s)))*dlambdaPC(i);
                PC_term_2_array(i,:) = 1/2 * (std_d(i,1,m)/(sigmaD *2*pi) .* (sqrt(pi)*B_s/(2*(-A_s)^(3/2))).* exp(C_s -B_s.^2/(4*A_s)))*dlambdaPC(i);
                PC_term_3_array(i,:) = 1/6 * (std_d(i,1,m)/(sigmaD *2*pi) .* (sqrt(pi)*(-2*A_s*(1 + 2*A_s) + B_s.^2)/(4*(-A_s)^(5/2))).* exp(C_s -B_s.^2/(4*A_s)))*dlambdaPC(i);
                PC_term_4_array(i,:) = 1/24* (std_d(i,1,m)/(sigmaD *2*pi) .* (sqrt(pi)*(-B_s).*(6*A_s*(1 + 2*A_s) - B_s.^2)/(8*(-A_s)^(7/2))).* exp(C_s -B_s.^2/(4*A_s)))*dlambdaPC(i);
            end
            
            PC_term_0_summed = PC_term_0_summed + dPm(m,:)*PC_term_0_array; % sums over the rows
            PC_term_1_summed = PC_term_1_summed + dPm(m,:)*PC_term_1_array;
            PC_term_2_summed = PC_term_2_summed + dPm(m,:)*PC_term_2_array;
            PC_term_3_summed = PC_term_3_summed + dPm(m,:)*PC_term_3_array;
            PC_term_4_summed = PC_term_4_summed + dPm(m,:)*PC_term_4_array;
        end
        
        lambdaD = zeros(realSa*realD,Nd);
        
        for i = 1:Nd
            lambdaD(:, i) =...
                PC_term_0_summed(i) * (xrnd.^0) + ...
                PC_term_1_summed(i) * (xrnd.^1) + ...
                PC_term_2_summed(i) * (xrnd.^2-1) + ...
                PC_term_3_summed(i) * (xrnd.^3-3*xrnd) + ...
                PC_term_4_summed(i) * (xrnd.^4-6*xrnd.^2+3);
        end
end



