function draw_seasonal_currents
    project_data
    configs
    file=fullfile(roms.project_dir,roms.input.climatology);
    [lon_psi,lat_psi,mask_psi]=roms_load_grid_psi;
    u=read_data(file,'u',[1,1,0,1],[0,0,1,0]);
    v=read_data(file,'v',[1,1,0,1],[0,0,1,0]);
    clf
    [u,v,speed]=roms_unify_uv(squeeze(u),squeeze(v));
    skip=15;
    tl=tiledlayout(2,2);
    set_tiledlayout_compact(tl);
    times=roms_get_times(read_data(file,'ocean_time'));
    months={3:5,6:8,9:11,[1,2,12]};
    for i=1:length(months)
        nexttile
        timeFilter=ismember(month(times),months{i});
        ut=mean(u(:,:,timeFilter),3);
        vt=mean(v(:,:,timeFilter),3);
        ut(mask_psi==0)=0;
        vt(mask_psi==0)=0;
        st=mean(speed(:,:,timeFilter),3);
        draw_map(st,"","psi");
        caxis([0,1])
        lon2=lon_psi(1:skip:end,1:skip:end);
        lat2=lat_psi(1:skip:end,1:skip:end);
        ut=ut(1:skip:end,1:skip:end);
        vt=vt(1:skip:end,1:skip:end);
        ut=ut*2;
        vt=vt*2;
        text_corner(strs.title_seasonNames(i))
        quiverm(lat2,lon2,vt,ut,'w',0,'filled');
        
        ut=zeros(size(ut));
        vt=zeros(size(vt));
        ut(2,end-3)=1;
        vt(2,end-3)=0;
        quiverm(lat2,lon2,vt,ut,'k',0,'filled');
        equal_aspect_ratio(gca)
        text_corner("0.5 m/s","lt",marginX=0.04,marginY=0.16,backgroundTransparent=1)
        apply_font
    end
    
    graphData.mainNclColor(true);
    set_gcf_size(480,420)
    c=colorbar;
    c.Layout.Tile='east';
    c.Label.String=strs.axis_flowSpeed;
end

