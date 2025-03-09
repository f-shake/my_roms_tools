clear;close all;
path=fileparts(mfilename('fullpath'));
file=fullfile(path,'ParseWaterQualityJson','bin','Debug','net6.0','waters.txt');
[sites,years,months,lons,lats,cods,s,ps]=readvars(file);

[lon,lat,mask]=roms_load_grid_rho;
mask(mask==1)=nan;

rangeF=lons>min(lon,[],'all')&lons<max(lon,[],'all')&lats>min(lat,[],'all')&lats<max(lat,[],'all');

quaters={[3:5],[6:8],[9:11]};
quaterNames='春夏秋';
[lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
mask_rho(mask_rho==1)=nan;
f2=figure(2);
figure(1);
tiledlayout(3,length(unique(years)));
for year=unique(years)'
    for quater=1:3
        figure(1);
        nexttile
        label=[num2str(year),'年',quaterNames(quater),'季'];
        for i=1:2
            figure(i);
            tempF=zeros(size(months));
            for month=quaters{quater}
                tempF=tempF|month==months;
            end
            f=tempF&rangeF&years==year;

            pcolorjw(lon_rho,lat_rho,mask_rho);
            hold on
            scatter(lons(f),lats(f),20,cods(f),'filled')
            %scatter(lons(f),lats(f),20,'w')
            caxis([0,5])
            title(label)
            apply_font
        end
        colorbar
        exportgraphics(f2,[label,'.png'],Resolution=300);
    end
end
figure(1)
cbh = colorbar;
cbh.Layout.Tile = 'east';
close(f2);