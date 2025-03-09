%% 分析绘图
clear
close all;
configs
dpi=600;
global strLang;
strLang="en";

switch input("请输入绘制类型（1-小论文；2-大论文）：")
    case 1
        strLang="en";
        project_data

        dh_graphic_abstract
        close all

        %模拟区域
        show_dh_area
        save_all_figures("F1-研究区域",dpi);

        %模型验证
        compare_SST_SSS_with_Argo
        save_all_figures("F2-温度盐度对比",dpi);
        compare_nutrients_with_gov
        save_all_figures("F3-营养盐对比",dpi);
        compare_chl_with_clm
        save_all_figures("S2-叶绿素对比",dpi);
        compare_with_clm("temp")
        save_all_figures("R1-温度HYCOM对比",dpi)
        compare_with_clm("salt")
        save_all_figures("R2-盐度HYCOM对比",dpi)
        draw_seasonal_currents
        save_all_figures("S3-季节流场",dpi);

        %各指标逐季节海表浓度
        draw_biology_time_series_maps
        save_all_figures("F4-逐季节海表浓度",dpi);
        draw_biology_time_series_lines
        save_all_figures("S4-典型海域浓度变化",dpi);

        %敏感性试验
        draw_np_ratio
        save_all_figures("F5-敏感性试验氮磷比",dpi);
        draw_sensitivity_testing_maps(["DIN","PO4","chlorophyll","zooplankton"])
        save_all_figures(["F6-敏感性试验变化率地图","S6-敏感性试验变化量地图"],dpi);
        draw_monthly_flux
        save_all_figures("S5-长江入海营养盐月通量",dpi);
        draw_sensitivity_testing_nutrients_contributions;
        save_all_figures("S7-单个营养盐的贡献",dpi);
        write_sensitivity_testing_table(["DIN","PO4","chlorophyll","zooplankton"])

    case 2
        strLang="zh";
        project_data

        %模拟区域
        show_dh_area
        save_all_figures("1-研究区域",dpi);

        %模型验证
        compare_SST_SSS_with_Argo
        save_all_figures("2.1-温度盐度对比",dpi);

        compare_nutrients_with_gov
        save_all_figures("2.2-营养盐对比",dpi);

        %流场
        %draw_seasonal_currents
        %save_all_figures("3.1-季节流场",dpi);

        %各指标逐季节海表浓度
        draw_biology_time_series_maps
        save_all_figures("3.2-逐季节海表浓度",dpi);

        %各指标典型海域浓度变化
        draw_biology_time_series_lines
        save_all_figures(["3.3-典型海域浓度变化",""],dpi);

        %各指标沿经纬度的剖面图
        draw_biology_profile(["temp","DIN","PO4","chlorophyll","zooplankton"],'lon')
        save_all_figures("3.4.1-经度剖面",dpi);
        draw_biology_profile(["temp","DIN","PO4","chlorophyll","zooplankton"],'lat')
        save_all_figures("3.4.2-纬度剖面",dpi);

        %敏感性试验
        draw_np_ratio
        save_all_figures("4.1-敏感性试验氮磷比",dpi);
        draw_sensitivity_testing_maps(["DIN","PO4","chlorophyll","zooplankton"])
        save_all_figures(["4.2-敏感性试验变化地图",""],dpi);
        write_sensitivity_testing_table(["DIN","PO4","chlorophyll","zooplankton"])

end


%其他不使用的函数
%draw_sensitivity_testing_bars(["DIN","PO4","chlorophyll","zooplankton"])
%draw_sensitivity_testing_maps2(["DIN","PO4","chlorophyll","zooplankton"])
%draw_2var_correlation("NO3","chlorophyll",bioData.locations(1,:));

disp("图表生成完成");pause
pause

%% 预处理
GridBuilder %网格
roms_create_clm_bdy_ini(1,1,0,0,'clms_hycom') %初始场、边界场、气候态文件
add_paths; roms_create_force_NCEP(20) %大气强迫
roms_create_force_radiation_ERA5 %辐射强迫
roms_create_tides_tpxo9(roms.time.start,roms.input.grid,roms.res.tpxo9,roms.res.tpxo9_days,roms.input.tides); %潮汐强迫
fill_bio_ini_from_rst %模式旋转
create_bio_rivers %创建河流
add_real_bio_varibles %向河流写入生物变量
create_n_flux_force %创建大气氮沉降文件

nc_compact