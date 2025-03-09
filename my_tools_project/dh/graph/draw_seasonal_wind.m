function draw_seasonal_wind
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
    skip=20;
    set_gcf_size(600)
    tl=tiledlayout(1,4);
    set_tiledlayout_compact(tl)
    months={3:5,6:8,9:11,[1,2,12]};
    set_gcf_size(1200,240)

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
        skippedU(2,end-2)=10;
        skippedV(2,end-2)=0;
        skippedU=skippedU/5;
        skippedV=skippedV/5;
        draw_map(speed);
        hold on
        quiverm(lat_rho(1:skip:end,1:skip:end),lon_rho(1:skip:end,1:skip:end), ...
            skippedV,skippedU,'k',0,'filled');
        text_corner("10 m/s","lt",marginX=0.06,marginY=0.16,backgroundTransparent=1)
        equal_aspect_ratio(ax)
        text_corner(strs.title_seasonNames(i))
        caxis(range);
        draw_border
        apply_font

    end
    color_ncl('cmocean_amp',-1,[0,0.5],true)
    set_gcf_size(1200,240)
    colorbar
end