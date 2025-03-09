function show_tracer_map(nc,days,dayAve,row,col)
    project_data
    configs
    times=roms_get_times(nc);
    times=times-times(1); %以天为单位的经过时间
    dyes=roms_get_dye(nc,1,1);
    tl=tiledlayout(row,col);
    set_gcf_size(700,400)
    set_tiledlayout_compact(tl)
    [lon_rho,lat_rho,~]=roms_load_grid_rho;
    az=a2z_string;
    for i=1:length(days)
        day=days(i);
        ax=nexttile;
        if day==0
            f=times==0;
        else
            f= times>day-dayAve & times<day+dayAve;
        end
        dye=mean(dyes(:,:,f),3);
        draw_background(lon_rho,lat_rho);
        contourf(lon_rho,lat_rho,dye,ShowText=0,LevelStep=0.1);
        text_left_top("("+az(i)+") "+strs.title_dayOf(day));
        axis off
        xlim([120.5,122.5]); ylim([29.85,31.2]); caxis([0,1])
        draw_border
        equal_aspect_ratio(ax)
        apply_font
    end
    graphData.mainNclColor(true);
    c=colorbar;
    c.Label.String=strs.axis_concentration;
    c.Layout.Tile = 'east';
    apply_font(tl)