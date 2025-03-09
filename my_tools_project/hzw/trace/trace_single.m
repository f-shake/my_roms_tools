function [traceResult,r,ioa,mb]=trace_single(nc,year,months,pollution,bdy,repeatIndex,showGraph,showText,riverFile)
    project_data
    %% 观测值处理
    [obss,sites,~,~]=get_observations_of_all(projectData.obsRange(:,1),projectData.obsRange(:,2),year,months);

    [xy,water,outOfRange]=roms_get_xy_by_lonlat_core(obss(:,1:2),nc,"rho",0,0,enable=false);
    obsFilter=~outOfRange&water;

    obss=obss(obsFilter,:);
    xy=xy(obsFilter,:);

    %% 插值

    [lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
    interpolantFilter=inpolygon(lon_rho,lat_rho,projectData.interpolantObsRange(:,1),projectData.interpolantObsRange(:,2));
    interpolantFilter=interpolantFilter&mask_rho==1;
    interpolantPollutionObsCount=length(find(interpolantFilter==1));
    F=scatteredInterpolant(obss(:,1),obss(:,2),obss(:,pollution+2),"nearest","nearest");
    interpolatedPollutionObs=F(lon_rho,lat_rho);
    interpolatedPollutionObs(interpolantFilter==0)=nan;

    %% 获取时间
    configs
    times=roms_get_times(nc);
    timeFilter=ismember(month(times),months);

    %% 模拟值合成
    dyes=cell(traceData.partCount+1,1);
    for i=1:traceData.partCount+1
        dyes{i}=roms_get_dye(nc,i+(repeatIndex-1)*(traceData.partCount+1),0);
    end

    c=ones([size(lon_rho),traceData.partCount]);

    for j=1:traceData.partCount
        dye=mean(mean(dyes{j}(:,:,:,timeFilter),4),3);
        c(:,:,j)=dye;
    end
    bdyObs=mean(mean(dyes{end}(:,:,:,timeFilter),4),3);

    o=interpolatedPollutionObs-bdyObs.*bdy;
    o=o(interpolantFilter);
    temp=zeros(interpolantPollutionObsCount,traceData.partCount);
    for i=1:traceData.partCount
        t=c(:,:,i);
        temp(:,i)=t(interpolantFilter);
    end
    c=temp;
    %% 获取污染源流量
    if ~exist('riverFile','var') || isempty(riverFile)
        riverFile=fullfile(roms.project_dir,roms.input.rivers);
    end
    transport=ncread(riverFile,'river_transport');
    transport=mean(transport(:,months),2);
    fluxs=zeros(traceData.partCount,1);
    for i=1:traceData.partCount
        river_dye=ncread(riverFile,['river_dye_0',num2str(i)]);
        river_dye=river_dye(:,1,1);
        fluxs(i)=sum(transport(river_dye>0));
    end

    %% 最小二乘
    opt=optimset('display','off');
    try
        lsqlinResult=lsqlin(c,o,-eye(traceData.partCount),-zeros(traceData.partCount,1),[],[],[],[],[],opt);
    catch
        lsqlinResult=nan(traceData.partCount,1);
    end
    lsqlinResult(end+1)=bdy;

    %% 重建
    sim_value=zeros(size(lon_rho));

    for i=1:traceData.partCount+1
        time=int16(size(dyes{i},4)/2):size(dyes{i},4);
        dye=dyes{i};
        dye=mean(mean(dye(:,:,:,time),4),3);
        dye=dye*lsqlinResult(i);
        sim_value=sim_value+dye;
    end

    lsqlinResult=lsqlinResult(1:end-1);
    %           溯源结果应当也是DIN和DIP而不是TN和TP，所以无关因子
    %             result=result/projectData.factor(pollution);
    %             sim_value=sim_value/projectData.factor(pollution);
    %% 计算误差
    ps=zeros(size(xy,1),1);
    os=zeros(size(xy,1),1);
    for i=1:size(obss,1)
        os(i)=obss(i,pollution+2);
        ps(i)=sim_value(xy(i,1),xy(i,2));
    end

    [r,p]=corrcoef(os,ps);
    p=p(2);
    r=r(2);
    ioa=1 - ( ...
        sum((os - ps).^2)  ...
        /sum((       abs(ps - mean(os)) + abs(os - mean(os)) ).^2 ) ...
        );
    mb=1/length(os)*sum(ps-os);

    %% 文本输出
    format short g
    disp("权重：")
    disp('      资料通量      溯源通量       溯源浓度      差异')
    traceFluxs=fluxs.*lsqlinResult;
    refFluxs=traceData.refFluxs(pollution,:)'; %参考污染物通量
    refConcentration=traceData.refConcentration(pollution,:)';
    traceFluxDiff=string(round((traceFluxs(traceData.riverPartCount+1:end)-refFluxs)./refFluxs*100,1));
    traceFluxDiff(ismissing(traceFluxDiff))='';

    traceConcentrationDiff=string(round((lsqlinResult(1:traceData.riverPartCount)-refConcentration)./refConcentration*100,1));
    traceConcentrationDiff(ismissing(traceConcentrationDiff))="";

    traceResult=traceFluxs;
    %traceResult(1:traceData.riverPartCount)=traceResult(1:traceData.riverPartCount)./fluxs(1:traceData.riverPartCount);
    traceResult=[traceResult(1:traceData.riverPartCount)./fluxs(1:traceData.riverPartCount);traceResult];   
    for i=1:1:traceData.partCount
        if i<=traceData.riverPartCount
            fprintf('%15.0f %15.0f %15.2f %15s\n',nan,traceFluxs(i),lsqlinResult(i),traceConcentrationDiff(i));
        else
            fprintf('%15.0f %15.0f %15.2f %15s\n',refFluxs(i-traceData.riverPartCount),traceFluxs(i),lsqlinResult(i),traceFluxDiff(i-traceData.riverPartCount));
        end
    end
    fprintf('R=%.2f, p<%.2f \n',r,ceil(p*100)/100);
    disp(['共',num2str(length(xy)),'个观测点'])

    %% 绘图
    if showGraph
        figure(1)
        draw_background(lon_rho,lat_rho);
        show_simulation_and_observation_core(lon_rho,lat_rho,sim_value,obss(:,1),obss(:,2),obss(:,pollution+2), ...
            "pcolor",1,showText,string(obss(:,pollution+2)))
        projectData.obsRange(end+1,:)=projectData.obsRange(1,:);

        caxis([bdy,projectData.maxValue(pollution)]);
        apply_font
        colormap(parula(projectData.colormapSteps(pollution)))

        figure(2)
        draw_background(lon_rho,lat_rho);
        pcolorjw(lon_rho,lat_rho,interpolatedPollutionObs);
        hold on
        plot(obss(:,1),obss(:,2),'.w')
        caxis([bdy,projectData.maxValue(pollution)]);
        apply_font
        colormap(parula(projectData.colormapSteps(pollution)))
    end
end