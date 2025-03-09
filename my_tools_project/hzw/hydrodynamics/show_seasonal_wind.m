function show_seasonal_wind
    configs
    project_data
    Uwind=ncread(fullfile(roms.project_dir,roms.input.atom),"Uwind");
    Vwind=ncread(fullfile(roms.project_dir,roms.input.atom),"Vwind");
    lon=ncread(fullfile(roms.project_dir,roms.input.atom),"lon");
    lat=ncread(fullfile(roms.project_dir,roms.input.atom),"lat");
    time=ncread(fullfile(roms.project_dir,roms.input.atom),"time");
    method='linear';
    times= datetime(roms.time.base)+time;
    range=[0,6];
    skip=10;
    set_gcf_size(600)
    tl=tiledlayout(1,4);
    set_tiledlayout_compact(tl)
    months={3:5,6:8,9:11,[1,2,12]};
    monthNames=strs.title_seasonNames;

    [lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
    for i=1:length(months)
        ax=nexttile;
        f=ismember(month(times),months{i});
        us=Uwind(:,:,f);
        vs=Vwind(:,:,f);
        avgU=mean(us,3);
        avgV=mean(vs,3);

        F=scatteredInterpolant(lon(:),lat(:),avgU(:),method);
        avgU=F(lon_rho,lat_rho);
        F=scatteredInterpolant(lon(:),lat(:),avgV(:),method);
        avgV=F(lon_rho,lat_rho);

        speed=sqrt(avgU.*avgU+avgV.*avgV);
        speed(mask_rho==0)=nan;
        avgU(mask_rho==0)=nan;
        avgV(mask_rho==0)=nan;
        skippedU=avgU(1:skip:end,1:skip:end);
        skippedV=avgV(1:skip:end,1:skip:end);
        skippedU(2,2)=5;
        skippedV(2,2)=0;

        draw_background(lon_rho,lat_rho)
        pcolorjw(lon_rho,lat_rho,speed);
        hold on
        quiver(lon_rho(1:skip:end,1:skip:end),lat_rho(1:skip:end,1:skip:end), ...
            skippedU,skippedV,1,'b');
        text(0.05,0.1,"5 m/s",Units="normalized")
        equal_aspect_ratio(ax)
        color_red_yellow_green(12);
        text_left_top(monthNames(i))
        caxis(range);
        draw_border
        apply_font

    end
    c=colorbar;
    c.Label.String=strs.axis_flowSpeed;
    c.Layout.Tile = 'east';
end