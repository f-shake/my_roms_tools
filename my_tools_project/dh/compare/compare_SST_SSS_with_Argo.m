project_data

romsNC=bioData.qck;
dim=3; %3：仅表面；4：包含深度
timeSelectType=1; %1：对于一天内包含多个时刻的记录，对同一天的数据作平均；2：对于时刻间隔>1天的，取最近时间的温度
timeOffset=0;
forceYear=2021;

[rLON,rLAT,rMASK]=roms_load_grid_rho;


argoDir="data/argo";
argoFiles=string(ls(argoDir+"/*.nc"));
argoFiles=fullfile(argoDir,argoFiles);
allObsLons=[];
allObsLats=[];
clf
tl=tiledlayout(1,3);
romsVars=["temp","salt"];
argoVars=["TEMP","PSAL"];
units=["°C","PSU"];
ticks={10:5:30,32:1:36};
ranges=[8,32;31.8,35.2];
labels=[bioData.varName.temp,bioData.varName.salt];

for dataType=1:2
    obsLon=[];
    obsLat=[];
    obsDates=[];
    obsTs=[];
    for file=argoFiles'
        % disp(file)
        lons=read_data(file,"LONGITUDE");
        lats=read_data(file,"LATITUDE");
        temps=read_data(file,argoVars(dataType));
        qcs=read_data(file,argoVars(dataType)+"_QC");
        qcs=qcs(1,:)';
        filter=ones(length(lons),1);
        filter=filter&lats>min(rLAT(:));
        filter=filter&lats<max(rLAT(:));
        filter=filter&lons>min(rLON(:));
        filter=filter&lons<max(rLON(:));
        filter=filter&qcs=='1';
        obsLon=[obsLon;lons(filter)];
        obsLat=[obsLat;lats(filter)];
        obsTs=[obsTs;temps(1,filter)'];
        for i=find(filter)'
            if(temps(1,i)<5)
                a=1;
            end
        end

        [~, fileName, ~] = fileparts(file);
        fileName=char(fileName);
        if forceYear>0
            y = forceYear;
        else
            y = str2double(fileName(1:4));
        end
        m = str2double(fileName(5:6));
        d = str2double(fileName(7:8));

        dt = datenum(y, m, d);
        obsDates=[obsDates;repmat(dt,length(obsLon)-length(obsDates),1)];

    end


    %% 寻找对应时刻、对应位置的ROMS中的温度
    [xy,waterPoint,outOfRange]=roms_get_xy_by_lonlat_core([obsLon,obsLat],{rLON,rLAT,rMASK},"rho",0,enable=0);
    xy=xy(waterPoint,:);
    obsTs=obsTs(waterPoint);
    obsLon=obsLon(waterPoint);
    obsLat=obsLat(waterPoint);
    obsDates=obsDates(waterPoint);
    s=size(xy,1);

    [romsTimes,romsTimeDays]=roms_get_times(read_data(romsNC,'ocean_time'));
    if dim==3
        romsTemp=read_data(romsNC,romsVars(dataType)+"_sur");
    elseif dim==4
        romsTemp=read_data(romsNC,romsVars(dataType));
    end
    simTs=zeros(s,1);


    for i=1:s
        if timeSelectType==1
            filter=round(romsTimeDays)+timeOffset==obsDates(i);
            indexs=find(filter);
            if dim==3
                simT=romsTemp(xy(i,1),xy(i,2),indexs);
            elseif dim==4
                simT=romsTemp(xy(i,1),xy(i,2),end,indexs);
            end
            simT=mean(simT(:));
        elseif timeSelectType==2
            timeDistance=abs(romsTimeDays-obsDates(i)+timeOffset);
            [~,minTimeDistIndex]=min(timeDistance);
            minTime=romsTimes(minTimeDistIndex);
            if dim==3
                simT=romsTemp(xy(i,1),xy(i,2),minTimeDistIndex);
            elseif dim==4
                simT=romsTemp(xy(i,1),xy(i,2),end,minTimeDistIndex);
            end
        end
        simTs(i)=simT;
    end

    filter=abs(simTs-obsTs)<10; %温差大于10℃，认为是异常数据
    simTs=simTs(filter);
    obsTs=obsTs(filter);
    obsLon=obsLon(filter);
    obsLat=obsLat(filter);

    allObsLons=[allObsLons;obsLon];
    allObsLats=[allObsLats;obsLat];

    %% 画图

    nexttile
    %histogram2(simTs,obsTs,[50,50],DisplayStyle='tile',FaceColor='flat')
    if length(obsTs)<=1000
        plot(obsTs,simTs,'.')
    else
        histogram2(obsTs,simTs,[100,100],'FaceColor','flat','DisplayStyle','tile')
    end
    hold on
    plot([0,50],[0,50],'-')
    xlim(ranges(dataType,:));
    ylim(ranges(dataType,:));
    xlabel(strs.axis_obsValue+" ("+units(dataType)+")");
    ylabel(strs.axis_simValue+" ("+units(dataType)+")");
    apply_font
    equal_aspect_ratio(gca)
    set_gcf_size(300)
    xticks(ticks{dataType})
    yticks(ticks{dataType})
    draw_border

    [r,p]=get_r(obsTs,simTs);
    ioa=get_ioa(obsTs,simTs);
    mb=get_mb(obsTs,simTs);
    
    fprintf("MB=%.3f r=%.2f p=%.5f IOA=%.2f \n",mb,r,p,ioa)
    text = sprintf("MB=%.3f\nr=%.2f*\nIOA=%.2f", round(mb, 3), round(r, 2), round(ioa, 2));
    text_corner(text, 'rb');
    text_corner("("+a2z_string(dataType)+") "+labels(dataType),"lt")
end

t=nexttile;
draw_map(rMASK,'lgf')
colormap(t,[1,1,1;0,0,0])
hold on
scatterm(allObsLats,allObsLons,6,'filled')
xlabel(strs.axis_latitude)
ylabel(strs.axis_longitude)
text_corner("(c) "+strs.title_buoyLocations,"lt")


set_gcf_size(750,250)