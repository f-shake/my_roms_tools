function show_dh_area
    [~,~,mask_rho,h]=roms_load_grid_rho;
    configs
    project_data
    clf


    %% 画一些空图用于生成图例
    hold on
    %     plot(0,0,'.c',MarkerSize=12)
    %     plot(0,0,'.b',MarkerSize=12)
    plot(0,0,'.k',MarkerSize=12)
    plot(0,0,'.r',MarkerSize=12)

    %% 绘制底图
    h(mask_rho==0)=0;
    draw_map(h,'lgf')

    c=colorbar('eastoutside');
    %c.Position=[0.22,0.47,0.03,0.25];

    c.Label.String= strs.colorbar_waterDepth;
    c.Ticks=[10,20,50,100,200,500,1000,2000,4000,8000];
    color_ocean(256);

    set(gca,'ColorScale','log')
    caxis([10,8000])
    %% 绘制矢量省界
    draw_provinces(false)

    text_center(120,29.2,bioData.provinces.Zhejiang)
    text_center(120,33,bioData.provinces.Jiangsu)
    text_center(121.4,31.2,bioData.provinces.Shanghai)
    text_center(118,26,bioData.provinces.Fujian)
    text_center(121.6,30.6,bioData.provinces.HangzhouBay)
    text_center(120.9,23.7,bioData.provinces.Taiwan)


    %% 绘制典型海域位置
    scatterm(bioData.locations(:,2),bioData.locations(:,1),20,'k','filled',Marker="square")
    textm(bioData.locations(:,2),bioData.locations(:,1)+0.2,bioData.locationNames,FontName=graphData.font,Color='k');

    scatterm(bioData.rivers(:,2),bioData.rivers(:,1),20,'r','filled',Marker="square")

    %% 图元素设置
    apply_font
    legend("",strs.legend_typicalSeaAreas,strs.legend_estuary)
    set_gcf_size(640,640)

end
function text_center(x,y,string)
    project_data
    textm(y,x,string,HorizontalAlignment='center',VerticalAlignment='middle',FontName=graphData.font)
end