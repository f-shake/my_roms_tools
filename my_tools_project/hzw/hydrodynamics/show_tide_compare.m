function show_tide_compare(nc,obsFiles,start,stop,stations,names,dayOffset,obsFactor,zOffset,smoothWindow)
    arguments
        nc(1,1) string %nc文件
        obsFiles(:,1) string %观测文件。每一行分别为年、月、日、小时、分钟、高度，\t隔开
        start(1,3) double {mustBeInteger} %开始时间
        stop(1,3) double {mustBeInteger} %结束时间
        stations(:,2) double %站点位置（网格坐标）
        names(:,1) string %站点名
        dayOffset(1,1) double =0 %模拟值和观测值的偏移
        obsFactor(1,1) double =1 %观测值需要乘的系数
        zOffset(:,1) double =zeros(size(obsFiles,1),1) %观测值整体高度偏移
        smoothWindow(1,1) double =0; %模拟值的平滑窗口，0表示不平滑
    end
    configs
    project_data
    start=datetime(start);
    stop=datetime(stop);
    if endsWith(nc,".mat")
        times=load(nc,'times');
        times=times.times;
        zeta=load(nc,'zeta');
        zeta=zeta.zeta;
    else
        times=ncread(nc,'ocean_time');
        zeta=ncread(nc,'zeta');
    end
    if smoothWindow>0
        zeta=smoothdata(zeta,'movmean',smoothWindow);
    end
    times=roms_get_times(times,8)+dayOffset;
    timeFilter=times>start & times<stop;
    times=times(timeFilter);
    zeta=zeta(:,:,timeFilter);
    clf
    figure(1)
    t1=tiledlayout(length(names),1);
    set_gcf_size(900,350)
    figure(2)
    t2=tiledlayout(1,length(names));
    set_gcf_size(300*length(names),300)
    set_tiledlayout_compact(t1,t2);
    for i=1:length(names)
        obs=obsFiles(i);
        obs=readmatrix(obs);
        obsTimes=datetime([],[],[]);
        obsHeights=[];
        for line=obs'
            time=datetime([line(1:5)',0]);
            if time>start && time<stop && (isempty(obsTimes) || time~=obsTimes(end))
                obsTimes(end+1)=time;
                obsHeights(end+1)=line(end);
            end
        end
        obsTimeNums=datenum(obsTimes);
        obsHeights=obsHeights-mean(obsHeights);
        obsHeights=obsHeights*obsFactor;
        obsHeights=obsHeights+zOffset(i);
        z=squeeze(zeta(stations(i,1),stations(i,2),:));
        z=z-mean(z);

        F=griddedInterpolant(datenum(times),z);
        interpolatedSimHeight=F(obsTimeNums);

        x=obsHeights;
        y=interpolatedSimHeight;

        nexttile(t1);
        plot(times,z,'-r',LineWidth=1);
        hold on
        plot(obsTimes,obsHeights,'.',Color=[0.5,0.5,0.5,0.5],MarkerSize=8)
        datetick('x','dd')
        xlim([start,stop])
        text_left_top(names(i),0.012);
        text_right_bottom("r="+round(get_r(x,y),2) + newline + ...
            "ioa="+round(get_ioa(x,y),2),0.06,0.24,1,1)
        apply_font

        ax=nexttile(t2);
        scatter(x,y,10,'filled');
        hold on
        m=max([x,y])*1.05;
        if ~isempty(m)
            plot([-m,m],[-m,m],'k');
            xlim([-m,m]);
            ylim([-m,m])
        end
        r=corrcoef(x,y);
        r=r(2);
        equal_aspect_ratio(ax);
        text_left_top([char(names(i)),' r=',num2str(r,2)]);
        draw_border
        apply_font
    end
    figure(1)
    xlabel(t1,strs.axis_time_day)
    ylabel(t1, strs.axis_height)
    legend([strs.legend_simulations,strs.legend_observations],Location='southwest',Orientation='horizontal');

    figure(2)
    xlabel(t2,"\newline "+strs.axis_obsValue) %不换行会错位，不知道为什么
    ylabel(t2,strs.axis_simValue)

    apply_font(t1,t2);