% 用于统计变量var1过了几天以后和变量var2的相关性最高。
% 本来是打算找出浮游植物出现峰值后几天浮游动物也大量繁殖，
% 但重复测试后总是发现时间越接近相关系数越高。
% 因此该分析放弃。

configs
project_data
var1="chlorophyll_sur";
var2="zooplankton_sur";
dir="BASEq";
maxSteps=5*8;
skip=20;
full=1;
stepPerDay=8;


results=zeros(maxSteps+1,1);
[lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
filter=mask_rho==1;
filter=filter&inpolygon(lon_rho,lat_rho,bioData.dh(:,1),bioData.dh(:,2));

times=roms_get_times(read_data(dir,"ocean_time"));
dayStep=days(times(2)-times(1));

xy=roms_get_xy_by_lonlat_core(bioData.locations(1,:),enable=0);


if full
    var1Data=read_data(dir,var1);
    var2Data=read_data(dir,var2);
else
    var1Data=read_data(dir,var1,[xy(1)-5,xy(2)+5,1],[11,11,0]);
    var2Data=read_data(dir,var2,[xy(1)-5,xy(2)+5,1],[11,11,0]);
    var1Data=squeeze(mean(var1Data,[1,2],'omitnan'));
    var2Data=squeeze(mean(var2Data,[1,2],'omitnan'));
end
for steps=0:maxSteps
    disp(steps);
    totalData1=[];
    totalData2=[];
    for i=steps+1:skip:length(times)
        if full
            data1=var1Data(:,:,i-steps);
            data2=var2Data(:,:,i);
            data1=data1(filter);
            data2=data2(filter);
        else
            data1=var1Data(i-steps);
            data2=var2Data(i);
        end
        totalData1=[totalData1,data1];
        totalData2=[totalData2,data2];
    end
    results(steps+1)=get_r(totalData1,totalData2);
end
[~,maxI]=max(results);
plot((0:maxSteps)/stepPerDay,results)
hold on
plot((maxI-1)/stepPerDay,results(maxI),'o')