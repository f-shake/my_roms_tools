function r=get_observations_of_cluster(xrange,yrange,minCount)
    arguments
        xrange(1,:) double=[]
        yrange(1,:) double=[]
        minCount(1,1) double{mustBeInteger}=0
    end
    path=fileparts(mfilename('fullpath'));
    file=fullfile(path,'ParseWaterQualityJson','bin','Debug','net6.0','cluster.txt');
    [count,lons,lats,cods,ns,ps]=readvars(file);
    f=count>minCount;

    if ~isempty(xrange) && ~isempty(yrange)
        f=f&inpolygon(lons,lats,xrange,yrange);
    end

    r=[lons(f),lats(f),cods(f),ns(f),ps(f)];
