folder="C:\Users\autod\Downloads\www.ncei.noaa.gov";
files=strtrim(string(ls(folder)));
files=files(endsWith(files,".nc"));
files=folder+"/"+files;

refNC=files(1);
refLon=ncread(refNC,"lon");
refLat=ncread(refNC,"lat");
%refLat=flip(refLat);

simNC="ocean_avg.nc";
simLON=ncread(simNC,"lon_rho");
simLAT=ncread(simNC,"lat_rho");
simSST=ncread(simNC,"temp");
%load("avg.mat")
simSST=squeeze(simSST(:,:,end,1:6));
simSST=mean(simSST,3);

lon1=min(simLON,[],'all');
lon2=max(simLON,[],'all');
lat1=min(simLAT,[],'all');
lat2=max(simLAT,[],'all');

idxLeft=find(refLon>lon1,1);
idxRight=find(refLon<lon2,1,"last");
idxBottom=find(refLat>lat1,1,"last");
idxTop=find(refLat<lat2,1);
refLon=refLon(idxLeft:idxRight);
refLat=refLat(idxTop:idxBottom);


[refLON,refLAT]=meshgrid(refLon,refLat);
refLON=double(refLON');
refLAT=double(refLAT');

refSST=nan(idxRight-idxLeft+1,idxBottom-idxTop  +1,length(files));

for i=1:length(files)
    file=files(i);
    disp(file);
    singleSST=ncread(file,"sea_surface_temperature",[idxLeft,idxTop,1],[length(refLon),length(refLat),1])-273.15;
   %singleSST= fliplr(singleSST);
     quality=ncread(file,"quality_level",[idxLeft,idxTop,1],[length(refLon),length(refLat),1]);
   % singleSST(quality<=2)=nan;
singleSST(singleSST<5)=nan;
refSST(:,:,i)=singleSST;
    %refSST=ncread(refNC,"sea_surface_temperature")-273.5;
    %refSST=fliplr(refSST);
    %quality=ncread(refNC,"quality_level");
    %quality=fliplr(quality);
    %refSST(quality<0)=nan;

end
refSST=double(mean(refSST,3,'omitnan'));






%F=scatteredInterpolant(refLON(indexs),refLAT(indexs),refSST(indexs));
F=scatteredInterpolant(simLON(:),simLAT(:),simSST(:));

simValueInRefLocations=F(refLON,refLAT);


clf
tiledlayout(2,2);
nexttile
pcolorjw(refLON,refLAT,refSST)
caxis([4,28]);
colorbar;
title("AVHRR")
nexttile
pcolorjw(refLON,refLAT,simValueInRefLocations);
caxis([4,28]);
colorbar;
title("模拟")
nexttile
pcolorjw(refLON,refLAT,simValueInRefLocations-refSST);
colorbar;
title("差异")
nexttile
histogram2(simValueInRefLocations,refSST,[100,100],'FaceColor','flat')
hold on
plot([5,25],[5,25])
title("直方图")

indexs=~isnan(simValueInRefLocations) &  refSST>0 ;
simValueInRefLocations=simValueInRefLocations(indexs);
refSST=refSST(indexs);
corrcoef(refSST,simValueInRefLocations)


