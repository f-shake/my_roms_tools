function grid=get_points_in_range(range,fill)
    arguments
        range(:,2) double
        fill(1,1) double=1
    end
    range=[range;range(1,:)];
    [lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
    grid=zeros(size(lon_rho));
    for i=1:size(grid,1)
        for j=1:size(grid,2)
            lon=lon_rho(i,j);
            lat=lat_rho(i,j);
            if inpolygon(lon,lat,range(:,1),range(:,2)) && mask_rho(i,j)==1
                grid(i,j)=fill;
            end
        end
    end