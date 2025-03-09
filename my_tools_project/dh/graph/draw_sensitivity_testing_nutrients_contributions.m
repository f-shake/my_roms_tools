project_data
tests=bioData.tests;
tl=tiledlayout(1,2);
set_tiledlayout_compact(tl)
set_gcf_size(900,300)

% baseDIN=mean(read_data(bioData.tests(1),"DIN",[1,1,0,1],[0,0,1,0]),4);
% basePO4=mean(read_data(bioData.tests(1),"PO4",[1,1,0,1],[0,0,1,0]),4);
baseChl=mean(read_data(bioData.tests(1),"chlorophyll",[1,1,0,1],[0,0,1,0]),4);
% cnhpDIN=mean(read_data(bioData.tests(3),"DIN",[1,1,0,1],[0,0,1,0]),4);
cnhpChl=mean(read_data(bioData.tests(3),"chlorophyll",[1,1,0,1],[0,0,1,0]),4);
% hncpPO4=mean(read_data(bioData.tests(4),"PO4",[1,1,0,1],[0,0,1,0]),4);
hncpChl=mean(read_data(bioData.tests(4),"chlorophyll",[1,1,0,1],[0,0,1,0]),4);
cncpChl=mean(read_data(bioData.tests(2),"chlorophyll",[1,1,0,1],[0,0,1,0]),4);

minCon=0.05;

nexttile
con=(cnhpChl-baseChl)./(cncpChl-baseChl);
con((cncpChl-baseChl)<minCon)=0;
draw_map(con);
caxis([0,1])
text_corner("(a) DIN Contribution",'rb')

nexttile
con=(hncpChl-baseChl)./(cncpChl-baseChl);
con((cncpChl-baseChl)<minCon)=0;
draw_map(con);
caxis([0,1])
text_corner("(b) PO_4^{3+}-P Contribution",'rb')

% nexttile
% %con=(cnhpChl-baseChl)./(cncpChl-baseChl)+(hncpChl-baseChl)./(cncpChl-baseChl);
% con=((cncpChl-baseChl)-(cnhpChl-baseChl)-(hncpChl-baseChl))./(cncpChl-baseChl);
% con((cncpChl-baseChl)<minCon)=0;
% draw_map(con);
% caxis([0,1])
% text_corner("(c) Synergy Contribution",'rb')

c=colorbar;
c.Layout.Tile='East';
graphData.mainNclColor(true);
cm=colormap;
cm(1:1,:)=ones(1,3); %白色表示贡献低于1%
colormap(gcf,cm);
c.Label.String=strs.axis_contributionPercentage;
c.Ticks=0:0.2:1;
c.TickLabels=["0","20%","40%","60%","80%","100%"];