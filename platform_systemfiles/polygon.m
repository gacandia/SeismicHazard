%%
function b = polygon(FDsup,FDinf,FX,FY,Catalog)
depth1=FDsup;
depth2=FDinf;
%
xq=Catalog(:,1);
yq=Catalog(:,2);
yearq=Catalog(:,3);
monthq=Catalog(:,4);
dayq=Catalog(:,5);
magq=Catalog(:,6);
zq=Catalog(:,7);
hourq=Catalog(:,8);
minq=Catalog(:,9);
%
cant= size(zq,1);
%tag=0;%0 (interface) 1 (intraplate superior) 2 (shallow crustal)?
count=0;
for j=1:1:cant
    if zq(j)>=depth1&&zq(j)<=depth2
    count=count+1;
    xqf(count)=xq(j);
    yqf(count)=yq(j);
    yearqf(count)=yearq(j);
    monthqf(count)=monthq(j);
    dayqf(count)=dayq(j);
    magqf(count)=magq(j);
    zqf(count)=zq(j);
    hourqf(count)=hourq(j);
    minqf(count)=minq(j);
    end
 end
%
xv=cell2mat(FX);
yv=cell2mat(FY);
%
if count >0
    [in,on] = inpolygon(xqf,yqf, xv,yv);                          % Logical Matrix
    %
    inon = in | on;                                             % Combine ‘in’ And ‘on’
    idx = find(inon(:));                                        % Linear Indices Of ‘inon’ Points
    xcoord = xqf(idx);                                           % X-Coordinates Of ‘inon’ Points
    ycoord = yqf(idx);                                           % Y-Coordinates Of ‘inon’ Points
    year=yearqf(idx);
    month=monthqf(idx);
    day=dayqf(idx);
    mag=magqf(idx);
    z=zqf(idx);
    hour=hourqf(idx);
    min=minqf(idx);
	b = [xcoord',ycoord',year',month',day',mag', z',hour',min'];
else
    b=[];
end 
end


