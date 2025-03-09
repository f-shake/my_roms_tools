using FzLib;
using Microsoft.WindowsAPICodePack.FzExtension;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace GridClassificationTool
{

    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window, INotifyPropertyChanged
    {
        byte[,] bytes;

        Brush[] colors = new Brush[]
            {
                Brushes.Red,
                Brushes.Green,
                Brushes.Blue,
                Brushes.Magenta,
                Brushes.Cyan,
                Brushes.PowderBlue,
                Brushes.Yellow,
                Brushes.Orange,
                Brushes.Orchid,
                Brushes.Purple,

            };
        Brush LightGray = new SolidColorBrush(Color.FromRgb(0xEF, 0xEF, 0xEF));

        private ObservableCollection<GridType> gridTypes = new ObservableCollection<GridType>();

        int height;

        byte[,] rawBytes;

        int scale = 100;
        private int typeCount = 8;

        int width;
        public MainWindow()
        {
            DataContext = this;
            InitializeComponent();
            btnTypeCountOK_Click(null, null);
        }
        public event PropertyChangedEventHandler PropertyChanged;
        public ObservableCollection<GridType> GridTypes
        {
            get => gridTypes;
            set => this.SetValueAndNotify(ref gridTypes, value, nameof(GridTypes));
        }

        public int TypeCount
        {
            get => typeCount;
            set => this.SetValueAndNotify(ref typeCount, value, nameof(TypeCount));
        }
        private void btnExport_Click(object sender, RoutedEventArgs e)
        {
            string path = new FileFilterCollection().Add("导出到MATLAB的网格文件", "grd").CreateSaveFileDialog().GetFilePath();
            if (path == null)
            {
                return;
            }

            using var file = File.CreateText(path);
            for (int j = 0; j < height; j++)
            {
                file.WriteLine(string.Join(',', Enumerable.Range(0, width).Select(i => bytes[i, j].ToString())));
            }
            file.Dispose();
        }

        private void btnImport_Click(object sender, RoutedEventArgs e)
        {
            string file = new FileFilterCollection().Add("由MATLAB导出的掩膜文件", "grd").CreateOpenFileDialog().GetFilePath();
            if (file == null)
            {
                return;
            }
            var lines = File.ReadAllLines(file);
            height = lines.Length;
            width = lines[0].Split(',').Length;
            bytes = new byte[width, height];
            rawBytes = new byte[width, height];
            for (int j = 0; j < height; j++)
            {
                var line = lines[j].Split(',');
                for (int i = 0; i < width; i++)
                {
                    bytes[i, j] = byte.Parse(line[i]);
                }
            }
            Array.Copy(bytes, rawBytes, bytes.Length);
            Draw();
        }

        private void btnTypeCountOK_Click(object sender, RoutedEventArgs e)
        {

            GridTypes.Clear();
            for (int i = 1; i <= TypeCount; i++)
            {
                GridTypes.Add(new GridType()
                {
                    Color = colors[i],
                    Selected = i == 1,
                    Index = i,
                });
                GridTypes[^1].Update(bytes);
            }

        }

        private void Draw()
        {

            cvs.Children.Clear();
            cvs.Width = width * scale;
            cvs.Height = height * scale;

            for (int i = 0; i < width; i++)
            {

                for (int j = 0; j < height; j++)
                {
                    var rectangle = new Rectangle()
                    {
                        Width = scale ,
                        Height = scale ,
                        Fill = Brushes.White,
                        Tag = new int[] { i, j, 0 }
                    };

                    if (bytes[i, j] == 0)
                    {
                        rectangle.Fill = (i + j) % 2 == 0 ? Brushes.White : LightGray;
                    }
                    else if (bytes[i, j] == byte.MaxValue)
                    {
                        rectangle.Fill = Brushes.Black;
                        rectangle.IsHitTestVisible = false;
                    }
                    else
                    {
                        rectangle.Fill = colors[bytes[i, j]];
                    }
                    rectangle.MouseLeftButtonDown += Rectangle_MouseLeftButtonDown;

                    cvs.Children.Add(rectangle);
                    Canvas.SetLeft(rectangle, i * scale );
                    Canvas.SetTop(rectangle, j * scale);

                }
            }


            foreach (var type in GridTypes)
            {
                type.Update(bytes);
            }
        }

        private async void Rectangle_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            var position = e.GetPosition(this);
            await Task.Delay(100);
            var newPosition = e.GetPosition(this);
            var distance = Math.Sqrt(Math.Pow(position.X - newPosition.X, 2) + Math.Pow(position.Y - newPosition.Y, 2));
            if (distance > 4)
            {
                return;
            }

            var rect = sender as Rectangle;
            int[] tag = rect.Tag as int[];
            var type = GridTypes.FirstOrDefault(p => p.Selected);
            Brush color = type.Color;

            if (bytes[tag[0], tag[1]] > 0)
            {
                int oldIndex = bytes[tag[0], tag[1]];
                bytes[tag[0], tag[1]] = 0;
                if (gridTypes.Any(p => p.Index == oldIndex))
                {
                    gridTypes.First(p => p.Index == oldIndex).Update(bytes);
                }
                rect.Fill = (tag[0] + tag[1]) % 2 == 0 ? Brushes.White : LightGray; 
            }
            else
            {
                bytes[tag[0], tag[1]] = Convert.ToByte(type.Index);
                rect.Fill = type.Color;
            }
            type.Update(bytes);


        }
    }
}