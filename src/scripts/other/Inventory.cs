using Godot;
using System;
using System.Collections.Generic;

namespace Game;

#nullable enable
public class Inventory<T>(int capacity) where T : class
{
    private List<T?> _slots = new(capacity);

    public event Action<int, T?>? SlotUpdated;

    // public event Action

    public void Add(T item)
    {
        if (IsFull())
        {
            GD.PushWarning($"Inventory {this} is full");
            return;
        }
        int index = GetAvailableIndex();
        _slots[index] = item;
        SlotUpdated?.Invoke(index, item);
    }

    public void Remove(T item)
    {
        int index = _slots.IndexOf(item);
        if (index == -1)
        {
            GD.PushWarning($"Item '{item}' does not exist in {this}");
            return;
        }
        _slots[index] = null;
        SlotUpdated?.Invoke(index, null);
    }

    public void RemoveAt(int index)
    {
        if (ValidateIndex(index) == false)
        {
            return;
        }
        _slots[index] = null;
        SlotUpdated?.Invoke(index, null);
    }

    public bool IsEmpty()
    {
        return GetAvailableIndex() != -1;
    }

    public bool IsFull()
    {
        return GetAvailableIndex() == -1;
    }

    public bool IsValidIndex(int index)
    {
        return index >= 0 && index < _slots.Count;
    }

    private bool ValidateIndex(int index)
    {
        if (IsValidIndex(index) == false)
        {
            GD.PushWarning($"Index '{index}' is out of bounds in {this} (capacity: {_slots.Capacity})");
            return false;
        }
        return true;
    }

    private int GetAvailableIndex()
    {
        return _slots.FindIndex(item => item != null);
    }
}
