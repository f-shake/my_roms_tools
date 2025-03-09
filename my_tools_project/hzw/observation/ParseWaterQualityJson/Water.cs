using System.Diagnostics;
using System.Text.Json.Serialization;

[DebuggerDisplay("{YearMonth} - {Province} - {City}")]
public class DataLine : WaterQuality
{
    [JsonPropertyName("city")]
    public string City { get; set; }

    [JsonPropertyName("lat")]
    public double Latitude { get; set; }

    [JsonPropertyName("lon")]
    public double Longitude { get; set; }

    [JsonPropertyName("province")]
    public string Province { get; set; }

    [JsonPropertyName("sea")]
    public string Sea { get; set; }
    [JsonPropertyName("site")]
    public string Site { get; set; }
    [JsonPropertyName("minitor_month")]
    public string YearMonth { get; set; }
}

[DebuggerDisplay("{Province} - {City}  （{Waters.Count}）")]
public class Record
{
    public WaterQuality MeanWater => new WaterQuality()
    {
        COD = Waters.Select(p => p.COD).Where(p => p >= 0).Average(),
        //DO = Waters.Select(p => p.DO).Where(p => p >= 0).Average(),
        N = Waters.Select(p => p.N).Where(p => p >= 0).Average(),
        P = Waters.Select(p => p.P).Where(p => p >= 0).Average(),
       // PH = Waters.Select(p => p.PH).Where(p => p >= 0).Average(),
    };
    public WaterQuality TrimMeanWater => new WaterQuality()
    {
        COD = GetTrimMean(Waters.Select(p => p.COD)),
        //DO = GetTrimMean(Waters.Select(p => p.DO)),
        N = GetTrimMean(Waters.Select(p => p.N)),
        P = GetTrimMean(Waters.Select(p => p.P)),
        //PH = GetTrimMean(Waters.Select(p => p.PH))
    };
    public string City { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Name { get; set; }
    public string Province { get; set; }
    public string Sea { get; set; }
    public List<WaterQuality> Waters { get; set; }

    public double GetTrimMean(IEnumerable<double> values)
    {
        var valueList = values.Where(p => p > 0).ToList();
        var mean = valueList.Average();
        double maxDiffValue = 0;
        double maxDiff = 0;
        for (int i = 0; i < valueList.Count; i++)
        {
            var value = valueList[i];
            double diff = Math.Abs(value - mean);
            if (diff > maxDiff)
            {
                maxDiff = diff;
                maxDiffValue = value;
            }
        }
        return (mean * valueList.Count - maxDiffValue) / (valueList.Count - 1);

    }
}
public class WaterQuality
{
    [JsonPropertyName("hxxyl")]
    public double COD { get; set; }

    [JsonPropertyName("rjy")]
    public double DO { get; set; }

    public int Month { get; set; }
    [JsonPropertyName("wjd")]
    public double N { get; set; }

    [JsonPropertyName("hxlxy")]
    public double P { get; set; }

    [JsonPropertyName("pH")]
    public double PH { get; set; }

    [JsonPropertyName("szlb")]
    public string Type { get; set; }

    public int Year { get; set; }
}




public class Cluster : Record
{
    public Cluster()
    {
        Waters = new List<WaterQuality>();
    }
    public readonly static double MinDistance = 0.08;
    public bool CanAddToHere(DataLine item)
    {
        var distance = dataLines.Select(p => Math.Sqrt(Math.Pow(item.Longitude - p.Longitude, 2) + Math.Pow(item.Latitude - p.Latitude, 2))).Min();
        return distance < MinDistance;
    }

    public List<DataLine> dataLines = new List<DataLine>();

    public bool AddItem(DataLine item)
    {
        if (Waters.Count > 0 && !CanAddToHere(item))
        {
            return false;
        }
        Waters.Add(item);
        dataLines.Add(item);
        return true;
    }

    public void Seal()
    {
        Longitude = dataLines.Average(p => p.Longitude);
        Latitude = dataLines.Average(p => p.Latitude);
        dataLines = null;
    }
}
