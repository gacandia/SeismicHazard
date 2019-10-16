function[handles]=dsha_assembler(handles)

sites   = cell2mat(handles.h.p(:,2:4));
Vs30    = handles.h.Vs30;
opt     = handles.opt; 
Ns      = size(handles.scenarios,1);
r0      = gps2xyz(sites,opt.ellipsoid);
handles.hdist = computeh(r0);  % move from here

home
fprintf('\n');
spat  = '%-80s     Runtime:  %-4.3f s\n';
t0 = tic;
fprintf('                                      DETERMINISTIC HAZARD ANALYSIS \n');
fprintf('---------------------------------------------------------------------------------------------------------\n');
shakefield = dsha_shake(handles.model,handles.scenarios,opt);
fprintf(spat,'   Shakefield Assembler',toc(t0));

warning off
parfor i=1:Ns
    shakefield(i)   = dsha_gmpe(shakefield(i),r0,Vs30,opt);
end
warning on
fprintf(spat,'   Ground Motion Model',toc(t0));
handles.shakefield=shakefield;

handles.L  = dsha_chol(handles.shakefield,handles.hdist,handles.opt);
fprintf(spat,'   Correlation Structure',toc(t0));

fprintf('---------------------------------------------------------------------------------------------------------\n');
fprintf('%-85sTotal:     %-4.3f s\n','',toc(t0));

