clear;clf;
configs;
extrapolationMethod='linear';
xmin=120; xmax=123;
ymin=29; ymax=32;
figxmin=120.5; figxmax=122.5;
figymin=29.85; figymax=32;
step=.2;
cmax=3;
obs=get_observations_of_all(roms.trace.obsRange(:,1),roms.trace.obsRange(:,2),2017,10:11);
F=scatteredInterpolant(obs(:,1),obs(:,2),obs(:,3),'natural',extrapolationMethod);
configs;

[lon_rho,lat_rho,mask_rho]= roms_load_grid_rho;
value=F(lon_rho,lat_rho);
value(mask_rho==0)=nan;
hold on;
contourf(lon_rho,lat_rho,value,ShowText=1,LevelStep=step);
scatter(obs(:,1),obs(:,2),'.');

xlim([figxmin,figxmax])
ylim([figymin,figymax])
caxis([0,cmax]);

colorbar

xlabel('经度')
ylabel('纬度')
