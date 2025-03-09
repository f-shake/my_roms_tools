function draw_provinces(label)
    arguments
        label(1,1) logical =true
    end
    global draftMode;
    if draftMode
        return
    end
    s=shaperead("data/map/省_简化.shp");
    configs
    project_data
    for j=1:length(s)
        x=s(j).X;y=s(j).Y;l=length(x);
        to=1;from=1;
        while(to<=l)
            if isnan(x(to))
                plotm(y(from:to-1),x(from:to-1),'k');
                to=to+1;
                from=to;
            else
                to=to+1;
            end
        end
    end
    if label
        text_center(120,29.2,bioData.provincesSimple.Zhejiang,8)
        text_center(120,33,bioData.provincesSimple.Jiangsu,8)
        text_center(118,26,bioData.provincesSimple.Fujian,8)
    end
end

function text_center(x,y,string,size)
    project_data
    t=textm(y,x,string,HorizontalAlignment='center',VerticalAlignment='middle',FontName=graphData.font);
    if nargin==4
        set(t,'fontSize',size)
    end
end