project_data
clf

[names,singles,means]=read_emission_table( ...
    projectData.emissionList,3, 'Name',["Type","LonLat"],["FluxPerS","CodMn","TN","TP"]);
pollutionTypes=3;
types=string(singles(:,1));

[lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
minx=min(lon_rho(:));
mask_rho(mask_rho==0)=nan;
draw_background(lon_rho,lat_rho)
colormap([0, 145, 234;0, 145, 234]/255)
hold on
pcolorjw(lon_rho,lat_rho,mask_rho)
lonlats=string(singles(:,2));
lonlats=str2double(split(lonlats,','));
fluxs=means(:,1);
[xy,waterPoint,outOfRange]=roms_get_xy_by_lonlat_core(lonlats,"",'rho',0,1,enable=0);

for i=1:length(fluxs)
    if types(i)=="企业"
        fluxs(i)=log(fluxs(i)*10000)*4;
        if fluxs(i)<5
            fluxs(i)=5;
        end
    elseif types(i)=="河流"
        fluxs(i)=log(fluxs(i))/log(2)*5;
    end
    lonlats(i,1)=lon_rho(xy(i,1),xy(i,2));
    lonlats(i,2)=lat_rho(xy(i,1),xy(i,2));
end

riverLonlats=lonlats(types=="河流",:);
riverFluxs=fluxs(types=="河流",:);
enterpriseLonlats=lonlats(types=="企业",:);
enterpriseFluxs=fluxs(types=="企业",:);
scatter(enterpriseLonlats(:,1),enterpriseLonlats(:,2),enterpriseFluxs,'filled',MarkerFaceColor=[0,1,0])
scatter(riverLonlats(:,1),riverLonlats(:,2),riverFluxs,'filled',MarkerFaceColor=[1,0,0])
equal_aspect_ratio(gca)
legend(["","",strs.legend_sewageOutletEmissions,strs.legend_riverEmissions])

x=xlim;
width=x(2)-x(1);
xlim([x(1)-width/50,x(2)+width/50]);
y=ylim;
height=y(2)-y(1);
ylim([y(1)-height/50,y(2)+height/50])
set_gcf_size(400)

apply_font