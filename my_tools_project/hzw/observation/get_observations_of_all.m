function [obs,sites,years,months]=get_observations_of_all(xrange,yrange,year,month)
    arguments
        xrange(1,:) double=[]
        yrange(1,:) double=[]
        year(1,:) double{mustBeInteger}=[],
        month(1,:) double {mustBeInteger,mustBeInRange(month,1,12)}=[]
    end
    project_data
    obsFile=projectData.observationInfo;
    [sites,years,months,lons,lats,cods,ns,ps]=readvars(obsFile);
    f=ones(size(lons));
    if ~isempty(xrange) && ~isempty(yrange)
        f=f&inpolygon(lons,lats,xrange,yrange);
    end
    if ~isempty(year)
        f=f&ismember(years,year);
    end
    if ~isempty(month)
        f=f&ismember(months,month);
    end
    sites=sites(f);
    years=years(f);
    months=months(f);

    obs=[lons(f),lats(f),cods(f),ns(f),ps(f)];
