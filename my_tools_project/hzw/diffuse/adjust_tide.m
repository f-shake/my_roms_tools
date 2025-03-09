clear
netcdf_load("roms_tides_raw.nc")
disp(squeeze(mean(tide_Eamp,[1,2]))')
tide_Eamp=tide_Eamp*1.15;
%tide_Eamp(:,:,9)=tide_Eamp(:,:,9)*1.15;

ncwrite("roms_tides.nc","tide_Eamp",tide_Eamp);