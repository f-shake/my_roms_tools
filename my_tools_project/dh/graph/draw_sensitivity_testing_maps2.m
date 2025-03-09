function draw_sensitivity_testing_maps2(vars)
    arguments
        vars
    end
    project_data
    tests=bioData.tests;
    tl=tiledlayout(length(vars),3);
    set_tiledlayout_compact(tl)
    set_gcf_size(length(tests)*180,length(vars)*220)
    index=0;
    datas=cell(2,1);
    for iVar=1:length(vars)
        var=vars(iVar);
        disp(var)
        for iTest=1:2
            index=index+1;
            disp(tests(iTest))
            t=nexttile;
            data=read_data(tests(iTest),var,[1,1,0,1],[0,0,1,0]);
            data=mean(data,4);
            datas{iTest}=data;
            caxis(bioData.colorRanges.(var));
            draw_map(data);
            bioData.mainNclColor(0)

            if iTest==1
                c=colorbar("Location","westoutside");
                c.Label.String=bioData.unit.(var);
            end

            apply_font
            label=sprintf("(%s) %s %s",a2z_string(index), bioData.testNames(iTest), bioData.varName.(var));
            text_corner(label,"rb")
        end

        t=nexttile;
        data=datas{2}./datas{1}-1;
        caxis([-1,2])
        draw_map(data);
        cm1=color_ncl(70,10,[0,0.45]);
        cm2=color_ncl(70,20,[0.55,1]);
        colormap(t,[cm1;cm2]);

        apply_font
        label=sprintf("(%s) %s %s",a2z_string(index), strs.title_changePercentage, bioData.varName.(var));
        text_corner(label,"rb")

    end

    c=colorbar;
    c.Label.String=strs.axis_changePercentage;
    c.Ticks=[-1,0,2];
    c.TickLabels=["-100%","0","+200%"];
    c.Layout.Tile='east';

    set_gcf_size(580,600)

    % 带Bar的版本
    %     function draw_sensitivity_testing_maps2(vars)
    %     arguments
    %         vars
    %     end
    %     project_data
    %     tests=bioData.tests;
    %     tl=tiledlayout(length(vars),4);
    %     set_tiledlayout_compact(tl)
    %     set_gcf_size(length(tests)*180,length(vars)*220)
    %     index=0;
    %     datas=cell(2,1);
    %     barData=zeros(length(bioData.locationNames),length(vars));
    %     xy=roms_get_xy_by_lonlat_core(bioData.locations,enable=false);
    %     for iVar=1:length(vars)
    %         var=vars(iVar);
    %         disp(var)
    %         for iTest=1:2
    %             index=index+1;
    %             disp(tests(iTest))
    %             t=nexttile;
    %             if var=="DIN"
    %                 data=read_data(tests(iTest),"NO3",[1,1,0,1],[0,0,1,0]);
    %                 data=data+read_data(tests(iTest),"NH4",[1,1,0,1],[0,0,1,0]);
    %             else
    %                 data=read_data(tests(iTest),var,[1,1,0,1],[0,0,1,0]);
    %             end
    %             data=mean(data,4);
    %             datas{iTest}=data;
    %             caxis(bioData.colorRanges.(var));
    %             draw_map(data);
    %             bioData.mainNclColor(0)
    %
    %             if iTest==1
    %                 c=colorbar("Location","westoutside");
    %                 c.Label.String=bioData.unit.(var);
    %             end
    %
    %             apply_font
    %             label=sprintf("(%s) %s %s",a2z_string(index), bioData.testNames(iTest), bioData.varName.(var));
    %             text_corner(label,"rb")
    %         end
    %
    %         t=nexttile;
    %         data=datas{2}./datas{1}-1;
    %         for iLoc=1:length(bioData.locationNames)
    %             barData(iLoc,iVar)=data(xy(iLoc,1),xy(iLoc,2));
    %         end
    %         caxis([-1,2])
    %         draw_map(data);
    %         cm1=color_ncl(-70,10,[0,0.45]);
    %         cm2=color_ncl(-70,20,[0.55,1]);
    %         colormap(t,[cm1;cm2]);
    %
    %         apply_font
    %         label=sprintf("(%s) %s %s",a2z_string(index), strs.title_changePercentage, bioData.varName.(var));
    %         text_corner(label,"rb")
    %
    %         nexttile
    %     end
    %
    %
    %     nexttile(4,[length(vars),1])
    %      b=barh(barData,FaceColor="flat");
    %         for k = 1:size(barData,2)
    %             b(k).CData = k;
    %         end
    %     color_ncl(61,128,[.1,.9])
    %     yticklabels(bioData.locationNames)
    %     varNames=strings(length(vars),1);
    %     for i=1:length(vars)
    %         varNames(i)=bioData.varName.(vars(i));
    %     end
    %     legend(varNames)
    %     xticks([0,2,4]);
    %     xticklabels(["0","200%","400%"]);
    %     ytickangle(90)
    %     apply_font
    %
    %     c=colorbar(nexttile(3));
    %     c.Label.String=strs.axis_changePercentage;
    %     c.Ticks=[-1,0,2];
    %     c.TickLabels=["-100%","0","+200%"];
    %     c.Layout.Tile='east';
    %
    %     set_gcf_size(800,600)