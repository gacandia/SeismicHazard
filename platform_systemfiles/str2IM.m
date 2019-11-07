function[IM]=str2IM(str)

NIM = length(str);
IM  = zeros(NIM,1);
for i=1:NIM
    switch str{i}
        case 'PGA',  IM(i)=0;
        case 'PGV',  IM(i)=-1;
        case 'Duration',IM(i)=-3;
        case 'CAV',  IM(i)=-4;
        case 'AI' ,  IM(i)=-5;
        case 'VGI',  IM(i)=-6;
        case 'PGD',  IM(i)=-10;    
        otherwise
            stri = lower(str{i});
            stri = strrep(stri,' ','');
            stri = strrep(stri,'sa','');
            stri = strrep(stri,'t=','');
            stri = strrep(stri,'o','');
            stri = strrep(stri,')','');
            stri = strrep(stri,'(','');
            stri = strrep(stri,'ts','');
            IM(i) = eval(stri);
    end
end