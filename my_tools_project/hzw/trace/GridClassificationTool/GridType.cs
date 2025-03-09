using FzLib;
using System.ComponentModel;
using System.Windows.Media;

namespace GridClassificationTool
{
    public class GridType : INotifyPropertyChanged
    {
        private Brush color;
        private int count;
        private int index;
        private bool selected;
        public event PropertyChangedEventHandler PropertyChanged;

        public Brush Color
        {
            get => color;
            set => this.SetValueAndNotify(ref color, value, nameof(Color));
        }

        public int Count
        {
            get => count;
            set => this.SetValueAndNotify(ref count, value, nameof(Count));
        }

        public int Index
        {
            get => index;
            set => this.SetValueAndNotify(ref index, value, nameof(Index));
        }

        public bool Selected
        {
            get => selected;
            set => this.SetValueAndNotify(ref selected, value, nameof(Selected));
        }

        public void Update(byte[,] bytes)
        {
            Count = bytes == null ? 0 : bytes.Cast<byte>().Count(p => p == Index);
        }
    }
}