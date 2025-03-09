function show_contributions(nc)
    project_data
    sums=zeros(traceData.partCount,1);
    tl=tiledlayout(2,3);
    set_tiledlayout_compact(tl)
    set_gcf_size(600,340)
    [lon_rho,lat_rho,~]=roms_load_grid_rho;
    inrange=inpolygon(lon_rho,lat_rho,projectData.studyRange(:,1),  projectData.studyRange(:,2));
    volume=roms_get_volumes;
    for i=1:length(traceData.partNames)
        if i<=traceData.riverPartCount
            ax=nexttile(i);
        else
            ax=nexttile(i+1);
        end
        dye=roms_get_dye(nc,i,0);
        times=int16(size(dye,4)/2):size(dye,4);
        dye=mean(dye(:,:,:,times),4);
        dyeVolume=dye.*volume;
        sums(i)=sum(dyeVolume(inrange),'omitnan');
        v=sum(dye,3);
        draw_background(lon_rho,lat_rho)
        pcolorjw(lon_rho,lat_rho,v)
        caxis([0,max(v(:))])
        text_left_top("("+a2z_string(i)+")")
        apply_font
        axis off
        draw_border
        equal_aspect_ratio(ax);
    end
    graphData.mainNclColor(true);
    range=caxis;
    c=colorbar(gca,Ticks=0:(range(2)/10):range(2),TickLabels=string(0:0.1:1));
    c.Label.String=strs.axis_concentration;
    c.Layout.Tile = 'east';

    [sums,newIndexs]=sort(sums);
    for i=traceData.partCount:-1:1
        fprintf("%-10s%.2g\n",traceData.partNames(newIndexs(i)),sums(i)/sum(sums)*100)
    end