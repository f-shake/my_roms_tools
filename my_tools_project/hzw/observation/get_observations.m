function r=get_observations(xls,var,years,months,column_names)
    arguments
        xls(1,1) string,
        var(1,1) string,
        years(1,:) double {mustBeInteger,mustBeNonnegative}=0,
        months(1,:) double {mustBeInteger,mustBeNonnegative}=0,
        column_names.lon (1,1) string='经度',
        column_names.lat (1,1) string='纬度',
        column_names.enable (1,1) string='启用',
        column_names.id (1,1) string='站点号',
        column_names.year (1,1) string='年',
        column_names.month (1,1) string='月',
    end
    %% 读取表格
    table=readtable(xls,"VariableNamingRule","preserve");
    s=size(table);
    obs=[];
    for i=1:s(1)
        line=table(i,:);
        lon=line.(column_names.lon);
        lat=line.(column_names.lat );
        enable=line.(column_names.enable);
        y=line.(column_names.year);
        m=line.(column_names.month);
        id=line.(column_names.id);
        id=id{1};
        %id= ['I',num2str(round(lon*100)),num2str(round(lat*100))]; %ID精确到0.1度，合并一些很近的点
        if  (enable ...
                && (isequal(years,0) ||  ismember(y,years)) ...
                && (isequal(months,0)||ismember(m,months)))

            value=line.(var);
            if isfield(obs,id)
                obs.(id).values(end+1)=value;
            else
                obs.(id).x=lon;
                obs.(id).y=lat;
                obs.(id).values=value;
            end
        end
    end

    %% 观测值处理
    names=fieldnames(obs);
    obss=zeros(length(names),3);
    for i=1:length(names)
        name=names(i);
        item=obs.(name{1});
        v=mean(item.values);
        obss(i,:)=[item.x,item.y,v];
    end

    r=obss;