using Godot;
using System;

namespace Utils.Types;

public class Drop<T>(T initialData)
{
    private T _data = initialData;
    public T Data
    {
        get => _data;
        set => _data = value;
    }
    public event Action Collected;

    public T Collect()
    {
        Collected?.Invoke();
        return _data;
    }

    public static implicit operator T(Drop<T> drop) => drop.Data;
}
