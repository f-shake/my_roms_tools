his=[30.6+4.35 0.50]; %μmol/L or 10^-3 mol/m^3
cur=[131+5.89 2.02];
waterFlux=[0.49 0.49 0.52 0.65 1.01 1.37 1.60 1.63 1.31 1.05 0.78 0.59]; %m^3
dayOfMonths=[31,28,31,30,31,30,31,31,30,31,30,31];
clf

project_data
tl=tiledlayout(2,1);
set_tiledlayout_compact(tl);
labels=[bioData.varName.DIN,bioData.varName.PO4];
for i=1:2
    t=nexttile;
    factors=1/1000    *26749     *86400      .*dayOfMonths.*waterFlux;
    %        mol/m^3   mol/s     mol/day       mol/month
    hisFlux=his(i).*factors;
    curFlux=cur(i).*factors;
    temp=[14.01,30.97];
    disp(sum(curFlux)*temp(i)/1e6/1e4)

    b=bar(1:12,[curFlux;hisFlux]);
    ylabel("flux (10^6 mol)")
    text_corner(labels(i))
    ylim([0,max(curFlux)*1.1])
    set(t,'YTickLabel',string(get(t,'YTick')/(10e6)))

    b(1).FaceColor = [255, 92, 40]/256;
    b(2).FaceColor = [120, 120, 255]/256;

    xticks(1:12);
    xlabel("Month")
    draw_border
    legend(["2012","1982"])
end
set_gcf_size(400,400)