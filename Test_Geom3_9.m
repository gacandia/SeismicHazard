

s1=[-8.528   -80.991    -25   -10.322   -80.022    -25  -14.412  -77.184   -25   -13.563   -75.856    -60    -10.464   -77.824     -60    -7.74    -79.267    -60];
s2=[-7.352   -78.423   -100    -8.015   -79.881    -60  -11.728  -78.003   -60   -13.899   -76.381    -60    -12.871   -74.775    -120  -10.831    -76.441   -130];


s1=reshape(s1,[3,6])';
s2=reshape(s2,[3,6])';

hold on
patch('vertices',s1,'faces',1:6,'facecolor','b')
patch('vertices',s2,'faces',1:6,'facecolor','r')

plot3(-11.18,-77.50,0,'ko')