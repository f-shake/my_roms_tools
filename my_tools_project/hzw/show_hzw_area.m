function show_hzw_area(baseDir,traceGridFile)
    [lon_rho,lat_rho,mask_rho,h]=roms_load_grid_rho;
    configs
    lon=[min(lon_rho+0.05,[],"all"),max(lon_rho+0.05,[],"all")];
    lat=[min(lat_rho,[],"all"),max(lat_rho,[],"all")];
    project_data
    clf


    %% 画一些空图用于生成图例
    hold on
    plot(0,0,'.r',MarkerSize=12)
    plot(0,0,'.c',MarkerSize=12)
    plot(0,0,'.y',MarkerSize=12)
    plot(0,0,'.k',MarkerSize=12)

    %% 绘制底图
    h(mask_rho==0)=0;
    pcolorjw(lon_rho,lat_rho,h)

    color_blue_green_yellow(-14);
    c=colorbar;
    c.Position=[0.25,0.47,0.03,0.25];
    c.Label.String= strs.colorbar_waterDepth;
    color_ocean(256)
    caxis([0,40])
    apply_font(c);

    fill(projectData.studyRange(:,1),projectData.studyRange(:,2),'r',FaceAlpha=0)

    %% 绘制矢量图
    s=shaperead(fullfile(baseDir,'县合并.shp'));
    configs
    for i=1:length(s)
        x=s(i).X;y=s(i).Y;l=length(x);
        to=1;from=1;
        while(to<=l)
            if isnan(x(to))
                fill(x(from:to-1),y(from:to-1),graphData.landColor);
                to=to+1;
                from=to;
            else
                to=to+1;
            end
        end
    end

  
    %% 绘制河流和排放点
    [~,singles,means]=read_emission_table( ...
        projectData.emissionList,3, 'Name',["Type","LonLat"],["FluxPerS","CodMn","TN","TP"]);
    types=string(singles(:,1));

    lonlats=string(singles(:,2));
    lonlats=str2double(split(lonlats,','));
    fluxs=means(:,1);
    [xy,~,~]=roms_get_xy_by_lonlat_core(lonlats,"",'rho',0,1,enable=0);

    %把边缘的点往内部移一下
    for i=1:size(xy,1)
        if xy(i,1)==1
            xy(i,1)=2;
        end
        if xy(i,2)==1
            xy(i,2)=2;
        end
    end

    for i=1:length(fluxs)
        if types(i)=="企业"
            fluxs(i)=log(fluxs(i)*10000)*4;
            if fluxs(i)<5
                fluxs(i)=5;
            end
        elseif types(i)=="河流"
            fluxs(i)=log(fluxs(i))/log(2)*5;
        end
        lonlats(i,1)=lon_rho(xy(i,1),xy(i,2));
        lonlats(i,2)=lat_rho(xy(i,1),xy(i,2));
    end

    riverLonlats=lonlats(types=="河流",:);
    riverFluxs=fluxs(types=="河流",:);
    enterpriseLonlats=lonlats(types=="企业",:);
    enterpriseFluxs=fluxs(types=="企业",:);
    scatter(enterpriseLonlats(:,1),enterpriseLonlats(:,2),enterpriseFluxs,'filled',MarkerFaceColor='c')
    scatter(riverLonlats(:,1),riverLonlats(:,2),riverFluxs,'filled',MarkerFaceColor='y')

    %% 绘制潮站
    tide=[
        121.099,30.588
        121.629,30.610];
    plot(tide(:,1),tide(:,2),'.r',MarkerSize=12)
    apply_font(text(tide(1,1)+0.05,tide(1,2),strs.tide_zp,Color='r',FontSize=graphData.lagerFontSize))
    apply_font(text(tide(2,1)+0.05,tide(2,2),strs.tide_th,Color='r',FontSize=graphData.lagerFontSize))
    apply_font(text(121.37,30.5,strs.location_hangzhouBay,HorizontalAlignment='center',VerticalAlignment='middle',FontSize=graphData.lagerFontSize))

    %% 绘制源强估算点
    input=readmatrix(traceGridFile,FileType='text');
    input=fliplr(input');
    points=zeros(0,2);
    for i=1:size(input,1)
        for j=1:size(input,2)
            if input(i,j)<255 && input(i,j)>0
                points(end+1,:)=[lon_rho(i,j),lat_rho(i,j)];
            end
        end
    end
    plot(points(:,1),points(:,2),'.k',MarkerSize=12)

    
      %% 绘制行政区
    district=[
        121.5,31.1 0 -4 %上海
        120.8,30.7 0 -4 %嘉兴
        120.7,30.1 18 0 %绍兴
        121.34,30.1 7 -4 %宁波
        122.21,30.03 -8 4 %舟山
        121.76,29.97 -8 -4 %甬江口
        122.05,31.2 0 -4 %长江口
        120.72,30.3 18 -2 %钱塘江口
        ];
    %plot(district(:,1),district(:,2),'.k',MarkerSize=12);
    for i=1:size(district,1)
        name=strs.locations(i);
        x=district(i,1)+district(i,3)/100;
        y=district(i,2)+district(i,4)/100;
        apply_font(text(x,y,name,Color='k',FontSize=graphData.fontSize, HorizontalAlignment='center'))
    end
    
    %% 范围坐标系图例
    xlim([min(lon_rho,[],"all"),max(lon_rho,[],"all")])
    ylim([min(lat_rho,[],"all"),max(lat_rho,[],"all")])
    xticks(121:.5:122.5)
    yticks(30:.5:32)
    xticklabels(string(121:.5:122.5)+"°E")
    yticklabels(string(30:.5:32)+"°N")
    draw_border
    grid on
    ax=gca;
    ax.Layer='top';
    legend([strs.legend_obsStation, strs.legend_sewageOutletEmissions,strs.legend_riverEmissions,strs.legend_estimationEmissions], Location='northeast')
    equal_aspect_ratio(gca)
    apply_font

    set_gcf_size(640,640)

end
function text_center(x,y,string)
    apply_font(text(x,y,string,HorizontalAlignment='center',VerticalAlignment='middle'))
end