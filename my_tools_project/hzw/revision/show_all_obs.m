clf
project_data
t=tiledlayout(3,6);
set_tiledlayout_compact(t);
pollutionIndex=1;
[sim_x,sim_y,mask_rho]=roms_load_grid_rho;
mask_rho(mask_rho==1)=nan;

for iSeason=1:3
    months=projectData.months{iSeason};
    for year=2017:2022
        nexttile
        [obs,sites]=get_observations_of_all(projectData.obsRange(:,1),projectData.obsRange(:,2),year,months);

        [xy,water,outOfRange]=roms_get_xy_by_lonlat_core(obs(:,1:2),roms.input.grid,"rho",0,0,enable=false);
        f=~outOfRange&water;

        xy=xy(f,:);
        obs=obs(f,:);
        sites=sites(f);


        %% 地图绘制
        draw_background(sim_x,sim_y)
        pcolorjw(sim_x,sim_y,mask_rho);
        hold on
        %show_simulation_and_observation_core(sim_x,sim_y,mask_rho,obs(:,1),obs(:,2),obs(:,2+pollutionIndex),'pcolor',1,0,string(obs(:,2+pollutionIndex)));
        scatter(obs(:,1),obs(:,2),20,obs(:,2+pollutionIndex),'filled')

        scatter(obs(:,1),obs(:,2),20,'w')
        caxis([0,projectData.maxValue(pollutionIndex)*2]);
        text_corner(string(year)+" "+ strs.title_seasonNames(iSeason))
        apply_font

        c=colormap;
        c(1,:)=[0.6,0.6,0.6];
        colormap(c);
    end
end

c=colorbar;
c.Layout.Tile='east';
set_gcf_size(1200,600)