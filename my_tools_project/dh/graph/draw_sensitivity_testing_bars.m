function draw_sensitivity_testing_bars(vars)
    arguments
        vars(:,1) string %变量名
    end

    project_data
    xy=bioData.locations;
    locationNames=bioData.locationNames;
    tests=bioData.tests;
    testNames=bioData.testNames;
    tl=tiledlayout(2,2);
    set_tiledlayout_compact(tl)
    xy=roms_get_xy_by_lonlat_core(xy,enable=0);
    index=0;
    for iVar=1:length(vars)
        t=nexttile;
        varName=vars(iVar);
        disp(varName)
        barDatas=zeros(length(xy),length(tests)-1);
        for iLoc=1:length(xy)
            location=xy(iLoc,:);
            disp("——"+locationNames(iLoc))
            for iTest=1:length(tests)
                data=read_data(tests(iTest),varName,[location-1,0,1],[3,3,1,0]);
                data=mean(data(:));
                if iTest==1
                    baseData=data;
                else
                    data=(data/baseData-1)*100;
                    barDatas(iLoc,iTest-1)=data;
                end
            end
        end
        b=bar(barDatas,FaceColor="flat");
        for k = 1:size(barDatas,2)
            b(k).CData = k;
        end
        color_ncl(61,128,[.1,.9])
        grid on
        ytickformat(t, 'percentage');

        maxY=max(barDatas(:))*1.2;
        minY=-maxY*0.2;
        ylim([minY,maxY]) %为title和标签留出位置
        %         xRange=xlim;

        %         for iLoc=1:length(xy)
        %             maxHeight=0;
        %             label="";
        %             for iTest=1:length(tests)
        %                 maxHeight=max([maxHeight,b(iTest).YEndPoints(iLoc)]);
        %                 data=b(iTest).YData(iLoc);
        %                 if  data>10
        %                     data=round(data,2);
        %                 elseif data>0.1
        %                     data=round(data,3);
        %                 else
        %                     data=vpa(data,2);
        %                 end
        %                 label=label+bioData.testNames(iTest)+": "+string(data)+newline;
        %             end
        %             x=(b(1).XEndPoints(iLoc)-xRange(1))/(xRange(2)-xRange(1));
        %             text(x,maxHeight/maxY,label, ...
        %                 VerticalAlignment='bottom',Units='normalized', ...
        %                 FontName=graphData.font,FontSize=graphData.fontSize)
        %         end

        locationNamesWithA2z=locationNames;
        for j=1:length(locationNames)
            index=index+1;
            locationNamesWithA2z(j)=sprintf("(%s) %s",a2z_string(index),locationNames(j));
        end

        xticklabels(locationNamesWithA2z)
        draw_border
        text_corner(bioData.varName.(varName))
        apply_font
    end
    l=legend(testNames(2:end),Location="east",Orientation="horizontal");
    l.Layout.Tile = 'south';

    set_gcf_size(1000,600)
end