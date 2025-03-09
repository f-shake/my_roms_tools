configs
[lon,lat,mask]=roms_load_grid_rho;
grid=mask;
base=1/30;
grid(:)=base;
[n1,n2]=size(grid);
for i=1:30
    value=1/5-(1/5-1/30)/30*i;
    grid(i,:)=max(grid(i,:),value);
    grid(n1-i+1,:)=max(grid(n1-i+1,:),value);
    grid(:,i)=max(grid(:,i),value);
    grid(:,n2-i+1)=max(grid(:,n2-i+1),value);
end
figure(1)
contourf(lon,lat,grid,ShowText=1);
grid3d=repmat(grid,1,1,roms.grid.N);

figure(2)

grid2=grid;
grid2(grid2==base)=0;
contourf(lon,lat,grid2,ShowText=1);
grid3d2=repmat(grid2,1,1,roms.grid.N);
clear tracer
% tracer.NO3=grid3d;
% tracer.PO4=grid3d;
% tracer.SiOH=grid3d;
% tracer.oxygen=grid3d;
% tracer.alkalinity=grid3d;
% tracer.chlorophyll=grid3d;
create_nudgcoef(4,4,grid3d,grid3d,grid3d2);

