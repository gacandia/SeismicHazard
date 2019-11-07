function [param,val] = mMRgetparam(handles) %#ok<*INUSD,*DEFNU>

ch=get(handles.panel2,'children');
ch2=ch(handles.edit);
val=vertcat(ch2.Value);
str=cell(length(ch2),1);
for i=1:length(ch2)
    str{i}=ch2(i).String;
    if val(i)~=0 && size(str{i},1)>1
        str{i}=str{i}{val(i)};
    end
end
val = [val;handles.MRselect.Value];

methods = pshatoolbox_methods(2);

switch methods(handles.MRselect.Value).str
    case 'delta'
        param.NMmin    = str2double(str{1});
        param.M        = str2double(str{2});
        
    case 'truncexp'
        param.NMmin    = str2double(str{1});
        param.bvalue   = str2double(str{2});
        param.Mmin     = str2double(str{3});
        param.Mmax     = str2double(str{4});
        
    case 'truncnorm'
        param.NMmin    = str2double(str{1});
        param.Mmin     = str2double(str{2});
        param.Mmax     = str2double(str{3});
        param.Mchar    = str2double(str{4});
        param.sigmaM   = str2double(str{5});
        
    case 'youngscoppersmith'
        param.NMmin    = str2double(str{1});
        param.bvalue   = str2double(str{2});
        param.Mmin     = str2double(str{3});
        param.Mchar    = str2double(str{4});
end
