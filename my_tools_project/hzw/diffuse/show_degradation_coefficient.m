file='ocean_qck.nc';

lon=ncread(file,'lon_psi');
lat=ncread(file,'lat_psi');

h=ncread(file,'h');
h=0.5*(h(1:end-1,1:end-1)+h(2:end,2:end));

u=ncread(file,'u_sur');
u=0.5*(u(:,1:end-1,:)+u(:,2:end,:));

v=ncread(file,'v_sur');
v=0.5*(v(1:end-1,:,:)+v(2:end,:,:));

temp=ncread(file,'temp_sur');
temp=0.5*(temp(1:end-1,1:end-1,:)+temp(2:end,2:end,:));



k0=0.005;
speed=(u.^2+v.^2).^0.5;
s=speed./h;
s(s>1)=1;
k=k0+0.05*s;
t=1.064.^(temp-22);
t(t>1.5)=1.5;
t(t<0.3)=0.3;
k=k.*t;

figure(1)
km=mean(k,3);
contourf(lon,lat,km,ShowText=1,LevelStep=0.003);
caxis([0,0.02]);

figure(2)
km=km(:);
km=km(~isnan(km));
histogram(km)
km=mean(km);
xline(km,'r--',round(km,3));
xline(prctile(km,90),'m--',round(prctile(km,90),3));
xline(prctile(km,10),'m--',round(prctile(km,10),3));


times=ncread(file,'ocean_time');
times=datetime([1858,11,17,0,0,0])+times/86400;

figure(3)
tiledlayout(1,3);
figure(4)
tiledlayout(3,1);

for m={4:5,7:9,10:11;"春季","夏季","秋季"}
    timeFilter=ismember(month(times),m{1});
    km=mean(k(:,:,timeFilter),3);

    figure(3)
    nexttile
    contourf(lon,lat,km,ShowText=1,LevelStep=0.003);
    caxis([0,0.02]);
    title(m{2});

    figure(4)
    nexttile
    km=km(:);
    km=km(~isnan(km));
    histogram(km)
    xline(mean(km),'r--',round(mean(km),3));
    xline(prctile(km,90),'m--',round(prctile(km,90),3));
    xline(prctile(km,10),'m--',round(prctile(km,10),3));
    title(m{2});
end

savefig(1,'deg_map_mean.fig')
savefig(2,'deg_hist_mean.fig')
savefig(3,'deg_map_season.fig')
savefig(4,'deg_hist_season.fig')