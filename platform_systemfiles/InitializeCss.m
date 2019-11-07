function handles=InitializeCss(handles)

rmin  = 0;
rmax  = 600;
dr    = 60;
mmin  = 5;
mmax  = 9;
dm    = 0.2;
handles.Rbin   = [(rmin:dr:rmax-dr)',(rmin:dr:rmax-dr)'+dr];
handles.Mbin   = [(mmin:dm:mmax-dm)',(mmin:dm:mmax-dm)'+dm];
handles.scenarios   = cell(0,9);
handles.tessel      = {[],zeros(0,2)};

handles.opt.MagDiscrete   = {'uniform' 0.1};
handles.model = process_model(handles.sys,handles.opt);
handles.isREGULAR = find(horzcat(handles.model.isregular)==1);
handles.isPCE     = find(horzcat(handles.model.isregular)==0);


isREGULAR = handles.isREGULAR;
handles.model = handles.model(isREGULAR);
[~,B]=setdiff(handles.sys.BRANCH(:,2),isREGULAR);
set(handles.pop_branch,'value',1);
set(handles.pop_branch,'string',{handles.model.id});
if ~isempty(B)
    handles.sys.BRANCH(B,:)=[];
    handles.sys.WEIGHT(B,:)=[];
    handles.sys.WEIGHT(:,4)=handles.sys.WEIGHT(:,4)/sum(handles.sys.WEIGHT(:,4));
    warndlg('PCE Models removed from logic tree. Weights were normalized')
    uiwait
end
set(handles.pop_site,'string',handles.h.id);


fig = handles.figure1;
delete(findall(fig,'type','line'));
delete(findall(fig,'tag','patch'));
delete(findall(fig,'tag','legend_ax1'));
set(findall(fig,'type','axes'),'ColorOrderIndex',1);
set(fig, 'WindowButtonMotionFcn', '');
drawnow
handles.xlabel1  = xlabel(handles.ax1,'Sa(T)','fontsize',8);
handles.ylabel1  = ylabel(handles.ax1,'\lambda Sa(T)','fontsize',8);
handles.param    = {2,'1','0.01 - 2','0.04 - 0.4','2 - 8',1,'0 - 1000','150 - 3000','5 - 150','0 - 3000','0 - 1000','32','1000','700 - 0.01','100'};
handles.Tcss     = [0.010;0.050;0.075;0.100;0.150;0.200;0.250;0.300;0.400;0.500;0.750;1.000;1.500;2.000];
handles.AEP      = [0.01;0.0045;0.002;0.001;0.00025;0.0001;4e-05;6e-06;1e-06;1e-07;1e-08];
handles.corrV    = 7;
handles.flatfile = '';
handles.Npreselect = 0;
handles.im1        = [];
handles.lambda1    = [];
handles.lambda2    = [];
handles.T          = [];
handles.eq         = [];
