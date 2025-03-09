function [result,mbs,rs,ioas]=trace(nc,year,pollutions,repeatIndexes,options)
    arguments
        nc(1,1) string %ocean_avg/his/qck文件的位置
        year(1,1) double{mustBeInteger,mustBePositive}
        pollutions(:,1) double %污染物序号
        repeatIndexes(1,:) double=pollutions
        %若为单个数字，则取第(repeatIndex-1)*(traceData.partCount+1)+1:repeatIndex*(traceData.partCount+1)个点
        %若为向量，则表示每个部分取的百分比，和为1。例如[0.5,0,0,0.5]表示第一个部分取50%，第四个部分取50%
        options.showGraph(1,1) logical =1 %是否绘图
        options.showText(1,1) logical =0 %是否显示标签
        options.riverFile(1,1) string=strings(0) %指定河流文件
    end
    configs
    project_data
    mbs=zeros(length(pollutions),3);
    rs=zeros(length(pollutions),3);
    ioas=zeros(length(pollutions),3);
    results=zeros(traceData.partCount+traceData.riverPartCount,length(pollutions),3);
    if options.showGraph
        for figureIndex=1:2
            figure(figureIndex)
            set_gcf_size(600);
            tl=  tiledlayout(length(pollutions),3);
            set_tiledlayout_compact(tl);
        end
    end
    months=projectData.months(projectData.comparableMonthIndexs);
    monthNames=strs.title_seasonNames;

    for index=1:length(pollutions)
        pollution=pollutions(index);
        for monthIndex=1:length(months)
            disp("==================================================")

            if options.showGraph
                figure(1)
                nexttile
                figure(2)
                nexttile
            end
            [traceResult,result,ioa,mb]=trace_single(nc,year,months{monthIndex},pollution,projectData.bdy(index),repeatIndexes(index),options.showGraph,options.showText,options.riverFile);
            rs(index,monthIndex)=result;
            ioas(index,monthIndex)=ioa;
            mbs(index,monthIndex)=mb;
            results(:,index,monthIndex)=traceResult;
        end

        if options.showGraph
            for figureIndex=1:2
                figure(figureIndex)
                c=colorbar;
                c.Label.String=projectData.pollutionNames(pollution)+"  "+strs.axis_concentrationMgPerL;
            end
        end
    end

    if options.showGraph
        for figureIndex=1:2
            figure(figureIndex)
            for index=1:length(pollutions)
                for monthIndex=1:length(months)
                    baseAX=gca;
                    ax=nexttile(baseAX.Parent,(index-1)*(length(months))+monthIndex);
                    draw_single_lonlat_tick(index==length(pollutions),monthIndex==1)
                    equal_aspect_ratio(ax);
                    draw_border
                    text_left_top("("+a2z_string((index-1)*length(months)+monthIndex)+") "+projectData.pollutionNames(pollutions(index))+"  "+ string(monthNames(monthIndex)))
                end
            end
            graphData.mainNclColor(true);
            apply_font(tl)
        end
    end
    disp("mb r ioa =")
    disp([mbs';rs';ioas']);


    %% 结果输出
    result=[squeeze(results(:,1,:))';squeeze(results(:,2,:))';squeeze(results(:,3,:))'];

    for i=1:size(result,1)
        for j=1:size(result,2)
            fprintf("%.2f  ",result(i,j))
        end
        fprintf("\n")
    end

end