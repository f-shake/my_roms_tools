function show_tracer_percent_in_each_part(nc,ranges)
    configs
    project_data
    [~,times]=roms_get_times(nc);
    times=times-times(1); %以天为单位的经过时间

    count=size(ranges,3);
    volume=sum(roms_get_volumes,3);
    volumeWithTimes=repmat(volume,1,1,length(times));

    volumesOfPart=zeros(count,1);
    dyes=cell(count,1);
    dyesVolumes=cell(count,1);
    rangeGrids=cell(count,1);
    dyePercent=cell(count);
    dyePercent{:}=zeros(count,1);
    dyeMinPercent{:}=zeros(count,1);

    %对每一个示踪剂进行预处理
    for i=1:count
        if endsWith(nc,".mat")
            dye=load(nc,'dye');
            dye=dye.dye;
        else
            dye=roms_get_dye(nc,i,1);
        end
        dye(isnan(dye))=0;
        dyesVolumes{i}=dye.*volumeWithTimes;
        dyes{i}=dye;
    end
    %计算每个部分的体积
    for i=1:count
        range=ranges(:,:,i);
        grid=get_points_in_range(range,1);
        rangeGrids{i}=grid;
        volumesOfPart(i)=sum(volume(grid==1));
    end

    for k=1:length(times) %k=time
        for i=1:count %i=range
            for j=1:count %j=dye
                dyeVolumeInThisTime=dyesVolumes{j}(:,:,k); %此刻示踪剂j的各网格体积
                thisDyeInThisRangeWeight=sum(dyeVolumeInThisTime(rangeGrids{i}==1)); %此刻，示踪剂j在区域i中的"质量"
                dyePercent{i,j}(k)=thisDyeInThisRangeWeight/volumesOfPart(i); %此刻，示踪剂j在区域i中的质量与初始时刻的百分比
                dye=dyes{j}(:,:,k); %此刻，示踪剂j每个网格的百分比
                dyeMinPercent{i,j}(k)=max(dye(rangeGrids{i}==1),[],'all'); %此刻，示踪剂j在区域i中的示踪剂最大值
            end
        end
    end

    tl=tiledlayout(count,1);
    set_tiledlayout_compact(tl)
    set_gcf_size(400,320);
    for i=1:count %i=range
        nexttile
        for j=1:count %j=dye
            dayMin=dyeMinPercent{i,j};
            plot(times,dayMin,Color=[0, 66, 206]/255);
            hold on
            plot(times,dyePercent{i,j},'-',Color=[0.7,0.7,0.7]);
            smoothed=smoothdata(dyePercent{i,j},'movmean',12*24);
            plot(times,smoothed,'r');
            xline(times(find(smoothed<0.5,1)),'-.')
            xline(times(find(dayMin<0.5,1)),'-.')
            text(times(find(smoothed<0.5,1)),0,string(ceil(times(find(smoothed<0.5,1)))),VerticalAlignment="bottom")
            text(times(find(dayMin<0.5,1)),0,string(ceil(times(find(dayMin<0.5,1)))),VerticalAlignment="bottom")

        end
        apply_font
        xlabel(strs.axis_time_day)
        ylabel(strs.axis_concentration)
        %legend("水体平均未交换率")
        ylim([0,1])
        xlim([0,max(times)])
        yline(0.5,'--');
        xticks([0:30:180]);
        draw_border
        legend([strs.legend_exchangeDyePercentMin; ...
            strs.legend_exchangeDyePercentAverage; ...
            strs.legend_exchangeDyePercentAverageSmoothed; ...
            "";"";"50%"],Location="northeast")
    end
