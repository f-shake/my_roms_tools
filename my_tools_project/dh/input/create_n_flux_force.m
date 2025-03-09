tic
configs

nc =fullfile(roms.project_dir,"roms_nflux.nc");
GEOSChemFolder="data/GEOSChem";
demoFile=fullfile(GEOSChemFolder,"GEOSChem.DryDep.20200101_0000z");
wetFactor=2142.3;
dryFactor=1.9342;
totalFactor=1;


%确定网格
[lon_rho,lat_rho]=roms_load_grid_rho;
minRomsLon=min(lon_rho,[],'all');
maxRomsLon=max(lon_rho,[],'all');
minRomsLat=min(lat_rho,[],'all');
maxRomsLat=max(lat_rho,[],'all');
glon=read_data(demoFile,"lon");
glat=read_data(demoFile,"lat");
glonIndex1=find(glon<minRomsLon,1,'last')-1;
glonIndex2=find(glon>maxRomsLon,1,'first');
glatIndex1=find(glat<minRomsLat,1,'last')-1;
glatIndex2=find(glat>maxRomsLat,1,'first');
targetLon=glon(glonIndex1:glonIndex2);
targetLat=glat(glatIndex1:glatIndex2);
[targetLON,targetLAT]=meshgrid(targetLon,targetLat);
targetLON=targetLON';
targetLAT=targetLAT';
gridSizeM2=ones(size(targetLON))*(targetLon(2)-targetLon(1))*(targetLat(2)-targetLat(1))*111*111*1000*1000;
gridSizeM2=gridSizeM2.*cosd(targetLAT);
factors = [1.47126, 2.56284, 2.17916, 1.90583, 1.6714, 2.39245, 3.4203, 4.06685, 2.87293, 2.5364, 2.96976, 2.07984];

times=datetime(2021,1,1):datetime(2022,1,1);
NO3=zeros([size(targetLON),length(times)]);
NH4=NO3;
rawWetNO3=NO3;
rawWetNH4=NO3;
rawDryNO3=NO3;
rawDryNH4=NO3;
timeIndex=0;
for time=times
    disp(time)
    timeIndex=timeIndex+1;
    wetFile=sprintf(GEOSChemFolder+"/GEOSChem.WetLossLS.%04d%02d%02d_0000z",year(time)-1,month(time),day(time));
    dryFile=sprintf(GEOSChemFolder+"/GEOSChem.DryDep.%04d%02d%02d_0000z",year(time)-1,month(time),day(time));
    % wet:kg s-1
    wetNO3=read_data(wetFile,"WetLossLS_NIT",[glonIndex1,glatIndex1,1,1],[length(targetLon),length(targetLat),1,1]);
    wetNH4=read_data(wetFile,"WetLossLS_NH4",[glonIndex1,glatIndex1,1,1],[length(targetLon),length(targetLat),1,1]);
    % dry:molec cm-2 s-1
    dryNO3=read_data(dryFile,"DryDep_NIT",[glonIndex1,glatIndex1,1],[length(targetLon),length(targetLat),1]);
    dryNH4=read_data(dryFile,"DryDep_NH4",[glonIndex1,glatIndex1,1],[length(targetLon),length(targetLat),1]);
    
    wetNO3=processWet(wetNO3,62.007,gridSizeM2);
    wetNH4=processWet(wetNH4,18.04,gridSizeM2);
    dryNO3=processDry(dryNO3);
    dryNH4=processDry(dryNH4);
    NO3(:,:,timeIndex)=(wetNO3*wetFactor+dryNO3*dryFactor)*totalFactor;
    NH4(:,:,timeIndex)=(wetNH4*wetFactor+dryNH4*dryFactor)*totalFactor;
    %NO3(:,:,timeIndex)=40*(wetNO3*200+dryNO3)./factors(month(time));
    %NH4(:,:,timeIndex)=40*(wetNH4*200+dryNH4)./factors(month(time));
    rawWetNO3(:,:,timeIndex)=wetNO3;
    rawWetNH4(:,:,timeIndex)=wetNH4;
    rawDryNO3(:,:,timeIndex)=dryNO3;
    rawDryNH4(:,:,timeIndex)=dryNH4;
end




%创建nc
disp("正在写入nc文件")
ncid = netcdf.create(nc,'nc_clobber');

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'type', 'radiation forcing file');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'gridid','combined grid');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',['Created by "' mfilename '" on ' datestr(now)]);

lon_dimID = netcdf.defDim(ncid,'xr',length(targetLon));
lat_dimID = netcdf.defDim(ncid,'er',length(targetLat));
t_dimID = netcdf.defDim(ncid,'time',length(times));

tID = netcdf.defVar(ncid,'time','double',t_dimID);
netcdf.putAtt(ncid,tID,'long_name','atmospheric forcing time');
netcdf.putAtt(ncid,tID,'units','days');
netcdf.putAtt(ncid,tID,'field','time, scalar, series');

lonID = netcdf.defVar(ncid,'lon','double',[lon_dimID lat_dimID]);
netcdf.putAtt(ncid,lonID,'long_name','longitude');
netcdf.putAtt(ncid,lonID,'units','degrees_east');
netcdf.putAtt(ncid,lonID,'field','xp, scalar, series');

latID = netcdf.defVar(ncid,'lat','double',[lon_dimID lat_dimID]);
netcdf.putAtt(ncid,latID,'long_name','latitude');
netcdf.putAtt(ncid,latID,'units','degrees_north');
netcdf.putAtt(ncid,latID,'field','yp, scalar, series');


NO3dID = netcdf.defVar(ncid,'NO3_airsea','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(ncid,NO3dID,'long_name','NO3 air sea flux');
netcdf.putAtt(ncid,NO3dID,'units','millimole N day-1 meter-2');
netcdf.putAtt(ncid,NO3dID,'field','NO3_airsea, scalar, series');
netcdf.putAtt(ncid,NO3dID,'coordinates','lon lat');
netcdf.putAtt(ncid,NO3dID,'time','time');


NO3dID = netcdf.defVar(ncid,'rawWetNO3','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(ncid,NO3dID,'long_name','NO3 air sea flux');
netcdf.putAtt(ncid,NO3dID,'units','millimole N day-1 meter-2');
netcdf.putAtt(ncid,NO3dID,'field','NO3_airsea, scalar, series');
netcdf.putAtt(ncid,NO3dID,'coordinates','lon lat');
netcdf.putAtt(ncid,NO3dID,'time','time');

NO3dID = netcdf.defVar(ncid,'rawDryNO3','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(ncid,NO3dID,'long_name','NO3 air sea flux');
netcdf.putAtt(ncid,NO3dID,'units','millimole N day-1 meter-2');
netcdf.putAtt(ncid,NO3dID,'field','NO3_airsea, scalar, series');
netcdf.putAtt(ncid,NO3dID,'coordinates','lon lat');
netcdf.putAtt(ncid,NO3dID,'time','time');


NH4ID = netcdf.defVar(ncid,'NH4_airsea','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(ncid,NH4ID,'long_name','NH4 air sea flux');
netcdf.putAtt(ncid,NH4ID,'units','millimole N day-1 meter-2');
netcdf.putAtt(ncid,NH4ID,'field','NH4_airsea, scalar, series');
netcdf.putAtt(ncid,NH4ID,'coordinates','lon lat');
netcdf.putAtt(ncid,NH4ID,'time','time');

NH4ID = netcdf.defVar(ncid,'rawWetNH4','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(ncid,NH4ID,'long_name','NH4 air sea flux');
netcdf.putAtt(ncid,NH4ID,'units','millimole N day-1 meter-2');
netcdf.putAtt(ncid,NH4ID,'field','NH4_airsea, scalar, series');
netcdf.putAtt(ncid,NH4ID,'coordinates','lon lat');
netcdf.putAtt(ncid,NH4ID,'time','time');

NH4ID = netcdf.defVar(ncid,'rawDryNH4','double',[lon_dimID lat_dimID t_dimID]);
netcdf.putAtt(ncid,NH4ID,'long_name','NH4 air sea flux');
netcdf.putAtt(ncid,NH4ID,'units','millimole N day-1 meter-2');
netcdf.putAtt(ncid,NH4ID,'field','NH4_airsea, scalar, series');
netcdf.putAtt(ncid,NH4ID,'coordinates','lon lat');
netcdf.putAtt(ncid,NH4ID,'time','time');


netcdf.close(ncid)

%写入数据
ncwrite(nc,'lon',targetLON);
ncwrite(nc,'lat',targetLAT);
ncwrite(nc,'time',datenum(times)- datenum(roms.time.base));
ncwrite(nc,'NO3_airsea',NO3);
ncwrite(nc,'NH4_airsea',NH4);
ncwrite(nc,'rawWetNO3',rawWetNO3);
ncwrite(nc,'rawWetNH4',rawWetNH4);
ncwrite(nc,'rawDryNO3',rawDryNO3);
ncwrite(nc,'rawDryNH4',rawDryNH4);

toc
function data=processWet(data,gPerMol,gridSizeM2) %kg s-1
    data(data<0)=0;
    data=data.*1000; %g s-1
    data=data.*86400; %g d-1
    data=data./gPerMol.*1000; %mmol d-1
    data=data./gridSizeM2; %mmol m-2 d-1
end

function data=processDry(data) %molec cm-2 s-1
    data(data<0)=0;
    data=data*10000; %molec m-2 s-1
    data=data.*86400; %molec m-2 d-1
    data=data./6.02214076e23*1000; %mmol m-2 d-1
end
