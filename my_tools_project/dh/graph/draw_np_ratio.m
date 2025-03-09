clf
configs
project_data
tl=tiledlayout(2,2);
set_tiledlayout_compact(tl);
for i=1:4
    disp(bioData.testNames(i))
    nexttile
    file=bioData.tests(i);
    n=read_data(file,"NO3",[1,1,0,1],[0,0,1,0])+read_data(file,"NH4",[1,1,0,1],[0,0,1,0]);
    p=read_data(file,"PO4",[1,1,0,1],[0,0,1,0]);

    n=mean(n,4);
    p=mean(p,4);
    np=n./p;
    [lon,lat]=roms_load_grid_rho;
    plot(0,0,'-w');
    hold on
    draw_map(np,'gl');
    contourm(lat,lon,np,'-w',LevelList=16);
    caxis([0,80])
    text_corner("("+a2z_string(i)+") "+ bioData.testNames(i),'rb')

    draw_provinces
end
c=colorbar;
c.Label.String="N/P";
c.Layout.Tile = 'south';
l=legend("","N:P=16:1",Color='#8f8fff',TextColor=[1,1,1]);
l.Layout.Tile = 'south';
apply_font
graphData.mainNclColor(true);
set_gcf_size(500,500)
set(gcf,'color','w')
set(gcf, 'InvertHardCopy', 'off'); %如果不加这一行，白色字体会变成黑色（https://ww2.mathworks.cn/matlabcentral/answers/102484-why-does-my-white-text-become-black-in-my-figure-when-printing-to-an-emf-file-in-matlab-7-5-r2007b）