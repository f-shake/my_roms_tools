function show_half_exchange_map(nc,range)
    configs
    times=ncread(nc,'ocean_time');
    times=datenum(datetime(roms.time.base)+times/86400);
    times=times-times(1); %以天为单位的经过时间

    dye=roms_get_dye(nc,1,1);
    halfTime=zeros(size(dye,1),size(dye,2));
    halfTime(isnan(dye(:,:,end)))=nan;
    grid=get_points_in_range(range,1);
    for t=1:length(times)
        for i=1:size(dye,1)
            for j=1:size(dye,2)
                if grid(i,j)==1 && dye(i,j,t)<0.5 && halfTime(i,j)==0
                    halfTime(i,j)=times(t);
                end
            end
        end
    end


    [lon_rho,lat_rho,~]=roms_load_grid_rho;

    %F=scatteredInterpolant(lon_rho(:),lat_rho(:),halfTime(:),'natural');
    %[new_lon,new_lat]=ndgrid(min(lon_rho(:)):0.005:max(lon_rho(:)),min(lat_rho(:)):0.005:max(lat_rho(:)));
    %new_halfTime=F(new_lon,new_lat);
    %pcolorjw(lon_rho,lat_rho,halfTime);
    ylim([29.85,31])
    contourf(lon_rho,lat_rho,halfTime,ShowText=1,LevelStep=10)

    %contourf(new_lon,new_lat,new_halfTime,ShowText=1,LevelStep=10)