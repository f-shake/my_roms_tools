%% 绘图
configs

global strLang
baseDir="C:\Users\autod\Desktop\hzw\";
mapDir=baseDir+"分析绘图数据/地图";
tideFiles=baseDir+"分析绘图数据/潮汐数据/"+["乍浦.txt"; "滩浒.txt"];
uvzetaFile=baseDir+"模拟结果/uvzeta.mat";
simFile=baseDir+"模拟结果/diffuse.nc";
exchangeFile=baseDir+"模拟结果/exchange.mat";
contributionFile="模拟结果/contribution.nc";
traceFile=baseDir+"模拟结果/trace.nc";
traceRiverFile=baseDir+"模式输入配置文件/源强估算/roms_rivers.nc";
traceGridFile=baseDir+"模式输入配置文件/源强估算/grid.grd";
fltFile=baseDir+"模拟结果/ocean_flt.nc";

dpi=600; close all;
switch input("请输入绘制类型（1-小论文；2-大论文；3-小论文返修）：")
    case 1
        strLang="en";
        project_data

        show_year_average(simFile,1:3,1:3);
        save_all_figures("0-图形摘要",dpi);

        show_hzw_area(mapDir,traceGridFile);
        save_all_figures("1.1-研究区域",dpi);

        show_emission_points
        save_all_figures("1.2-污染源",dpi);

        show_tide_compare(uvzetaFile,tideFiles,[2018,1,2],[2018,1,16], [37 45; 55 60],[strs.tide_zp,strs.tide_th],-0.08,0.01,[0.0,0.0],0);
        save_all_figures(["2.1-潮汐对比","2.2-潮汐相关系数"],dpi);

        show_tide_current(uvzetaFile,datetime(2018,1,4,0,0,0),1)
        save_all_figures("2.3-流场",dpi);

        show_residual_current(uvzetaFile)
        save_all_figures("2.4-余流场",dpi);

        show_tracer_percent_in_each_part(exchangeFile,projectData.studyRange);
        save_all_figures("3.1-水交换示踪剂折线图",dpi);

        show_tracer_map(exchangeFile,[0,15,30,45,60,75,90,105,120],3,3,3)
        save_all_figures("3.2-水交换时间序列地图",dpi);

        [mbs,rs,ioas]=compare(simFile,2018,1:3,1:3,0);
        writematrix([mbs';rs';ioas'],'4-扩散模拟评价指标.csv');
        save_all_figures(["4.1-扩散模拟对比图","4.2-扩散模拟相关系数"],dpi);

        show_contributions(contributionFile)
        save_all_figures("5.1-保守物质贡献分布图",dpi);

        [t,mbs,rs,ioas]=trace(traceFile,2018,1:3,1:3,showGraph=1,showText=0,riverFile=traceRiverFile);
        writematrix([mbs';rs';ioas'],'6.1-源强估算评价指标.csv');
        writematrix(t,'6.2-源强估算结果.csv');
        save_all_figures(["6.1-源强估算图","6.2-源强估算观测点插值示意图"],dpi);
   case 2
        strLang="zh";
        project_data

        show_hzw_area(mapDir,traceGridFile);
        save_all_figures("1.1-研究区域",dpi);

        show_tide_compare(uvzetaFile,tideFiles,[2018,1,2],[2018,1,16], [37 45; 55 60],[strs.tide_zp,strs.tide_th],-0.08,0.01,[0.0,0.0],0);
        save_all_figures(["2.1-潮汐对比","2.2-潮汐相关系数"],dpi);

        show_tide_current(uvzetaFile,datetime(2018,1,4,0,0,0),1)
        save_all_figures("2.3-流场",dpi);

        show_residual_current(uvzetaFile)
        save_all_figures("2.4-余流场",dpi);

        show_tracer_percent_in_each_part(exchangeFile,projectData.studyRange);
        save_all_figures("3.1-水交换示踪剂折线图",dpi);

        show_tracer_map(exchangeFile,[0,15,30,45,60,75,90,105,120],3,3,3)
        save_all_figures("3.2-水交换时间序列地图",dpi);

        [mbs,rs,ioas]=compare(simFile,2018,1:3,1:3,0);
        writematrix([mbs';rs';ioas'],'4-扩散模拟评价指标.csv');
        save_all_figures(["4.1-扩散模拟对比图","4.2-扩散模拟相关系数"],dpi);

        show_contributions(contributionFile)
        save_all_figures("5.1-保守物质贡献分布图",dpi);

        floatFilter=repmat([1,0,0,0,0],5,365/5);
        show_floats(fltFile,365*ones(5,1),[1,5,10,30,90],floatFilter,[5,5],strs.title_traceParts,strs.title_firstDayOf([1;5;10;30;90]))
        save_all_figures("5.2-粒子贡献分布图",dpi);

        floats_contribution(fltFile,[ones(365,1);ones(365,1)*2],projectData.studyRange)

        [t,mbs,rs,ioas]=trace(traceFile,2018,1:3,1:3,showGraph=1,showText=0,riverFile=traceRiverFile);
        writematrix([mbs';rs';ioas'],'6.1-源强估算评价指标.csv');
        writematrix(t,'6.2-源强估算结果.csv');
        save_all_figures(["6.1-源强估算图","6.2-源强估算观测点插值示意图"],dpi);

    case 3
        strLang="en";
        project_data

        show_residual_current(uvzetaFile)
        save_all_figures("r1-余流场",dpi);

        floatFilter=repmat([1,0,0,0,0],5,365/5);
        show_floats(fltFile,365*ones(5,1),[5;10;30;60;90],floatFilter,[5,5],strs.title_traceParts,strs.title_firstDayOf([5;10;30;60;90]))
        save_all_figures("r2-粒子扩散图",dpi);

        show_all_obs
        save_all_figures("r3-所有观测点位置",dpi);

    otherwise
        error("未知输入")
end
disp("图表生成完成");pause

%% 其他绘图
% 显示水半交换时间地图
show_half_exchange_map(exchangeFile,projectData.studyRange);

% 观测值
show_observations_per_quarter

%% 预处理文件生成

GridBuilder %网格
roms_create_clm_bdy_ini(1,1,0,0,'clms_hycom') %初始场、边界场、逼近文件
add_paths;
roms_create_force_NCEP(20) %气象强迫
roms_create_force_radiation_ERA5 %辐射强迫
roms_create_tides_tpxo9(roms.time.start,roms.input.grid,roms.res.tpxo9,roms.res.tpxo9_days,roms.input.tides); %潮汐强迫
roms_create_tides_tpx

% 水交换创建河流，添加示踪剂
add_water_exchange_dye(projectData.studyRange);
create_water_exchange_rivers

% 扩散模拟创建河流和边界
rstFile="ocean_rst.nc";
create_real_emission_points
add_ini_bdy_dye([],projectData.bdy);
add_ini_bdy_dye(rstFile,projectData.bdy);

% 源强估算导出网格
export_mask
traceGridFile="模式输入配置文件/源强估算/grid.grd";

% 贡献
prepare_contribution_ini_rivers(traceGridFile)

% 源强估算创建河流文件和初始边界场
rstFile="ocean_rst.nc";
create_manual_virtual_emission_points_with_time(traceGridFile)
%add_ini_bdy_tracer([],traceData)
add_ini_bdy_tracer(rstFile,traceData)

% 漂浮子
xyz0=[
    120.86 31.84 5
    120.60 30.39 5
    121.13,30.59 5
    121.19,30.38 5
    122.13,29.93 5
    ];
roms_create_timely_floats(xyz0,365,0,1,1,0,1)

xyz0=[
    75 74 5
    ];
roms_create_timely_floats(xyz0,20*365/5,0,5,0,0,1)