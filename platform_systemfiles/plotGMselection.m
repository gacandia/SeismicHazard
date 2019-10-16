function[handles]=plotGMselection(handles,ind)

xs = handles.axes3.XScale;
ys = handles.axes3.YScale;

g    = 9.80665;
spec = handles.spec;
T    = spec.T;

switch handles.accunits
    case 'g'     , accConv = g;
    case 'm/s2'  , accConv = 1;
    case 'cm/s2' , accConv = 0.1;
end

do_acc=1;
do_vel=0;
do_dis=0;
switch handles.Display_group.Title
    case 'Velocity Display Options',     do_vel=1;
    case 'Displacement Display Options', do_dis=1;
end

data       = handles.tabla.Data;
i          = ind(1);
j          = ind(2);
switch handles.buttomselected
    case 1, tagname    = [num2str(i),'_',num2str(j),'_1'];
    case 2, tagname    = [num2str(i),'_',num2str(j),'_2'];
    case 3, tagname    = [num2str(i),'_',num2str(j),'_3'];
end

ROOT     = handles.pathname;
EQ       = data{i,3};
FILE     = data{i,j};

%% CHECKS IF PLOT EXISTS
LIN=findall(handles.axes3,'type','line');
ch=findall(handles.axes3,'type','line');
set(ch,'Linewidth',0.5);

for ii=1:length(LIN)
    if strcmp(tagname,LIN(ii).Tag) && handles.AutoTrimPushed==0
        LIN(ii).LineWidth=1.5;
        handles.axes3.XScale=xs;
        handles.axes3.YScale=ys;
        return
    end
end

%% MANAGES ADD/REPLACE OPTION
filea = regexp(FILE,'\.','split');
[DT,ACC] =deal(NaN);

overwrite = handles.overwrite(i,:);
do_overwrite = any(overwrite~=0);

switch handles.HoldPlot.Value
    case 0, handles.axes3.NextPlot	='replace';
        ch=findall(handles.axes3,'type','line');
        delete(ch);
    case 1, handles.axes3.NextPlot	='add';
end

%% record retrieve module
switch filea{end}
    case 'at2'
        STR  = regexp(FILE,'\/','split');
        STR  = STR{end};
        NGA_ID     = data{i,1};
        FILENAME   = ['NGA_no_',num2str(NGA_ID),'_',STR];
        FULLPATH   = fullfile(ROOT,FILENAME);
        if exist(FULLPATH,'file')
            [DT,ACC] = readNGA(FULLPATH);
            ACC = ACC*accConv; % all to m/s2
        end
    case 'txt' % SIBER-RISK FILES
        FULLPATH = fullfile(ROOT,EQ,FILE);
        [DT,ACC] = readSIBERRISK(FULLPATH);
        ACC = ACC*accConv; % all to m/s2 
end

TIME = (0:length(ACC)-1)*DT;

%% manual trimming module
if do_overwrite && handles.AutoTrimPushed==0
    ACC=ACC(and(TIME>=overwrite(1)  ,TIME<=overwrite(2)));
    TIME=TIME(and(TIME>=overwrite(1),TIME<=overwrite(2)));
    TIME=TIME-TIME(1);
end

%% auto trimming mode
if handles.AutoTrimPushed==1
    
    ACCN=cumsum(ACC.^2)./sum(ACC.^2);
    tt1 = handles.paramAuto(1);
    tt2 = handles.paramAuto(2);
    ACC = ACC(and(tt1<ACCN,ACCN<tt2));
    TIME=TIME(and(tt1<ACCN,ACCN<tt2));
    handles.overwrite(i,:)=[TIME(1),TIME(end)];
    TIME=TIME-TIME(1);
end

%% filter module
ACC = butterworth(TIME,ACC,handles.param);

%% plot module
switch handles.buttomselected
    case 1
        
        if ~isempty(handles.gmscale)
            Sa   = spec.method(TIME,ACC,handles.spec,handles.param);
            accf = eq_scaled_GMSELECT(ACC,T,Sa,0,0,handles.gmscale(1),handles.gmscale(2));
        else
            accf = ACC;
        end
        
        if and(do_vel==0,do_dis==0)
            plot(handles.axes3,TIME,accf/g,'tag',tagname,'ButtonDownFcn',{@linecallback,handles});
            xlabel('Time (s)')
            ylabel('acc (g)')
        end
        if do_vel
            accf = freqInt(TIME,accf,1);
            plot(handles.axes3,TIME,accf,'tag',tagname,'ButtonDownFcn',{@linecallback,handles});
            xlabel('Time (s)')
            ylabel('vel (m/s)')
        end
        if do_dis
            accf = freqInt(TIME,accf,2);
            plot(handles.axes3,TIME,accf,'tag',tagname,'ButtonDownFcn',{@linecallback,handles});
            xlabel('Time (s)')
            ylabel('dis (m)')
        end
        
    case 2
        if ~isempty(handles.gmscale)
            Sa  = spec.method(TIME,ACC,handles.spec,handles.param);
            ACC = eq_scaled_GMSELECT(ACC,T,Sa,0,0,handles.gmscale(1),handles.gmscale(2));
        end
        
        if and(do_vel==0,do_dis==0)
            [f,U] = Fou(TIME,ACC,1);
            plot(handles.axes3,f,U,'tag',tagname,'ButtonDownFcn',{@linecallback,handles});
            xlabel('Frequency (Hz)')
            ylabel('Fourier Transform Acc')
        end
        
        if do_vel
            [~,Uf,f] = freqInt(TIME,ACC,1,handles.param);
            Uf(f<0) =[]; f(f<0)  =[];
            plot(handles.axes3,f,abs(Uf),'tag',tagname,'ButtonDownFcn',{@linecallback,handles});
            xlabel('Frequency (Hz)')
            ylabel('Fourier Transform Vel')
        end
        
        if do_dis
            [~,Uf,f] = freqInt(TIME,ACC,2,handles.param);
            Uf(f<0) =[]; f(f<0)  =[];
            plot(handles.axes3,f,abs(Uf),'tag',tagname,'ButtonDownFcn',{@linecallback,handles});
            xlabel('Frequency (Hz)')
            ylabel('Fourier Transform Disp')
        end
        akZoomX(handles.axes3)
        
    case 3
        [Sa,Sv,Sd] = spec.method(TIME,ACC,handles.spec,handles.param);
        if ~isempty(handles.gmscale)
            [~,Sa,Sv,Sd]  = eq_scaled_GMSELECT(ACC,T,Sa,Sv,Sd,handles.gmscale(1),handles.gmscale(2));
        end
        if do_acc, y = Sa/g;end
        if do_vel, y = Sv;  end
        if do_dis, y = Sd;  end
        
        plot(handles.axes3,T,y,'tag',tagname,'ButtonDownFcn',{@linecallback,handles})
        
        xlabel('Period (s)')
        ylabel('Sa (g)')
        if do_vel,ylabel('Sv (m/s)'),end
        if do_dis,ylabel('Sd (m)'),end        
        
end

akZoomX(handles.axes3)
handles.axes3.XScale=xs;
handles.axes3.YScale=ys;
handles.axes3.ButtonDownFcn={@resetselection,handles};


function resetselection(~,~,handles)

handles.curr_ID.String=' ';
handles.curr_earthquake.String=' ';
handles.curr_filename.String=' ';
handles.curr_component.String=' ';

ch=findall(handles.axes3,'type','line');
set(ch,'Linewidth',0.5);