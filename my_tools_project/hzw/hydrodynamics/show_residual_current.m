function show_residual_current(matFile)
    project_data
    try
        u= evalin('base', 'u');
        v= evalin('base', 'v');
    catch
        load(matFile,'u','v');
    end
    [lon_psi,lat_psi]=roms_load_grid_psi;
    [lon_rho,lat_rho]=roms_load_grid_rho;

    clf
    set_gcf_size(700,600)
    ut=mean(u,3);
    vt=mean(v,3);
    [ut,vt,speed]=roms_unify_uv(ut,vt);
    skip=3;
    draw_background(lon_rho,lat_rho)
    hold on
    pcolorjw(lon_psi,lat_psi,speed);
    caxis([0,2])
    lon2=lon_psi(1:skip:end,1:skip:end);
    lat2=lat_psi(1:skip:end,1:skip:end);
    ut2=ut(1:skip:end,1:skip:end);
    vt2=vt(1:skip:end,1:skip:end);
    ut2(2,2)=1;
    vt2(2,2)=0;
    quiver(lon2,lat2,ut2,vt2,3,'k',AutoScale='off');
    text(0.02,0.05,"1 m/s",Units="normalized")
    color_blue_yellow_red(5);
    colormap([1,1,1])
    axis off
    draw_border
    apply_font
    equal_aspect_ratio(gca)
%     c=colorbar;
%     c.Label.String=strs.axis_height;
    apply_font
end