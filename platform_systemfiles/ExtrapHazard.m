function [newim1] = ExtrapHazard(im,lambda1,AEP)


%% Fit: 'untitled fit 1'.
lnx = log(im(:,1));
[~,ind]=max(lambda1(end,:));

if lambda1(end,ind)<min(AEP)
    newim1    = im;
    return
end

lny = log(lambda1(:,ind)); 
[xData, yData] = prepareCurveData( lnx, lny );
ft        = fittype( 'poly3' );
fitresult = fit( xData, yData, ft );
lnxo      = log(logsp(im(end,1),200,200)');
lnyo      = fitresult(lnxo);
lnxomax   = interp1(lnyo,lnxo,log(min(AEP)));
xomax     = ceil(exp(lnxomax)); 
[~, Nper] = size(im);
newim1    = repmat(logsp(0.01,xomax,20)',1,Nper);
