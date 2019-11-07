function [param,val] = mMRparam(handles,source) %#ok<*INUSD,*DEFNU>

val = zeros(1,15);
mscl = source.mscl;

switch func2str(mscl.handle)
    case 'truncexp'
        str='Truncated Exponential';
        [~,B]=intersect(handles.MRselect.String,str);
        val(end)=B;
        param.NMmin    = mscl.msparam.NMmin;
        param.bvalue   = mscl.msparam.bvalue;
        param.Mmin     = mscl.msparam.Mmin;
        param.Mmax     = mscl.msparam.Mmax;
        
        
    case 'truncnorm'
        str='Truncated Normal';
        [~,B]=intersect(handles.MRselect.String,str);
        val(end)=B;
        param.NMmin    = mscl.msparam.NMmin;
        param.Mmin     = mscl.msparam.Mmin;
        param.Mmax     = mscl.msparam.Mmax;
        param.Mchar    = mscl.msparam.Mchar;        
        param.sigmaM   = mscl.msparam.sigmaM;        
        
        
    case 'delta'
        str='Delta';
        [~,B]=intersect(handles.MRselect.String,str);
        val(end)=B;
        param.NMmin    = mscl.msparam.NMmin;
        param.M        = mscl.msparam.M;
        
    case 'youngscoppersmith'
        str='Characteristic';
        [~,B]=intersect(handles.MRselect.String,str);
        val(end)=B;
        param.NMmin    = mscl.msparam.NMmin;
        param.bvalue   = mscl.msparam.bvalue;
        param.Mmin     = mscl.msparam.Mmin;
        param.Mchar    = mscl.msparam.Mchar;        
end
