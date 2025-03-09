function [r,p,ioa,mb,os,ps,sites]=compare_single(nc,years,months,pollutionIndex,dyeIndex,hasObs,showGraph,graphType)
    project_data

    %% 观测数据处理
    if hasObs
        [obs,sites]=get_observations_of_all(projectData.obsRange(:,1),projectData.obsRange(:,2),years,mod(months-1,12)+1);

        [xy,water,outOfRange]=roms_get_xy_by_lonlat_core(obs(:,1:2),nc,"rho",0,0,enable=false);
        f=~outOfRange&water;

        xy=xy(f,:);
        obs=obs(f,:);
        sites=sites(f);
    end
    %% 模拟数据处理
    sim_value=roms_get_dye(nc,dyeIndex)*projectData.factor(pollutionIndex);

    times=roms_get_times(nc);
    ncyears=year(times);
    ncmonths=month(times)+(ncyears-ncyears(1))*12;
    timeFilter=ismember(ncmonths,months);
    sim_value=mean(mean(sim_value(:,:,:,timeFilter),4),3);



    %% 误差计算
    if hasObs
        ps=zeros(size(xy,1),1);
        os=zeros(size(xy,1),1);
        for i=1:size(obs,1)
            os(i)=obs(i,2+pollutionIndex);
            ps(i)=sim_value(xy(i,1),xy(i,2));
        end

        [r,p]=get_r(os,ps);
        ioa=get_ioa(os,ps);
        mb=get_mb(os,ps);
    else
        r=[];
        p=[];
        ioa=[];
        mb=[];
        os=[];
        ps=[];
        sites=[];
    end
    if showGraph

        [sim_x,sim_y]=roms_load_grid_rho;
        %% 地图绘制
        figure(1)
        draw_background(sim_x,sim_y);
        if hasObs
            show_simulation_and_observation_core(sim_x,sim_y,sim_value,obs(:,1),obs(:,2),obs(:,2+pollutionIndex),graphType,1,0,string(obs(:,2+pollutionIndex)));
        else
            show_simulation_and_observation_core(sim_x,sim_y,sim_value,zeros(0),zeros(0),zeros(0),graphType,1,0,string(0));
        end
        caxis([projectData.bdy(pollutionIndex),projectData.maxValue(pollutionIndex)]);

        apply_font

        %% 相关系数图绘制
        if hasObs
            figure(2);
            scatter(ps,os,10,'filled','k')
            hold on
            plot([0,10],[0,10])
            plot([0,5],[0,10],'--',Color=[.5,.5,.5])
            plot([0,10],[0,5],'--',Color=[.5,.5,.5])
            xlim([0,projectData.maxValue(pollutionIndex)])
            ylim([0,projectData.maxValue(pollutionIndex)])
            apply_font
        end
    end

    %% 输出
    disp ==========================
    disp("示踪剂编号=" +num2str(pollutionIndex)+"   月份="+num2str(months))
    if hasObs
        disp("  r="+num2str(r))
        disp("共"+num2str(length(sites))+"个站点")
        disp("观测值与模拟值之差的平均值="+num2str(mean(os-ps)))
    end
end
