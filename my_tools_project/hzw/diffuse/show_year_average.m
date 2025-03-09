function show_year_average(nc,dyeIndexes,pollutionIndexes)
    arguments
        nc(1,1) string %nc文件路径
        dyeIndexes(:,1) double {mustBeInteger,mustBePositive}
        pollutionIndexes(:,1) double {mustBeInteger,mustBePositive}
    end

    configs
    project_data




    %% 画图准备

    set_gcf_size(300*length(dyeIndexes),300);
    tl=tiledlayout(1,length(dyeIndexes));
    set_tiledlayout_compact(tl)

    %% 遍历每一个污染物
    for index=1:length(dyeIndexes)
        dyeIndex=dyeIndexes(index);
        pollutionIndex=pollutionIndexes(index);

        nexttile(tl);

        compare_single(nc,2018,1:12,pollutionIndex,dyeIndex, 0,1,'pcolor',[]);

        c=colorbar;
        c.Location="southoutside";


        c.Label.String=projectData.pollutionNames(pollutionIndex)+"  "+strs.axis_concentrationMgPerL;

    end

    %% 绘制左上角标签，绘制边框，限制坐标轴比例
    for index=1:length(dyeIndexes)
        pollutionIndex=pollutionIndexes(index);

        ax=nexttile(tl,index);
        xticks(graphData.longitudeValues); xticklabels(graphData.longitudeLabels);
        yticks(graphData.latitudeValues); yticklabels(graphData.latitudeLabels  );

        equal_aspect_ratio(ax);
        draw_border
        text_left_top("Annual "+projectData.pollutionNames(pollutionIndex)+" concentrations in 2018",0.01,0.01)
    end

    %% 设置colormap、Label、字体
    color_red_yellow_green(10);

end