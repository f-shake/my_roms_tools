function draw_sensitivity_testing_maps(vars)
    arguments
        vars
    end
    project_data
    tests=bioData.tests;
    for iFig=1:2
        figure(iFig)
        tl=tiledlayout(length(vars),length(tests));
        set_tiledlayout_compact(tl)
        set_gcf_size(720,600)
    end
    for iVar=1:length(vars)
        var=vars(iVar);
        disp(var)
        for iTest=1:length(tests)
            disp("——"+bioData.testNames(iTest))
            rawData=read_data(tests(iTest),var,[1,1,0,1],[0,0,1,0]);
            rawData=mean(rawData,4);

            for iFig=1:2
                figure(iFig)
                t=nexttile;

                if iTest==1
                    baseData=rawData;
                    caxis(bioData.colorRanges.(var));
                    draw_map(rawData);
                    graphData.mainNclColor(false);c=colorbar("Location","westoutside");
                    c.Label.String=sprintf("%s (%s)", bioData.varName.(var), bioData.unit.(var));                else
                    switch iFig
                        case 1
                            data=rawData./baseData-1;
                            caxis([-1,3])
                            cm1=color_ncl(14,20,[0,0.35]);
                            cm2=color_ncl(14,60,[0.65,1]);
                        case 2
                            data=rawData-baseData;
                            a=bioData.colorRanges.(var);
                            caxis([-a(2)/5,a(2)/5])
                            cm1=color_ncl(14,30,[0,0.35]);
                            cm2=color_ncl(14,30,[0.65,1]);
                    end
                    draw_map(data);
                    cm1(end,:)=[1,1,1];
                    cm2(1,:)=[1,1,1];
                    colormap(t,[cm1;cm2]);
                end

                draw_provinces

                apply_font
                label=sprintf("(%s) %s %s",a2z_string((iTest-1)*length(vars)+iVar), bioData.testNames(iTest), bioData.varName.(var));
                text_corner(label,'rb')

                if iTest==length(bioData.tests) && iFig==2
                    c=colorbar;
                    c.Label.String=sprintf("%s (%s)", bioData.varName.(var), bioData.unit.(var));
                end
            end
        end
    end

    figure(1)
    c=colorbar;
    c.Label.String=strs.axis_changePercentage;
    c.Ticks=-1:4;
    c.TickLabels=["-100%","0","+100%","+200%","+300%"];
    c.Layout.Tile='east';