using System.Text.Json;

string folder = @"C:\Users\autod\OneDrive\大学\污染物模拟\全国海水水质系统数据";

int[] yearFilter = new int[] { } ;
int[] monthFilter = new int[] {  };

var files = Directory.EnumerateFiles(folder, "*.json");

List<DataLine> waters = new List<DataLine>();

foreach (var file in files)
{
    Console.WriteLine("正在读取" + file);
    var json = File.ReadAllText(file);
    json = json.Replace("未检出", "0").Replace("\"\"", "\"-1\"");
    var temp = JsonSerializer.Deserialize<List<DataLine>>(json, new JsonSerializerOptions()
    {
        NumberHandling = System.Text.Json.Serialization.JsonNumberHandling.AllowReadingFromString
    });
    foreach (var item in temp)
    {
        var yearMonth = item.YearMonth.Split('-');
        item.Year = int.Parse(yearMonth[0]);
        item.Month = int.Parse(yearMonth[1]);
    }
    waters.AddRange(temp);
}

if (yearFilter.Length > 0)
{
    waters = waters.Where(p => yearFilter.Contains(p.Year)).ToList();
}
if (monthFilter.Length > 0)
{
    waters = waters.Where(p => monthFilter.Contains(p.Month)).ToList();
}

Console.WriteLine($"共{waters.Count}条");
Console.WriteLine("正在导出记录");
using var watersFile = File.CreateText("waters.txt");
watersFile.WriteLine($"Site,Year,Month,Longitude,Latitude,COD,N,P");
foreach (var item in waters)
{
    watersFile.WriteLine($"{item.Site},{item.Year},{item.Month},{item.Longitude},{item.Latitude},{item.COD:0.00},{item.N:0.00},{item.P:0.000}");
}



//按站点分组
Console.WriteLine("正在按站点分组");
var siteRecords = new List<Record>();
using var sitesFile = File.CreateText("sites.txt");
sitesFile.WriteLine($"ID,Province,Longitude,Latitude,COD,N,P");
var groups = waters.GroupBy(p => p.Site);
foreach (var group in groups)
{
    try
    {
        var site = new Record()
        {
            Name = group.Key,
            Latitude = group.Average(p => p.Latitude),
            Longitude = group.Average(p => p.Longitude),
            Waters = group.Cast<WaterQuality>().ToList(),
            City = group.Select(p => p.City).Distinct().SingleOrDefault(),
            Province = group.Select(p => p.Province).Distinct().SingleOrDefault(),
            Sea = group.Select(p => p.Sea).Distinct().SingleOrDefault(),
        };
        siteRecords.Add(site);

        sitesFile.WriteLine($"{site.Name},{site.Province},{site.Longitude},{site.Latitude},{site.MeanWater.COD:0.00},{site.MeanWater.N:0.00},{site.MeanWater.P:0.000}");
    }
    catch (Exception ex)
    {

    }
}
Console.WriteLine($"共分类：{groups.Count()}");


//聚类
Console.WriteLine("正在聚类分组");
List<Cluster> clusters = new List<Cluster>();

foreach (var item in waters)
{
    bool added = false;
    foreach (var cluster in clusters)
    {
        if (cluster.AddItem(item))
        {
            added = true;
            break;
        }
    }
    if (!added)
    {
        Cluster cluster = new Cluster();
        cluster.AddItem(item);
        clusters.Add(cluster);
    }
}
foreach (var cluster in clusters.ToList())
{
    cluster.Seal();
}
using var clusterFile = File.CreateText("cluster.txt");
clusterFile.WriteLine($"Count,Longitude,Latitude,COD,N,P");
Console.WriteLine($"共分类：{clusters.Count}");
foreach (var cluster in clusters)
{
    try
    {
        clusterFile.WriteLine($"{cluster.Waters.Count},{cluster.Longitude},{cluster.Latitude},{cluster.MeanWater.COD:0.00},{cluster.MeanWater.N:0.00},{cluster.MeanWater.P:0.000}");
    }
    catch
    {

    }
}