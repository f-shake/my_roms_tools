project_data

dataType="argo"; %https://argo.ucsd.edu/，原始数据
dataType="aoml"; %https://www.aoml.noaa.gov/phod/gdp/interpolated/data/all.php，插值后的数据

romsNC=bioData.qck;
dim=3; %3：仅表面；4：包含深度
timeSelectType=1; %1：对于一天内包含多个时刻的记录，对同一天的数据作平均；2：对于时刻间隔>1天的，取最近时间的温度
timeOffset=0;

obsLon=[];
obsLat=[];
obsDates=[];
obsTs=[];
[rLON,rLAT,rMASK]=roms_load_grid_rho;

if dataType=="argo"
    argoDir="data/argo";
    argoFiles=string(ls(argoDir+"/*.nc"));
    argoFiles=fullfile(argoDir,argoFiles);
    for file=argoFiles'
        disp(file)
        lons=read_data(file,"LONGITUDE");
        lats=read_data(file,"LATITUDE");
        temps=read_data(file,"TEMP");
        qcs=read_data(file,"TEMP_QC");
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
        y = str2double(fileName(1:4));
        m = str2double(fileName(5:6));
        d = str2double(fileName(7:8));

        dt = datenum(y, m, d);
        obsDates=[obsDates;repmat(dt,length(obsLon)-length(obsDates),1)];

    end
elseif dataType=="aoml"
    if ~exist('T','var')
        path=string(ls('data/buoydata_15001_*.dat'));
        path="data/"+path(1);
        ds = tabularTextDatastore(path,'TreatAsMissing','NA');
        count=0;
        T=[];
        while hasdata(ds)
            tempData=read(ds);
            filter=ones(length(tempData.Var1),1);
            filter=filter&tempData.Var4==2021;
            filter=filter&tempData.Var5>min(rLAT(:));
            filter=filter&tempData.Var5<max(rLAT(:));
            filter=filter&tempData.Var6>min(rLON(:));
            filter=filter&tempData.Var6<max(rLON(:));
            filter=filter&tempData.Var7<100;
            count=count+ds.ReadSize;
            tempData=tempData(filter,:);
            if size(tempData,1)>0
                if isempty(T)
                    T=tempData;
                else
                    T=[T;tempData];
                end
            end
            disp("已读取"+string(count)+"行，已筛选"+string(size(T,1))+"行");
        end
    end

    obsLon=zeros(size(T,1),1);
    obsLat=zeros(size(T,1),1);
    obsDates=zeros(size(T,1),1);
    obsTs=zeros(size(T,1),1);
    for row=1:size(T,1)
        obsDates(row)=datenum(T.Var4(row),T.Var2(row),round(T.Var3(row)));
        obsLon(row)=T.Var6(row);
        obsLat(row)=T.Var5(row);
        obsTs(row)=T.Var7(row);
    end
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
    romsTemp=read_data(romsNC,'temp_sur');
elseif dim==4
    romsTemp=read_data(romsNC,'temp');
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

%% 画图

clf
tl=tiledlayout(1,2);
set_tiledlayout_compact(tl);

nexttile
%histogram2(simTs,obsTs,[50,50],DisplayStyle='tile',FaceColor='flat')
if length(obsTs)<=1000
    plot(obsTs,simTs,'.')
else
    histogram2(obsTs,simTs,[100,100],'FaceColor','flat','DisplayStyle','tile')
end
hold on
plot([0,50],[0,50],'-')
minValue=min([obsTs;simTs]);
maxValue=max([obsTs;simTs]);
xlim([minValue,maxValue]);
ylim([minValue,maxValue]);
xlabel(strs.axis_obsValue)
ylabel(strs.axis_simValue)
apply_font
equal_aspect_ratio(gca)
set_gcf_size(300)
xticks(10:2:30)
yticks(10:2:30)
draw_border

[r,p]=get_r(obsTs,simTs);
ioa=get_ioa(obsTs,simTs);
mb=get_mb(obsTs,simTs);

text = sprintf("MB=%.3f\nr=%.2f*\nIOA=%.2f", round(mb, 3), round(r, 2), round(ioa, 2));
text_corner(text, 'rb');
text_corner("(a)","lt")


t=nexttile;
draw_map(rMASK,'lgf')
colormap(t,[1,1,1;0,0,0])
hold on
scatterm(obsLat,obsLon,6,'filled')
xlabel(strs.axis_latitude)
ylabel(strs.axis_longitude)
text_corner("(b)","lt")


set_gcf_size(600,300)