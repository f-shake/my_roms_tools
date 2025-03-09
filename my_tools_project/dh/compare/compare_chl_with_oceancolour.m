project_data

clf
months={3:5,6:8,9:11,[12,1,2]};
tl=tiledlayout(1,4);
set_tiledlayout_compact(tl)
for m=1:4
selectMonth=months{m};

folder="data/OceanColour";
files=strtrim(string(ls(folder)));
files=files(endsWith(files,".nc"));
files=folder+"/"+files;

refNC=files(selectMonth);
refLon=ncread(refNC(1),"lon");
refLat=ncread(refNC(1),"lat");
%refLat=flip(refLat);

simLON=read_data(bioData.avg,"lon_rho");
simLAT=read_data(bioData.avg,"lat_rho");
simTimes=read_data(bioData.avg,"ocean_time");
timeIndex=ismember(selectMonth,month(roms_get_times(simTimes)));
simValue=read_data(bioData.avg,"chlorophyll");
%load("avg.mat")
simValue=squeeze(simValue(:,:,end,timeIndex));
simValue=mean(simValue,3);

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

refValue=nan(idxRight-idxLeft+1,idxBottom-idxTop+1,length(files));

for i=1:length(refNC)
    file=refNC(i);%files(i);
    disp(file);
    singleRefValue=ncread(file,"chlor_a",[idxLeft,idxTop,1],[length(refLon),length(refLat),1]);
    refValue(:,:,i)=singleRefValue;

end
refValue=double(mean(refValue,3,'omitnan'));






%F=scatteredInterpolant(refLON(indexs),refLAT(indexs),refSST(indexs));
F=scatteredInterpolant(double(simLON(:)),double(simLAT(:)),double(simValue(:)));

simValueInRefLocations=F(refLON,refLAT);


% tiledlayout(2,2);
% nexttile
% pcolorjw(refLON,refLAT,refValue)
% caxis([0,8]);
% colorbar;
% title("参考")
% nexttile
% pcolorjw(refLON,refLAT,simValueInRefLocations);
% caxis([0,8]);
% colorbar;
% title("模拟")
% nexttile
% pcolorjw(refLON,refLAT,simValueInRefLocations-refValue);
% colorbar;
% title("差异")
nexttile
histogram2(log(simValueInRefLocations),log(refValue),[100,100],'FaceColor','flat','DisplayStyle','tile')
hold on
plot([-4,4],[-4,4])
xlim([-4,4])
ylim([-4,4])
% title("直方图")

indexs=~isnan(simValueInRefLocations) &  refValue>0 ;
simValueInRefLocations=simValueInRefLocations(indexs);
refValue=refValue(indexs);
corrcoef(refValue,simValueInRefLocations)


end

