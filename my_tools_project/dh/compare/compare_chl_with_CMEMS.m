xx=[];
yy=[];
for selectMonth=1:12
    disp(selectMonth)
    refFile="data/CMEMS/b2021"+num2str(selectMonth,"%02d")+".nc";
    simNC="base1108a";
    dim=4;

    refLon=ncread(refFile,"longitude");
    refLat=ncread(refFile,"latitude");

    simLON=read_data(simNC,"lon_rho");
    simLAT=read_data(simNC,"lat_rho");
    simTimes=read_data(simNC,"ocean_time");
    timeIndex=month(roms_get_times(simTimes))==selectMonth;
    if dim==3
        simValue=read_data(simNC,"chlorophyll_sur");
        simValue=squeeze(simValue(:,:,timeIndex));
    elseif dim==4
        simValue=read_data(simNC,"chlorophyll");
        simValue=squeeze(simValue(:,:,end,timeIndex));
    end
    %load("avg.mat")
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

    refValue=nan(idxRight-idxLeft+1,idxBottom-idxTop+1,50);


    singleRefValue=ncread(refFile,"chl",[idxLeft,idxTop,1,1],[length(refLon),length(refLat),50,1]);
    refValue(:,:,:)=singleRefValue;
    refValue=refValue(:,:,1);
    %从ROMS网格插值到CMEMS网格

    F=scatteredInterpolant(double(simLON(:)),double(simLAT(:)),simValue(:));

    simValueInRefLocations=F(refLON,refLAT);


    % clf
    % tiledlayout(2,2);
    % nexttile
    % pcolorjw(refLON,refLAT,refValue)
    % caxis([0,5]);
    % colorbar;
    % title("参考")
    % nexttile
    % pcolorjw(refLON,refLAT,simValueInRefLocations);
    % caxis([0,5]);
    % colorbar;
    % title("模拟")
    % nexttile
    % pcolorjw(refLON,refLAT,simValueInRefLocations-refValue);
    % colorbar;
    % title("差异")
    % nexttile
    % histogram2(simValueInRefLocations,refValue,[100,100],FaceColor='flat',DisplayStyle='tile')
    % hold on
    % color_blue_yellow_red(10)
    % plot([0,10],[0,10])
    % xlim([0,2]);
    % ylim([0,2]);
    % title("直方图")

    indexs=~isnan(simValueInRefLocations) &  refValue>0 ;
    simValueInRefLocations=simValueInRefLocations(indexs);
    refValue=refValue(indexs);

    if  isempty(xx)
        xx=simValueInRefLocations;
        yy=refValue;
    else
        xx=[xx;simValueInRefLocations];
        yy=[yy;refValue];
    end
end
r=get_r(xx,yy)
ioa=get_ioa(xx,yy)
mb=get_mb(xx,yy)
figure
%histogram2(xx,yy,[100,100],FaceColor='flat',DisplayStyle='tile')
plot(xx,yy,'.');
hold on
color_blue_yellow_red(10)
plot([0,10],[0,10],'-')
xlim([0,10]);
ylim([0,10]);
title("直方图")