function [mbs,rs,ioas]=compare(nc,year,dyeIndexes,pollutionIndexes,displayErrorCount,showGraph)
    arguments
        nc(1,1) string %nc文件路径
        year(1,1) double
        dyeIndexes(:,1) double {mustBeInteger,mustBePositive}
        pollutionIndexes(:,1) double {mustBeInteger,mustBePositive} =dyeIndexes
        displayErrorCount(1,1) double {mustBeInteger}=10
        showGraph(1,1) logical =1
    end

    configs
    project_data


    %% 初始化变量
    sitesTotalError=containers.Map;
    sitesMaxError=containers.Map;
    sitesTotalCount=containers.Map;

    months=projectData.months;
    monthNames=strs.title_seasonNames;
    comparableMonthIndexs=projectData.comparableMonthIndexs;

    mbs=zeros(length(dyeIndexes),length(comparableMonthIndexs));
    rs=zeros(length(dyeIndexes),length(comparableMonthIndexs));
    rps=zeros(length(dyeIndexes),length(comparableMonthIndexs));
    ioas=zeros(length(dyeIndexes),length(comparableMonthIndexs));

    %% 画图准备
    
    if showGraph
        clf;clc;
        figure(1);
        set_gcf_size(200*length(months),200*length(dyeIndexes));
        tl1=tiledlayout(length(dyeIndexes),length(months));

        figure(2);
        set_gcf_size(200*length(comparableMonthIndexs),200*length(dyeIndexes));
        tl2=tiledlayout(length(dyeIndexes),length(comparableMonthIndexs));
        set_tiledlayout_compact(tl1,tl2);
    end

    %% 遍历每一个污染物
    for index=1:length(dyeIndexes)
        dyeIndex=dyeIndexes(index);
        pollutionIndex=pollutionIndexes(index);
        for monthIndex=1:length(months)
            hasObs=ismember(monthIndex,comparableMonthIndexs);
            if showGraph
                nexttile(tl1);
                if hasObs
                    nexttile(tl2);
                end
            end
            [r,rp,ioa,mb,os,ps,sites]=compare_single(nc,year,months{monthIndex},pollutionIndex,dyeIndex, ...
                hasObs,showGraph,'pcolor');

            %% 统计误差
            if hasObs

                rs(index,monthIndex)=r;
                rps(index,monthIndex)=rp;
                ioas(index,monthIndex)=ioa;
                mbs(index,monthIndex)=mb;

                errors=abs(os-ps);
                for i=1:length(sites)
                    site=char(sites(i));
                    error=errors(i);
                    if isKey(sitesTotalError,site)
                        sitesTotalCount(site)=sitesTotalCount(site)+1;
                        sitesTotalError(site)=sitesTotalError(site)+error;
                        sitesMaxError(site)=max([sitesMaxError(site),error]);
                    else
                        sitesTotalCount(site)=1;
                        sitesTotalError(site)=error;
                        sitesMaxError(site)=error;
                    end
                end
                [errors,errorIndexes]=sort(errors,"descend");
                if displayErrorCount>0
                    disp("本图块误差最大的点：")
                    disp(string(sites(errorIndexes(1:displayErrorCount/2)))')
                    disp(string(errors(1:displayErrorCount/2))')
                    errorPercent=sum(abs(os-ps)./max([os';ps'])'<0.3)/length(os)*100;
                    disp("误差小于30%的站点数量="+num2str(errorPercent)+"%")
                end
            end
        end
        if showGraph
            figure(1); 
            c=colorbar;
            c.Label.String=projectData.pollutionNames(pollutionIndex)+"  "+strs.axis_concentrationMgPerL;
        end
    end

    if showGraph
        %% 绘制左上角标签，绘制边框，限制坐标轴比例
        for index=1:length(dyeIndexes)
            pollutionIndex=pollutionIndexes(index);
            for monthIndex=1:length(months)
                if showGraph
                    nexttile(tl1,(index-1)*(length(months))+monthIndex);
                    draw_single_lonlat_tick(index==length(dyeIndexes),monthIndex==1)

                    ax=nexttile(tl1,(index-1)*(length(months))+monthIndex);
                    equal_aspect_ratio(ax);
                    draw_border
                    text_left_top("("+a2z_string((index-1)*length(monthNames)+monthIndex)+") "+projectData.pollutionNames(pollutionIndex)+"  "+ string(monthNames(monthIndex)))

                    if ismember(monthIndex,comparableMonthIndexs)
                        ax=nexttile(tl2,(index-1)*(length(comparableMonthIndexs))+monthIndex);
                        equal_aspect_ratio(ax);
                        draw_border
                        text_left_top("("+a2z_string((index-1)*length(monthNames)+monthIndex)+") "+projectData.pollutionNames(pollutionIndex)+"  "+ string(monthNames(monthIndex)))
                        if rps(index,monthIndex)<0.01
                            star="*";
                        elseif rps(index,monthIndex)<0.05
                            star="**";
                        else
                            error("p值太高了");
                        end
                        text_right_bottom("mb="+round(mbs(index,monthIndex),3) + newline + ...
                            "r="+round(rs(index,monthIndex),2) + star + newline + ...
                            "ioa="+round(ioas(index,monthIndex),2),0.38,0.3)
                    end
                end
            end
        end

        %% 设置colormap、Label、字体
        figure(1);
        graphData.mainNclColor(true);

        figure(2);
        xlabel(tl2, strs.axis_simValue)
        ylabel(tl2,strs.axis_obsValue);
        apply_font(tl1,tl2);
    end

    %     %% 寻找误差最大的站点
    %     sitesErrors=zeros(size(sites));
    %     for i=1:length(sites)
    %         site=char(sites(i));
    %         sitesErrors(i)=sitesTotalError(site)/sitesTotalCount(site);
    %         %sitesErrors(i)=sitesMaxError(site);
    %     end
    %     [~,errorsIndex]=sort(sitesErrors,'descend');
    %     disp("所有图块误差最大的点：")
    %     disp(string(sites(errorsIndex(1:displayErrorCount)))')
    %
    %     disp(projectData.pollutionNames)
    %     disp([round(mbs,3)';round(rs,2)';round(ioas,2)']);
end