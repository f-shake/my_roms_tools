%% 字符串常量
global strLang
if isempty(strLang)
    strLang="zh";
end
switch strLang
    case "zh"
        strs.axis_longitude="经度";
        strs.axis_latitude="纬度";
        strs.axis_time_day="时间（天）";
        strs.axis_height="相对高度（m）";
        strs.axis_obsValue='观测值';
        strs.axis_simValue='模拟值';
        strs.axis_flowSpeed="流速（m/s）";
        strs.axis_concentration="浓度";
        strs.axis_concentrationMgPerL="浓度（mg/L）";
        strs.axis_simTemp="模拟温度（℃）";
        strs.axis_obsTemp="Argo温度（℃）";
        strs.axis_temp="温度（℃）";
        strs.axis_changePercentage="变化百分比（%）";
        strs.axis_contributionPercentage="贡献百分比（%）";
        strs.axis_concentrationOf=@(var,u) var + "浓度（"+u+"）";
        strs.location_hangzhouBay="杭州湾";
        strs.tide_gp="澉浦";
        strs.tide_zp="乍浦";
        strs.tide_th="滩浒";
        strs.locations=["上海","嘉兴","绍兴","宁波","舟山","甬江","长江","钱塘江"];
        strs.legend_exchangeDyePercentMin="最大浓度";
        strs.legend_exchangeDyePercentAverage="平均浓度";
        strs.legend_exchangeDyePercentAverageSmoothed="平均浓度（平滑）";
        strs.legend_obsStation="观测站";
        strs.legend_simulations="模拟值";
        strs.legend_observations="观测值";
        strs.legend_riverEmissions="河流源";
        strs.legend_sewageOutletEmissions="沿海排污口";
        strs.legend_estimationEmissions="用于估算排放速率的污染源";
        strs.legend_typicalSeaAreas="典型海域";
        strs.legend_estuary="河口";
        strs.colorbar_waterDepth="水深";
        strs.title_seasonNames=["春季","夏季","秋季","冬季"];
        strs.title_pollutionNames=["COD","DIN","PO_4"];
        strs.title_hangzhouBay='杭州湾海水深度及验证潮站图';
        strs.title_dayOf=@(day)"第"+num2str(day)+"天";
        strs.title_firstDayOf=@(day)"前"+num2str(day)+"天";
        strs.title_monthOf=@(m) num2str(m)+"月";
        strs.title_traceParts=["长江","钱塘江","北岸","南岸","舟山"];
        strs.title_changePercentage="变化百分比";
        strs.title_buoyLocations="浮标位置";
        strs.title_stationLocations="测站位置";
    case "en"
        strs.axis_longitude="Longitude";
        strs.axis_latitude="Latitude";
        strs.axis_time_day="Time (Day)";
        strs.axis_height="Relative Height";
        strs.axis_obsValue='Observation';
        strs.axis_simValue='Simulation';
        strs.axis_flowSpeed="Velocity (m/s)";
        strs.axis_concentration="Concentration";
        strs.axis_concentrationMgPerL="Concentration (mg/L)";
        strs.axis_simTemp="Simulated Temperature (°C)";
        strs.axis_obsTemp="Argo Temperature (°C)";
        strs.axis_temp="Temperature (°C)";
        strs.axis_changePercentage="Percentage Change (%)";
        strs.axis_contributionPercentage="Percentage Contribution (%)";
        strs.axis_concentrationOf=@(var,u) var + " Concentration ("+u+")";
        strs.location_hangzhouBay="Hangzhou Bay";
        strs.tide_gp="Ganpu";
        strs.tide_zp="Zhapu";
        strs.tide_th="Tanhu";
        strs.locations=["Shanghai City","Jiaxing City","Shaoxing City",...
            "Ningbo City","Zhoushan City", "Yongjiang estuary","Yangtze estuary","Qiantang estuary"];
        strs.legend_obsStation="Tide observation station";
        strs.legend_exchangeDyePercentMin="Tracer % (Max.)";
        strs.legend_exchangeDyePercentAverage="Tracer % (Ave.)";
        strs.legend_exchangeDyePercentAverageSmoothed="Tracer % (Ave., Smoothed)";
        strs.legend_simulations="Simulations";
        strs.legend_observations="Observations";
        strs.legend_riverEmissions="River source";
        strs.legend_sewageOutletEmissions="Sewage outlet source";
        strs.legend_estimationEmissions="Sources used to estimate discharge rates";
        strs.legend_typicalSeaAreas="Typical sea areas";
        strs.legend_estuary="Estuary";
        strs.colorbar_waterDepth="Bathymetry";
        strs.title_seasonNames=["Spring","Summer","Autumn","Winter"];
        strs.title_pollutionNames=["COD","DIN","PO_4"];
        strs.title_hangzhouBay='Chart of seawater depth and verification tide stations in Hangzhou Bay';
        strs.title_dayOf=@(day)"Day "+num2str(day);
        strs.title_firstDayOf=@(day) num2str(day)+" Days";
        strs.title_monthOf=@(m) convertToEnglishMonth(m);
        strs.title_traceParts=["Yangtze River","Qiantang River","Bay north","Bay south","Zhoushan"];
        strs.title_changePercentage="Percentage Change";
        strs.title_buoyLocations="Buoy locations";
        strs.title_stationLocations="Station locations";
end


%% 项目常量

projectData.pollutionNames=strs.title_pollutionNames;
projectData.studyRange = [121.845 30.8583; 121.7642 29.9742; 121.7 29.8; 121.0722 30.2683; 120.9083 30.3728; 121 31; 121.8 31];
projectData.exchangeRange=[121.845 30.8583; 121.7642 29.9742; 121.7 29.8; 120.6 30; 120.6 31; 121 31; 121.8 31];
projectData.obsRange = [120.9 31.3; 122.6 31.3; 122.6 29.8; 120.9 29.8];
projectData.interpolantObsRange =  [120.8 31.3; 122.6 31.3; 122.6 29.8; 120.8 29.8];
projectData.maxValue=[3,2,0.08];
projectData.colormapSteps= [20 20 16];
projectData.bdy=[.75,.5,.02];
projectData.factor=[1,.89 .65];
projectData.months={4:5,7:9,10:11,12:14};
projectData.comparableMonthIndexs=1:3;
projectData.emissionList="模式输入配置文件/扩散模拟/排放清单.xlsx";
projectData.observationInfo="分析绘图数据/waters.txt";

%% 源强估算常量
traceData.partCount=5;
traceData.riverPartCount=2;
traceData.simFluxs=repmat([30166,1403,100*ones(1,3)],13,1);
traceData.simFluxs(:,1)=traceData.simFluxs(:,1).*[0.49 0.49 0.52 0.65 1.01 1.37 1.60 1.63 1.31 1.05 0.78 0.59 0.49 ]';
traceData.simFluxs(:,2)=traceData.simFluxs(:,2).*[0.53  0.76  0.98  1.12  1.55  1.68  1.08  1.18  1.52  0.67  0.47  0.47 0.53]';

traceData.refFluxs=[
    2000  1100 11
    2900  1100 19
    120  33 0.2
    ];
traceData.refConcentration=[
    2.55 2.175
    1.90 2.08
    .095 .09
    ];
traceData.partNames=strs.title_traceParts;
traceData.pointPerPart=10;
traceData.maxValues=[3,2,0.1];
traceData.repeat=3; %重复次数，生成总数量(partCount+1)*repeat的dye

%% 生态项目常量
bioData.tests=["HNHP","CNCP","CNHP","HNCP"];
bioData.testNames=["HN-HP","CN-CP","CN-HP","HN-CP"];

bioData.avg="CNCP";
bioData.qck="CNCPq";
bioData.dia="CNCPd";
bioData.ignoreOutfalls="IgnoreOutfalls";
switch strLang
    case "zh"
        bioData.considerOutfallName="考虑排污口";
        bioData.ignoreOutfallName="忽略排污口";
    case "en"
        bioData.considerOutfallName="Consider Outfalls";
        bioData.ignoreOutfallName="Ignore Outfalls";
end
switch strLang
    case "zh"
        bioData.locationNames=["长江口","温州","厦门",...
            "长江口东","温州东","外海"
            ];
    case "en"
        bioData.locationNames=[
            "Yangtze"+newline+"Estuary"
            "Wenzhou"+newline+"nearshore"
            "Xiamen"+newline+"nearshore"
            "East of the"+newline+"Yangtze Estuary"
            "East of the"+newline+"Wenzhou nearshore"
            "Open Sea"
            ];
end
bioData.colorRanges.temp=[10,30];
bioData.colorRanges.salt=[27,36];
bioData.colorRanges.NO3=[0,12];
bioData.colorRanges.NH4=[0,2];
bioData.colorRanges.DIN=[0,80];
bioData.colorRanges.PO4=[0,2];
bioData.colorRanges.chlorophyll=[0,6];
bioData.colorRanges.phytoplankton=[0,6];
bioData.colorRanges.zooplankton=[0,3];
bioData.colorRanges.LdetritusN=[0,5];
bioData.colorRanges.LdetritusC=[0,33];
bioData.colorRanges.SdetritusN=[0,9];
bioData.colorRanges.SdetritusC=[0,50];
bioData.colorRanges.DetritusN=[0,15];
bioData.colorRanges.DetritusC=[0,50];
bioData.colorRanges.TIC=[1300,2050];
bioData.colorRanges.alkalinity=[1120,2350];
bioData.colorRanges.oxygen=[200,280];
bioData.colorRanges.denitrification=[0,3];


bioData.diffColorRanges.NO3=5;
bioData.diffColorRanges.DIN=5;
bioData.diffColorRanges.NH4=0.06;
bioData.diffColorRanges.PO4=0.2;
bioData.diffColorRanges.chlorophyll=0.5;
bioData.diffColorRanges.zooplankton=0.3;

bioData.profileColorRanges.temp=[0,30];
bioData.profileColorRanges.NO3=[0,40];
bioData.profileColorRanges.NH4=[0,0.1];
bioData.profileColorRanges.DIN=[0,40];
bioData.profileColorRanges.PO4=[0,3];
bioData.profileColorRanges.chlorophyll=[0,1];
bioData.profileColorRanges.phytoplankton=[0,3];
bioData.profileColorRanges.zooplankton=[0,0.001];
bioData.profileColorRanges.oxygen=[80,250];

bioData.maxDepth.temp=1500;
bioData.maxDepth.NO3=1500;
bioData.maxDepth.DIN=1500;
bioData.maxDepth.NH4=1500;
bioData.maxDepth.PO4=1500;
bioData.maxDepth.chlorophyll=150;
bioData.maxDepth.phytoplankton=1500;
bioData.maxDepth.zooplankton=1500;
bioData.maxDepth.oxygen=1500;

bioData.varName.DIN="DIN";
bioData.varName.NPratio="N/P";
bioData.varName.NO3="NO_3^-";
bioData.varName.NH4="NH_4^+";
bioData.varName.PO4="PO_4^{3-}";
switch strLang

    case "zh"
        bioData.varName.temp="温度";
        bioData.varName.salt="盐度";
        bioData.varName.chlorophyll="叶绿素a";
        bioData.varName.phytoplankton="浮游植物";
        bioData.varName.zooplankton="浮游动物";
        bioData.varName.LdetritusN="大型碎屑（氮）";
        bioData.varName.LdetritusC="大型碎屑（碳）";
        bioData.varName.SdetritusN="小型碎屑（氮）";
        bioData.varName.SdetritusC="小型碎屑（碳）";
        bioData.varName.DetritusN="碎屑（氮）";
        bioData.varName.DetritusC="碎屑（碳）";
        bioData.varName.TIC="无机碳";
        bioData.varName.alkalinity="碱度";
        bioData.varName.oxygen="溶解氧";
        bioData.varName.denitrification="反硝化";
    case "en"
        bioData.varName.temp="Temperature";
        bioData.varName.salt="Salinity";
        bioData.varName.chlorophyll="Chlorophyll-a";
        bioData.varName.phytoplankton="Phytoplankton";
        bioData.varName.zooplankton="Zooplankton";
        bioData.varName.LdetritusN="Large detritus N";
        bioData.varName.LdetritusC="Large detritus C";
        bioData.varName.SdetritusN="Small detritus N";
        bioData.varName.SdetritusC="Small detritus C";
        bioData.varName.TIC="Total CO_2";
        bioData.varName.alkalinity="Alkalinity";
        bioData.varName.oxygen="Dissolved Oxygen";
        bioData.varName.denitrification="Denitrification";
end

bioData.unit.NO3="μmol N L^{-1}";
bioData.unit.DIN="μmol N L^{-1}";
bioData.unit.NH4="μmol N L^{-1}";
bioData.unit.PO4="μmol P L^{-1}";
bioData.unit.chlorophyll="mg L^{-1}";
bioData.unit.zooplankton="μmol N L^{-1}";
bioData.unit.NPratio="ratio";
switch strLang
    case "zh"
        bioData.provinces.Zhejiang="浙江";
        bioData.provinces.Jiangsu="江苏";
        bioData.provinces.Shanghai="上海";
        bioData.provinces.Fujian="福建";
        bioData.provinces.HangzhouBay="杭州湾";
        bioData.provinces.Taiwan="台湾";

        bioData.provincesSimple.Zhejiang="浙";
        bioData.provincesSimple.Jiangsu="苏";
        bioData.provincesSimple.Shanghai="沪";
        bioData.provincesSimple.Fujian="闽";
    case "en"
        bioData.provinces.Zhejiang="Zhejiang";
        bioData.provinces.Jiangsu="Jiangsu";
        bioData.provinces.Shanghai="Shanghai";
        bioData.provinces.Fujian="Fujian";
        bioData.provinces.HangzhouBay="Hangzhou Bay";
        bioData.provinces.Taiwan="Taiwan";

        bioData.provincesSimple.Zhejiang="ZJ";
        bioData.provincesSimple.Jiangsu="JS";
        bioData.provincesSimple.Shanghai="SH";
        bioData.provincesSimple.Fujian="FJ";
end




bioData.dh=[117.4174938	23.6922313
    120.7773646	21.95252842
    120.8151159	23.12406717
    121.7135982	24.48488998
    122.7328849	24.09261981
    123.9031769	24.03746761
    125.8209458	24.89648847
    127.4971061	25.95341412
    128.7806522	27.53782388
    129.6489334	28.57058825
    130.4870135	30.29986899
    130.1472513	31.38243591
    128.5465938	32.66267199
    126.2286605	33.17604455
    121.9136804	31.70416923
    119.6772036	30.83792352
    ];

bioData.provinceShp="data/map/省_简化.shp";

%% 绘图常量
graphData.longitudeValues=[121,122];
graphData.longitudeLabels=["121°E","122°E"];
graphData.latitudeValues=[30,31,32];
graphData.latitudeLabels=["30°N","31°N","32°N"];
graphData.landColor=[217, 217, 217]/256;
graphData.fontSize=8;
graphData.lagerFontSize=10;
graphData.mainNclColor=@(applyToFigure) applyMainColor(applyToFigure);

switch strLang
    case "zh"
        graphData.font='微软雅黑';
    case "en"
        graphData.font='Arial';
end



%% 辅助函数
function monthName = convertToEnglishMonth(monthNumber)
    % 检查输入的月份是否在有效范围内
    if monthNumber < 1 || monthNumber > 12
        error('Invalid month number. Please enter a number between 1 and 12.')
    end

    % 定义英文月份的字符串数组
    months = ["January", "February", "March", "April", "May", "June", ...
        "July", "August", "September", "October", "November", "December"];

    % 根据月份编号获取对应的英文月份
    monthName = months(monthNumber);
end

function applyMainColor(applyToFigure)
    c=color_ncl(37,-1,[.1,1],applyToFigure);

    c=c(15:end,:);

    for i=1:10
        for j=1:3
            c(i,j)=c(i,j)+(1-c(i,j))/15*(11-i);
        end
    end
    n=256;
    if n<0
        c=flip(c);
        n=-n;
    end
    positions = linspace(0, 1, size(c, 1));
    new_positions = linspace(0, 1, n);
    c = interp1(positions, c, new_positions);

    if applyToFigure
        colormap(gcf,c);
    else
        colormap(gca,c);
    end
end

