function show_tide_current(matFile,start,draw_height)
    project_data
    if draw_height
        try
            times= evalin('base', 'times');
            u= evalin('base', 'u');
            v= evalin('base', 'v');
            zeta= evalin('base', 'zeta');
        catch
            load(matFile,'times','u','v','zeta');
        end
        [lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
    else
        try
            times= evalin('base', 'times');
            u= evalin('base', 'u');
            v= evalin('base', 'v');
        catch
            load(matFile,'times','u','v');
        end
        [lon_psi,lat_psi,~]=roms_load_grid_psi;
        [~,~,speed]=roms_unify_uv(u,v);
    end
    step=2;
    stop=start+23/24;
    set_gcf_size(900,600)
    t=tiledlayout(3,4);
    set_tiledlayout_compact(t);
    datetimes=roms_get_times(times);
    for time=start:step/24:stop
        ax=nexttile;
        index=find(datetimes==time);
        ut=u(:,:,index);
        vt=v(:,:,index);
        skip=5;
        if draw_height
            draw_background(lon_rho,lat_rho)
            hold on
            z=zeta(:,:,index);
            z(mask_rho==0)=nan;
            z=z-mean(z,"all","omitnan");
            pcolorjw(lon_rho,lat_rho,z);
            caxis([-4,4])
            lon2=lon_rho(1:skip:end,1:skip:end);
            lat2=lat_rho(1:skip:end,1:skip:end);
            ut2=ut(1:skip:end,1:skip:end);
            vt2=vt(1:skip:end,1:skip:end);
            ut2(2,2)=5;
            vt2(2,2)=0;
            quiver(lon2,lat2,ut2,vt2,3,'k',AutoScale='off');
            text(0.01,0.1,"5m/s",Units="normalized")
        else
            draw_background(lon_psi,lat_psi)
            hold on
            pcolorjw(lon_psi,lat_psi,speed(:,:,index));
            caxis([0,4])
            lon2=lon_psi(1:skip:end,1:skip:end);
            lat2=lat_psi(1:skip:end,1:skip:end);
            ut2=ut(1:skip:end,1:skip:end);
            vt2=vt(1:skip:end,1:skip:end);
            ut2(2,2)=5;
            vt2(2,2)=0;
            quiver(lon2,lat2,ut2,vt2,3,'k');
            text(0.01,0.1,"5m/s",Units="normalized")
        end
        text_left_top(['h=',num2str(hour(time))])
        graphData.mainNclColor(true);
        axis off
        draw_border
        equal_aspect_ratio(ax)
        apply_font
    end
    c=colorbar;
    if draw_height
        c.Label.String=strs.axis_height;
    else
        c.Label.String=strs.axis_flowSpeed;
    end
    c.Layout.Tile = 'east';
    apply_font(t)
end