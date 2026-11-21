using Godot;
using System;
using System.Collections.Generic;
using System.Collections;
using Utils;

namespace Game;

#nullable enable
public class Storage<T>(int capacity) : ICollection<T?> where T : class
{
    protected T?[] _slots = new T?[capacity];

    private int _count = 0;
    public int Count
    {
        get => _count;
        protected set => _count = value;
    }
    public int Capacity => _slots.Length;

    public T? this[int index]
    {
        get => _slots[index];
        set => _slots[index] = value;
    }

    public bool IsReadOnly => false;

    public event Action<int, T?>? SlotUpdated;

    public void Add(T? item)
    {
        if (IsFull())
        {
            GD.PushWarning(Constants.ErrorMessages.STORAGE_FULL(this));
            return;
        }
        if (item == null)
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.NULL_ARGUMENT(nameof(item), typeof(T)));
            return;
        }
        int index = GetAvailableIndex();
        UpdateSlot(index, item);
        Count++;
    }

    public void Insert(int index, T item)
    {
        if (!Functions.IsIndexValid(index, this))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index, this));
            return;
        }
        if (IsSlotInUse(index))
        {
            GD.PushWarning(Constants.ErrorMessages.SLOT_IN_USE(index, this));
            return;
        }
        if (item == null)
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.NULL_ARGUMENT(nameof(item), typeof(T)));
            return;
        }
        UpdateSlot(index, item);
        Count++;
    }

    // INFO might not be working properly
    public bool Remove(T? item)
    {
        int index = _slots.IndexOf(item);
        if (index == -1)
        {
            GD.PushWarning($"Item '{item}' does not exist in {this}");
            return false;
        }
        UpdateSlot(index, null);
        Count--;
        return true;
    }

    public void RemoveAt(int index)
    {
        if (!Functions.IsIndexValid(index, this))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index));
            return;
        }
        UpdateSlot(index, null);
        Count--;
    }

    public void Move(int index1, int index2)
    {
        if (!Functions.IsIndexValid(index1, this))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index1));
            return;
        }
        if (IsSlotEmpty(index1))
        {
            GD.PushWarning(Constants.ErrorMessages.SLOT_EMPTY(index1, this));
            return;
        }
        if (!Functions.IsIndexValid(index2, this))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index2));
            return;
        }
        if (IsSlotInUse(index2))
        {
            GD.PushWarning(Constants.ErrorMessages.SLOT_IN_USE(index2, this));
            return;
        }
        UpdateSlot(index2, _slots[index1]);
        UpdateSlot(index1, null);
    }

    public void Move(int index, Storage<T> storage)
    {
        if (!Functions.IsIndexValid(index, storage))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index));
            return;
        }
        if (IsSlotEmpty(index))
        {
            GD.PushWarning(Constants.ErrorMessages.SLOT_EMPTY(index, this));
            return;
        }
        if (storage == null)
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.NULL_ARGUMENT(nameof(storage), typeof(Storage<T>)));
            return;
        }
        if (storage.IsFull())
        {
            GD.PushWarning(Constants.ErrorMessages.STORAGE_FULL(storage));
            return;
        }
        storage.Add(_slots[index]);
        UpdateSlot(index, null);
    }

    public void Move(int index1, Storage<T> storage, int index2)
    {
        if (!Functions.IsIndexValid(index1, this))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index1));
            return;
        }
        if (IsSlotEmpty(index1))
        {
            GD.PushWarning(Constants.ErrorMessages.SLOT_EMPTY(index1, this));
            return;
        }
        if (storage == null)
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.NULL_ARGUMENT(nameof(storage), typeof(Storage<T>)));
            return;
        }
        if (storage.IsFull())
        {
            GD.PushWarning(Constants.ErrorMessages.STORAGE_FULL(storage));
            return;
        }
        if (!Functions.IsIndexValid(index2, storage))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index2));
            return;
        }
        if (storage.IsSlotInUse(index2))
        {
            GD.PushWarning(Constants.ErrorMessages.SLOT_IN_USE(index2, storage));
            return;
        }
        T temp = _slots[index1]!;
        UpdateSlot(index1, storage[index2]);
        storage.UpdateSlot(index2, temp);
    }

    public void Swap(int index1, int index2)
    {
        if (!Functions.IsIndexValid(index1, this))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index1));
            return;
        }
        if (!Functions.IsIndexValid(index2, this))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index2));
            return;
        }
        T temp = _slots[index1]!;
        UpdateSlot(index1, _slots[index2]);
        UpdateSlot(index2, temp);
    }

    public void Swap(int index1, Storage<T> storage, int index2)
    {
        if (!Functions.IsIndexValid(index1, this))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index1));
            return;
        }
        if (!Functions.IsIndexValid(index2, storage))
        {
            GD.PushWarning(Utils.Constants.ErrorMessages.INDEX_OUT_OF_BOUNDS(index2));
            return;
        }
        T temp = _slots[index1]!;
        UpdateSlot(index1, storage[index2]);
        storage.UpdateSlot(index2, temp);
    }

    public bool IsEmpty()
    {
        return Count == 0;
    }

    public bool IsFull()
    {
        return Count == _slots.Length;
    }

    public bool IsSlotEmpty(int index)
    {
        return _slots[index] == null;
    }

    public bool IsSlotInUse(int index)
    {
        return _slots[index] != null;
    }

    public void Clear()
    {
        for (int i = 0; i < _slots.Length; i++)
        {
            UpdateSlot(i, null);
        }
    }

    protected void UpdateSlot(int index, T? item)
    {
        _slots[index] = item;
        SlotUpdated?.Invoke(index, item);
    }

    protected int GetAvailableIndex()
    {
        for (int i = 0; i < _slots.Length; i++)
        {
            if (_slots[i] != null) return i;
        }
        return -1;
    }

    // for ICollection<T>
    public bool Contains(T? item)
    {
        return _slots.Contains(item);
    }
    public void CopyTo(T?[] array, int index)
    {
        int arrayIndex = 0;
        foreach (T? item in _slots)
        {
            if (item != null)
            {
                array[arrayIndex] = item;
                arrayIndex++;
            }
        }
    }
    public IEnumerator<T?> GetEnumerator() => new StorageEnumerator<T>(this);
    IEnumerator IEnumerable.GetEnumerator() => GetEnumerator();
}


public class StorageEnumerator<T>(Storage<T> storage) : IEnumerator<T?> where T : class
{
    private readonly Storage<T> _storage = storage;
    private int _index = -1;
    private T? _current;

    public T? Current => _current;

    object? IEnumerator.Current => Current;

    public bool MoveNext()
    {
        if (++_index >= _storage.Count)
        {
            return false;
        }
        else
        {
            _current = _storage[_index];
            return true;
        }
    }

    public void Dispose()
    {
        throw new NotImplementedException();
    }

    public void Reset() => _index = -1;
}
