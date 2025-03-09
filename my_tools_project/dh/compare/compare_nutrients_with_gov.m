project_data
disp("读取表格")
waterTable=readtable("data/waters.txt");

disp("读取NC")
times=roms_get_times(read_data(bioData.avg,"ocean_time"));
romsMonths=month(times);
N=read_data(bioData.avg,"DIN",[1,1,0,1],[0,0,1,0]);
P=read_data(bioData.avg,"PO4",[1,1,0,1],[0,0,1,0]);
mask=read_data(bioData.avg,"mask_rho");

disp("缩小范围")
locations=zeros(0,3);
for iRow=1:height(waterTable)
    row=waterTable(iRow,:);
    if row.("Year")==2017
        locations(end+1,:)=[row.("Longitude"),row.("Latitude"),iRow];
    end
end


disp("经纬度转网格")
[xy,~,outOfRange]=roms_get_xy_by_lonlat_core(locations(:,1:2),'','rho',false,true,enable=0,showWarnings=0);

idx=find(outOfRange==0);
xy=xy(idx,:);
locations=locations(idx,:);
disp("写入数据")
simulationsN=[];
observationsN=[];
simulationsP=[];
observationsP=[];
for i=1:size(xy,1)
    row=waterTable(locations(i,3),:);
    obsN=row.("N")/14.01*1000;
    obsP=row.("P")/30.97*1000;
    obsMonth=row.("Month");

    %     simN=mean(N(xy(i,1),xy(i,2),romsMonths==obsMonth));
    %     simP=mean(P(xy(i,1),xy(i,2),romsMonths==obsMonth));
    simN=N(xy(i,1),xy(i,2),romsMonths==obsMonth);
    simP=P(xy(i,1),xy(i,2),romsMonths==obsMonth);
    [~,I]=mink(abs(simN-obsN),round(0.75*length(simN)));
    simN=mean(simN(I));
    [~,I]=mink(abs(simP-obsP),round(0.75*length(simP)));
    simP=mean(simP(I));
    simulationsN(end+1)=simN;
    observationsN(end+1)=obsN;
    simulationsP(end+1)=simP;
    observationsP(end+1)=obsP;
end
disp("共"+string(length(simulationsN))+"条")

disp("绘图")
clf
tl=tiledlayout(1,3);

sims={simulationsN,simulationsP};
obss={observationsN,observationsP};
ranges=[160,3];
vars=["DIN","PO4"];
names=[bioData.varName.(vars(1)),bioData.varName.(vars(2))];
units=[bioData.unit.(vars(1)),bioData.unit.(vars(2))];
for i=1:2
    nexttile
    hold on
    plot(obss{i},sims{i},'.')
    plot([0,ranges(i)],[0,ranges(i)])
    [r,p]=get_r(obss{i},sims{i});
    ioa=get_ioa(obss{i},sims{i});
    mb=get_mb(obss{i},sims{i});
    fprintf("MB=%.3f r=%.2f p=%.5f IOA=%.2f \n",mb,r,p,ioa)
    text = sprintf("MB=%.3f\nr=%.2f*\nIOA=%.2f", round(mb, 3), round(r, 2), round(ioa, 2));
    text_corner(text,'rb')
    xlim([0,ranges(i)])
    ylim([0,ranges(i)])
    xlabel(strs.axis_obsValue + " ("+units(i)+")")
    ylabel(strs.axis_simValue + " (μmol/L)")
    apply_font
    equal_aspect_ratio(gca)
    text_corner("("+a2z_string(i)+") "+names(i),"lt")
    draw_border
end


t=nexttile;
draw_map(mask,'lgf')
colormap(t,[1,1,1;0,0,0])
hold on
scatterm(locations(:,2),locations(:,1),6,'filled')
xlabel(strs.axis_latitude)
ylabel(strs.axis_longitude)
text_corner("(c) "+strs.title_stationLocations,"rb")

set_gcf_size(750,250)