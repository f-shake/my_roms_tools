using Newtonsoft.Json.Linq;
using System;
using System.Net;
using System.Text;
using System.IO;

Console.Write("潮站ID：");
int id = int.Parse(Console.ReadLine());
Console.Write("开始日期（如2022-1-1）：");
DateTime start = DateTime.Parse(Console.ReadLine());
Console.Write("结束日期（如2022-1-1）：");
DateTime end = DateTime.Parse(Console.ReadLine());
using var file=File.CreateText("output.txt");
for (DateTime date = start; date <=end; date = date.AddDays(1))
{
    Console.WriteLine($"正在处理{date}");
    string url = $"https://www.cnss.com.cn/u/cms/www/tideJson/{id}_{date.Year}-{date.Month:00}-{date.Day:00}.json";
    string json = HttpDownload(url);

    foreach (JArray data in JArray.Parse(json)[0]["data"])
    {
        DateTime time = DateTimeOffset.FromUnixTimeMilliseconds(data[0].Value<long>()).DateTime + TimeSpan.FromHours(8);
        var height = data[1].Value<double>() / 100;

        file.WriteLine($"{time.Year}\t{time.Month}\t{time.Day}\t{time.Hour}\t{time.Minute}\t{height}");

    }
}

Console.WriteLine("已输出到output.txt");

string HttpDownload(string url)
{
    try
    {
        MemoryStream fs = new MemoryStream();
        // 设置参数
        HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
        //发送请求并获取相应回应数据
        HttpWebResponse response = request.GetResponse() as HttpWebResponse;
        //直到request.GetResponse()程序才开始向目标网页发送Post请求
        Stream responseStream = response.GetResponseStream();
        //创建本地文件写入流
        byte[] bArr = new byte[1024];
        int iTotalSize = 0;
        int size = responseStream.Read(bArr, 0, (int)bArr.Length);
        while (size > 0)
        {
            iTotalSize += size;
            fs.Write(bArr, 0, size);
            size = responseStream.Read(bArr, 0, (int)bArr.Length);
        }
        fs.Close();
        responseStream.Close();
        var arr = fs.ToArray();
        return new UTF8Encoding(false).GetString(arr);
    }
    catch (Exception ex)
    {
        return null;
    }
}
