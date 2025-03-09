function add_water_exchange_dye(ranges)
    arguments
        ranges(:,2,:) double %前两个维度是xi和eta，第三个维度是示踪剂的序号
    end

    count=size(ranges,3);
    configs
    configs(1,count);
    [lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
    n=length(ncread(fullfile(roms.project_dir,roms.input.grid),'s_rho'));
    types=zeros(size(lon_rho));
    for k=1:count
        range=[ranges(:,:,k);ranges(1,:,k)];
        dye=zeros(size(lon_rho));
        for i=1:size(dye,1)
            for j=1:size(dye,2)
                lon=lon_rho(i,j);
                lat=lat_rho(i,j);
                if inpolygon(lon,lat,range(:,1),range(:,2)) && mask_rho(i,j)==1
                    dye(i,j)=1;
                    types(i,j)=k;
                end
            end
        end
        roms.tracer.densities{k}=repmat(dye,1,1,n);
    end

    types(mask_rho==0)=-1;
    pcolorjw(lon_rho,lat_rho,types);

    roms_add_passive_tracer_core(roms);