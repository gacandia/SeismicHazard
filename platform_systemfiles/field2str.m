function[str]=field2str(str,varargin)

% fixes strings of IMs

todelete = [];

if size(str,1)==1 && contains(str{1},'logsp')
    per = eval(str{1});
    str = sprintfc('%g',per)';
end

if size(str,1)==1 && contains(str{1},'linpsace')
    per = eval(str{1});
    str = sprintfc('%g',per)';
end

for i=1:size(str,1)
    stri = lower(str{i});
    stri = strrep(stri,' ','');
    stri = strrep(stri,'sa','');
    stri = strrep(stri,'t','');
    stri = strrep(stri,'o','');
    stri = strrep(stri,'=','');
    stri = strrep(stri,'(' ,'');
    stri = strrep(stri,')' ,'');
    switch stri
        case {'-10','pgd'}     ,   str{i}='PGD';
        case {'-1' ,'pgv'}     ,   str{i}='PGV';
        case {'0'  ,'pga'}     ,   str{i}='PGA';
        case {'-4'}            ,   str{i}='CAV';
        case {'-5' ,'ia','ai'} ,   str{i}='AI';
        otherwise
            per = str2double(stri);
            if per<0 || isnan(per)
                todelete=[todelete;i]; %#ok<AGROW>
            elseif per==0
                str{i}='PGA';
            else
                str{i} = ['Sa(T=',stri,')'];
            end
    end
end
str(todelete)=[];

if nargin>1
	str=str(1);
end
