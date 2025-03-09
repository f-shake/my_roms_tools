%检查东海范围内施加的大气氮沉降的总量
clear
clf
project_data
targetOnly=1;
file="roms_nflux.nc";
wet=read_data(file,"rawWetNO3")+read_data(file,"rawWetNH4");
dry=read_data(file,"rawDryNO3")+read_data(file,"rawDryNH4");
target=read_data(file,"NO3_airsea")+read_data(file,"NH4_airsea");%通过create_n_flux_force.m后生成的文件
lon=read_data(file,"lon");
lat=read_data(file,"lat");
[lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;

%gridSizeM2=ones(size(lon))*(lon(2)-lon(1))*(lat(2)-lat(1))*111*111*1000*1000;
%gridSizeM2=gridSizeM2.*cosd(lat);
totalWet=0;
totalDry=0;
totalTarget=0;
mapData=zeros(size(mask_rho));

for i=1:size(wet,3)
    targetT=target(:,:,i);
    wetT=wet(:,:,i);
    dryT=dry(:,:,i);
    filter=inpolygon(lon_rho,lat_rho,bioData.dh(:,1),bioData.dh(:,2)) ...
        & mask_rho==1;
    if ~targetOnly
        F=scatteredInterpolant(lon(:),lat(:),wetT(:));
        wetT=F(lon_rho,lat_rho);
        F=scatteredInterpolant(lon(:),lat(:),dryT(:));
        dryT=F(lon_rho,lat_rho);
        totalWet=totalWet+mean(wetT(filter));
        totalDry=totalDry+mean(dryT(filter));
    end
    F=scatteredInterpolant(lon(:),lat(:),targetT(:));
    targetT=F(lon_rho,lat_rho);
    totalTarget=totalTarget+mean(targetT(filter));
    targetT(mask_rho==0)=0;
    mapData=mapData+targetT;
    disp([i,totalWet,totalDry,totalTarget])

end

draw_map(mapData,'b');
bioData.mainNclColor(1)
c=colorbar;
c.Label.String="mmol m^{-2} y^{-1}";
caxis([0,200])