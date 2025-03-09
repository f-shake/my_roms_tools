function compare_with_clm(var)
    configs
    project_data
    xx=[];
    yy=[];
    simNC=bioData.avg;
    simTimes=read_data(simNC,"ocean_time");
    clmNC= roms.input.climatology;
    [lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
    mask_rho3D=repmat(mask_rho,[1,1,roms.grid.N]);

    l=bioData.colorRanges.(var);
    % var="NO3";
    simChlValue=read_data(simNC,var);

    figure(2)
    t=tiledlayout(2,4);
    set_tiledlayout_compact(t);
    clmValue=[];
    for season=1:4
        switch season
            case 1
                months=3:5;
            case 2
                months=6:8;
                %         case 3
                months=9:11;
            case 4
                months=[12,1,2];
        end
        timeIndex=ismember(month(roms_get_times(simTimes)),months);
        simValue=mean(squeeze(simChlValue(:,:,end,timeIndex)),3);
        clmTimes=roms_get_times(clmNC);
        timeCountPerMonth=floor(length(clmTimes)/12);
        for m=months
            if isempty(clmValue)
                clmValue=mean(read_data(clmNC,var,[1,1,0,(m-1)*timeCountPerMonth+1],[0,0,1,timeCountPerMonth]),4);
            else
                clmValue(:,:,end+1)=mean(read_data(clmNC,var,[1,1,0,(m-1)*timeCountPerMonth+1],[0,0,1,timeCountPerMonth]),4);
            end
        end
        clmValue=mean(clmValue,3);

        nexttile(season)
        draw_map(simValue)
        caxis(l)
        draw_provinces
        text_corner(strs.axis_simValue+" "+strs.title_seasonNames(season),'lb');

        nexttile(season+4)
        draw_map(clmValue)
        caxis(l)
        draw_provinces
        text_corner("HYCOM "+strs.title_seasonNames(season),'lb');

        x=simValue(mask_rho==1);
        y=clmValue(mask_rho==1);
        [r,p]=get_r(x,y);
        ioa=get_ioa(x,y);
        mb=get_mb(x,y);
        fprintf("MB=%.3f r=%.2f p=%.5f IOA=%.2f \n",mb,r,p,ioa)
        text_corner("mb="+round(mb,3) + newline + "r="+round(r,2) + "*" + newline +"ioa="+round(ioa,2),'rb',fontColor='w',backgroundTransparent=1)

    end

    graphData.mainNclColor(1);

    c=colorbar;
    c.Label.String=strs.axis_concentrationMgPerL;
    c.Layout.Tile = 'east';
    apply_font
    set_gcf_size(960,420)
    set(gcf,'color','w')
    set(gcf, 'InvertHardCopy', 'off'); %如果不加这一行，白色字体会变成黑色（https://ww2.mathworks.cn/matlabcentral/answers/102484-why-does-my-white-text-become-black-in-my-figure-when-printing-to-an-emf-file-in-matlab-7-5-r2007b）