project_data
clf
path=fileparts(mfilename('fullpath'));
file=fullfile(path,'ParseWaterQualityJson','bin','Debug','net6.0','waters.txt');
[sites,years,months,lons,lats,cods,s,ps]=readvars(file);

[lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
f=years==2018 & ismember(months,3:5) & inpolygon(lons,lats,projectData.obsRange(:,1),projectData.obsRange(:,2));
draw_background(lon_rho,lat_rho)
hold on
mask_rho(mask_rho==0)=nan;
colormap([0, 145, 234;0, 145, 234]/255)
pcolorjw(lon_rho,lat_rho,mask_rho);
scatter(lons(f),lats(f),20,'filled',MarkerFaceColor='y')
draw_border
equal_aspect_ratio(gca)