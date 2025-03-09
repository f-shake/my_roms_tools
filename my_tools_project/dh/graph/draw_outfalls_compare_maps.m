function draw_outfalls_compare_maps(vars)
    arguments
        vars
    end
    project_data
    tests=[bioData.avg,bioData.ignoreOutfalls];
    %     tl=tiledlayout(length(tests),length(vars));
    tl=tiledlayout(2,2);
    set_tiledlayout_compact(tl)

    for iVar=1:length(vars)
        var=vars(iVar);
        disp(var)
        for iTest=1:length(tests)
            %             t=nexttile((iTest-1)*length(vars)+iVar);
            data=read_data(tests(iTest),var,[1,1,0,1],[0,0,1,0]);
            data=mean(data,4);
            if iTest==1

                baseData=data;
                %                 caxis(bioData.colorRanges.(var));
                %                 draw_map(data);
                %                 graphData.mainNclColor(false);
                %                 c=colorbar("Location","southoutside");
                %                 c.Label.String=strs.axis_concentrationOf(bioData.varName.(var), bioData.unit.(var));
                %                 apply_font
                %                 label=sprintf("(%s) %s %s",a2z_string((iTest-1)*length(vars)+iVar), bioData.considerOutfallName, bioData.varName.(var));

            else
                t=nexttile;
                data=(data./baseData-1);
                caxis([-0.1,0.1])
                draw_map(data);
                cm1=color_ncl(14,20,[0,0.35]);
                cm2=color_ncl(14,20,[0.65,1]);

                cm1(end,:)=[1,1,1];
                cm2(1,:)=[1,1,1];
                colormap(t,[cm1;cm2]);
                apply_font
                %                 label=sprintf("(%s) %s %s",a2z_string((iTest-1)*length(vars)+iVar), bioData.ignoreOutfallName, bioData.varName.(var));
                label=sprintf("(%s) %s",a2z_string(iVar), bioData.varName.(var));

                text_corner(label,'lt')
                draw_provinces
            end

        end
    end


    c=colorbar;
    c.Label.String=strs.axis_changePercentage;
    c.Ticks=-0.1:0.05:0.1;
    c.TickLabels=["-10%","-5%","0","+5%","+10%"];
    c.Layout.Tile='east';

    set_gcf_size(450,360)