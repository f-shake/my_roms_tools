function draw_2var_correlation(var1,var2,location)
    clf
    project_data
    xy=roms_get_xy_by_lonlat_core(location,enable=false);
    var1Data=squeeze(read_data(bioData.tests(1),var1,[xy,0,1],[1,1,1,0]));
    var2Data=squeeze(read_data(bioData.tests(1),var2,[xy,0,1],[1,1,1,0]));
    scatter(var1Data,var2Data,20,'filled')
    r=get_r(var1Data,var2Data);
    text_corner("r="+string(round(r,2)))