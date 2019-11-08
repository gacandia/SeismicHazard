function[handles]=dsha_assembler2(handles)

Vs30    = handles.h.Vs30;
opt     = handles.opt; 
r0      = gps2xyz(handles.h.p,opt.ellipsoid);

home
fprintf('\n');
spat  = '%-80s     Runtime:  %-4.3f s\n';
t0 = tic;
fprintf('                                      DETERMINISTIC HAZARD ANALYSIS \n');
fprintf('---------------------------------------------------------------------------------------------------------\n');
handles.shakefield = dsha_shake2(handles.model,handles.scenarios,opt);
Ngroup = length(handles.shakefield);
fprintf(spat,'   Shakefield Assembler',toc(t0));

for i=1:Ngroup
    
    handles.shakefield(i)   = dsha_gmpe2(handles.shakefield(i),r0,Vs30,opt);
end

fprintf(spat,'   Ground Motion Model',toc(t0));

handles.hdist = computeh(r0);  % move from here
handles.L     = dsha_chol2(handles.shakefield,handles.hdist,handles.opt);
fprintf(spat,'   Correlation Structure',toc(t0));

fprintf('---------------------------------------------------------------------------------------------------------\n');
fprintf('%-85sTotal:     %-4.3f s\n','',toc(t0));

