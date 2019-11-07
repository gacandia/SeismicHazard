function[str]=IM2str(T)

if isnumeric(T)
    str = cell(1,length(T));
    for i=1:length(T)
        val = T(i);
        if val==-10
            str{i} = 'PGD';
        elseif val==-6
            str{i} = 'VGI';
        elseif val==-5
            str{i} = 'AI';
        elseif val==-4
            str{i} = 'CAV';
        elseif val==-3
            str{i} = 'Duration';
        elseif val==-1
            str{i} = 'PGV';
        elseif val==0
            str{i} = 'PGA';
        elseif val>0
            str{i} = ['Sa(T=',num2str(val),')'];
        end
    end
end

if iscell(T)
    str = T;
end