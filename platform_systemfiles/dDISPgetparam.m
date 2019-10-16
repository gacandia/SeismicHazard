function [param,implot] = dDISPgetparam(handles,im) %#ok<*INUSD,*DEFNU>

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

methods = pshatoolbox_methods(5);
methods = methods(vertcat(methods.isregular));

val     = handles.Dpop.Value;
label   = methods(val).label;
on      = ones(size(im));
ky      = str2double(handles.ky.String)*on;
Ts      = str2double(handles.Ts.String)*on;

switch label
    case 'BMT 2017 Sa(M)'
        Sa    = im;
        implot= str2double(str{1});
        mag   = str2double(str{2})*on;
        param = {ky,Ts,Sa,mag};
        
        % crustal (bray et al)
    case 'BT 2007 Sa'
        Sa    = im;
        implot= str2double(str{1});
        param = {ky,Ts,Sa};
    case 'BT 2007 Sa(M)'
        Sa    = im;
        implot= str2double(str{1});
        mag   = str2double(str{2})*on;
        param = {ky,Ts,Sa,mag};
    case 'BM 2019 NonNF (M)'
        Sa    = im;
        implot= str2double(str{1});
        mag   = str2double(str{2})*on;
        param = {ky,Ts,Sa,mag};
        
        % crustal (bray et al)
    case 'Jibson  2007 (M)'
        PGA   = im;
        implot= str2double(str{1});
        mag   = str2double(str{2})*on;
        param = {ky,Ts,PGA,mag};
    case 'Jibson  2007 Ia'
        Ia    = im;
        implot= str2double(str{1});
        param = {ky,Ts,Ia};
    case 'RA 2011 (Rigid)'
        PGV   = str2double(str{1})*on;
        implot= str2double(str{2});
        PGA   = im;
        param = {ky,Ts,PGV,PGA};
    case 'RA 2011 (Flexible)'
        kvmax = str2double(str{1})*on;
        implot= str2double(str{2});
        kmax  = im;
        param = {ky,Ts,kvmax,kmax};
    case 'RS 2009 (Scalar-M)'
        PGA   = im;
        implot= str2double(str{1});
        mag   = str2double(str{2})*on;
        param = {ky,Ts,PGA,mag};
    case 'RS 2009 (Vector)'
        PGV   = str2double(str{1})*on;
        PGA   = im;
        implot= str2double(str{2});
        param = {ky,Ts,PGV,PGA};
    case 'AM 1988'
        PGA   = im;
        implot= str2double(str{1});
        param = {ky,Ts,PGA};
       
end
