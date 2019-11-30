D=what('platform_defaultmodels');
delete([D.path,'\*.mat'])

%% PEER 2018 SET 1
inputfile = 'PEER2018_Set1_Test1_1.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_2.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_3.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_4.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_5.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_6.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_7.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_8a.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_8b.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_8c.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_10.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set1_Test1_11.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');


%% PEER 2018 SET 2
inputfile = 'PEER2018_Set2_Test2_1.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set2_Test2_2a.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set2_Test2_2b.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set2_Test2_2c.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set2_Test2_2d.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set2_Test2_3a.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set2_Test2_3b.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set2_Test2_3c.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER2018_Set2_Test2_3d.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

%% PEER 2010 SET 1
inputfile = 'PEER_Set1_Case1.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case1_ECEF.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);  %#ok<*ASGLU>
model = process_model(sys,opt); %#ok<*NASGU>
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case2.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case3.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');


inputfile = 'PEER_Set1_Case4.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case5.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case6.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case7.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case8a.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case8b.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case8c.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case9a.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case9b.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case9c.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case10.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case11.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'PEER_Set1_Case12.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

%% CHILE, PERU
inputfile = 'MexicoCity_CU_PreviousTectonic_2018_f2.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile); %#ok<*ASGLU>
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'Mexico_Default_not_CU.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile); %#ok<*ASGLU>
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'Chile_Default.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile); %#ok<*ASGLU>
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'Chile_Poulos.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile); %#ok<*ASGLU>
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'Peru_Default.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

inputfile = 'Peru_Default_Declustering.txt';
matfile=regexp(inputfile,'\.txt','split');
[sys,opt,h]= loadPSHA(inputfile);
model = process_model(sys,opt);
D=what('platform_defaultmodels'); save([D.path,'\',matfile{1}],'model','h','sys','opt');

disp('done')