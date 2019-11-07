function[T,IJK]=main_psda(T1,T2,T3)

NT1 = size(T1,1);
NT2 = size(T2,1);
NT3 = size(T3,1);
[II,JJ,KK]=meshgrid(1:NT1,1:NT2,1:NT3);
II = II(:);
JJ = JJ(:);
KK = KK(:);
w1 = cell2mat(T1(II,2));
w2 = cell2mat(T2(JJ,4));
w3 = cell2mat(T3(KK,6));
T  = [T1(II,1),T2(JJ,1),T3(KK,1),num2cell(w1.*w2.*w3)];
IJK = [II,JJ,KK];
