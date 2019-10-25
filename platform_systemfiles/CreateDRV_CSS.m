function data=CreateDRV_CSS(param,nameCSV)

fid  = fopen('CSSref.txt');
data = textscan(fid,'%s','delimiter','\n');
data = data{1};
fclose(fid);

% aa1
switch param{1}
    case 1, data=strrep(data,'$aa1','0');
    case 2, data=strrep(data,'$aa1','1');    
    case 3, data=strrep(data,'$aa1','2');
end

% aa2
To = str2double(param{2});
data=strrep(data,'$aa2',sprintf('%.2f',To));

% aa3 aa4
To = str2double(regexp(param{3},'\-','split'));
data=strrep(data,'$aa3',sprintf('%.2f',To(1)));
data=strrep(data,'$aa4',sprintf('%.2f',To(2)));

% aa5 aa6
To = str2double(regexp(param{4},'\-','split'));
data=strrep(data,'$aa5',sprintf('%.2f',To(1)));
data=strrep(data,'$aa6',sprintf('%.2f',To(2)));

% aa7 aa8
To = str2double(regexp(param{5},'\-','split'));
data=strrep(data,'$aa7',sprintf('%.1f',To(1)));
data=strrep(data,'$aa8',sprintf('%.1f',To(2)));

% aa9
switch param{6}
    case 1, data=strrep(data,'$aa9','1');
    case 2, data=strrep(data,'$aa9','2');
end

% bb1 bb2
To = str2double(regexp(param{7},'\-','split'));
data=strrep(data,'$bb1',sprintf('%.1f',To(1)));
data=strrep(data,'$bb2',sprintf('%.1f',To(2)));

% bb3 bb4
To = str2double(regexp(param{8},'\-','split'));
data=strrep(data,'$bb3',sprintf('%.1f',To(1)));
data=strrep(data,'$bb4',sprintf('%.1f',To(2)));

% bb5 bb6
To = str2double(regexp(param{9},'\-','split'));
data=strrep(data,'$bb5',sprintf('%.1f',To(1)));
data=strrep(data,'$bb6',sprintf('%.1f',To(2)));

% bb7 bb8
To = str2double(regexp(param{10},'\-','split'));
data=strrep(data,'$bb7',sprintf('%.1f',To(1)));
data=strrep(data,'$bb8',sprintf('%.1f',To(2)));

% bb9 cc1
To = str2double(regexp(param{11},'\-','split'));
data=strrep(data,'$bb9',sprintf('%.1f',To(1)));
data=strrep(data,'$cc1',sprintf('%.1f',To(2)));

% cc2
To = str2double(param{12});
data=strrep(data,'$cc2',sprintf('%i',To));

% cc3
To = str2double(param{13});
data=strrep(data,'$cc3',sprintf('%i',To));

% cc4 cc5
To = str2double(regexp(param{14},'\-','split'));
data=strrep(data,'$cc4',sprintf('%i',To(1)));
data=strrep(data,'$cc5',sprintf('%.2f',To(2)));

% cc6
To = str2double(param{15});
data=strrep(data,'$cc6',sprintf('%.2f',To));

data = strrep(data,'$csvfile$',nameCSV);

fileID = fopen('H.txt','w');
fprintf(fileID,'%s\n',data{:});
fclose(fileID);
