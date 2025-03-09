function [r,sites]=get_observations_of_sites_groups(xrange,yrange)
    arguments
        xrange(1,:) double=[]
        yrange(1,:) double=[]
    end
    path=fileparts(mfilename('fullpath'));
    file=fullfile(path,'ParseWaterQualityJson','bin','Debug','net6.0','sites.txt');
    [sites,province,lons,lats,cods,ns,ps]=readvars(file);
    f=ones(size(lons));
    if ~isempty(xrange) && ~isempty(yrange)
        f=inpolygon(lons,lats,xrange,yrange);
    end
    sites=sites(f);
    r=[lons(f),lats(f),cods(f),ns(f),ps(f)];
