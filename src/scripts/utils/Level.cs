using System;

namespace Utils
{
    public class Level(int initialValue)
    {
        private int _value = initialValue;
        public int Value
        {
            get => _value;
            set
            {
                _value = value;
                Changed?.Invoke(_value);
            }
        }

        public event Action<int> Changed;


        public static implicit operator int(Level level) => level.Value;

        public static Level operator +(Level level, int value) => new(level.Value + value);
        public static Level operator -(Level level, int value) => new(level.Value - value);

        public void operator +=(int value) => Value += value;
        public void operator -=(int value) => Value -= value;
        public void operator ++() => Value++;
        public void operator --() => Value--;

        public override string ToString() => Value.ToString();

        // doesnt fucking work because of how the langauge works, fuck Microslop
        // public void operator =(int value) => Value = value;
    }
}
