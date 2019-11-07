function[GM]=GMSelect_GeometricMean(GM,H1,H2,~)

Neq = length(H1);
for i=1:Neq
    GM(i).T     = H1(i).T;
    GM(i).PGA   = sqrt(H1(i).PGA   * H2(i).PGA);
    GM(i).PGV   = sqrt(H1(i).PGV   * H2(i).PGV);
    GM(i).PGD   = sqrt(H1(i).PGD   * H2(i).PGD);
    GM(i).Sa    = sqrt(H1(i).Sa   .* H2(i).Sa);
    GM(i).Sv    = sqrt(H1(i).Sv   .* H2(i).Sv);
    GM(i).Sd    = sqrt(H1(i).Sd   .* H2(i).Sd);
    GM(i).D595  = sqrt(H1(i).D595  * H2(i).D595);
    GM(i).D2575 = sqrt(H1(i).D2575 * H2(i).D2575);
    GM(i).DBracket =sqrt(H1(i).DBracket * H2(i).DBracket);
    GM(i).Tm    = sqrt(H1(i).Tm    * H2(i).Tm);
    GM(i).Tp    = sqrt(H1(i).Tp    * H2(i).Tp);
    GM(i).To    = sqrt(H1(i).To    * H2(i).To);
    GM(i).aRMS  = sqrt(H1(i).aRMS  * H2(i).aRMS);
    GM(i).CAV   = sqrt(H1(i).CAV   * H2(i).CAV);
    GM(i).Arias = sqrt(H1(i).Arias * H2(i).Arias);
end

% no unit conversion required since all data comes from H1 and H2, which
% are have the propper units