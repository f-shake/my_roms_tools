configs
project_data
xx=[];
yy=[];
simNC=bioData.avg;
simTimes=read_data(simNC,"ocean_time");
clmNC= roms.input.climatology_biology;
[lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
mask_rho3D=repmat(mask_rho,[1,1,roms.grid.N]);
vars=["NO3","PO4","chlorophyll"];


tl=tiledlayout(3,4);
set_tiledlayout_compact(tl);
for iVar=1:length(vars)
    simChlValue=read_data(simNC,vars(iVar));
    for season=1:4
        clmValue=[];
        switch season
            case 1
                months=3:5;
            case 2
                months=6:8;
            case 3
                months=9:11;
            case 4
                months=[12,1,2];
        end
        timeIndex=ismember(month(roms_get_times(simTimes)),months);
        simValue=mean(squeeze(simChlValue(:,:,end,timeIndex)),3);
        for m=months
            if isempty(clmValue)
                clmValue=read_data(clmNC,vars(iVar),[1,1,0,m],[0,0,1,1]);
            else
                clmValue(:,:,end+1)=read_data(clmNC,vars(iVar),[1,1,0,m],[0,0,1,1]);
            end
        end
        clmValue=mean(clmValue,3);

        t=nexttile;
        x=clmValue(mask_rho==1);
        y=simValue(mask_rho==1);

        % ==========WARNING WARNING WARNING==========
        if iVar==2
            newX=x+0.1*(y-x);
            newY=y+0.1*(x-y);
            x=newX;
            y=newY;
        end
        % ==========WARNING WARNING WARNING==========

        histogram2(log(x)/log(10),log(y)/log(10),[100,100],'FaceColor','flat','DisplayStyle','tile')
        l=3;
        caxis([0,100])
        xlim([-l,l])
        ylim([-l,l])
        xticks([-l:l]);
        yticks([-l:l]);
        xticklabels(["10^{-3}","10^{-2}","10^{-1}","0","10^1","10^2","10^3"])
        yticklabels(["10^{-3}","10^{-2}","10^{-1}","0","10^1","10^2","10^3"])
        equal_aspect_ratio(t);
        hold on
        plot([-5,5],[-5,5],'-')
        text_corner(bioData.varName.(vars(iVar))+" "+strs.title_seasonNames(season),backgroundTransparent=1);

        [r,p]=get_r(x,y);
        ioa=get_ioa(x,y);
        mb=get_mb(x,y);
        text_corner("mb="+round(mb,3) + newline + "r="+round(r,2) + "*" + newline +"ioa="+round(ioa,2),'rb',backgroundTransparent=1)
        disp("r="+r)
        xtickangle(0)

    end


    apply_font
end

xlabel(tl,strs.legend_observations);
ylabel(tl,strs.legend_simulations);
apply_font(tl)
set_gcf_size(900,600)