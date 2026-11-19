using System;
using System.Collections.Generic;
using Godot;

namespace Utils
{
    public class Dice<T>(Dictionary<T, float> initialItems)
    {
        private Dictionary<T, float> _entries = initialItems;

        public T Roll()
        {
            if (Validate() == false)
            {
                return default;
            }
            float rolledWeight = GD.Randf();

            float weightSum = 0.0f;
            foreach ((T item, float weight) in _entries)
            {
                weightSum += weight;
                if (rolledWeight <= weightSum) return item;
            }
            return default;
        }

        public void SetWeight(T item, float weight)
        {
            if (_entries.ContainsKey(item) == false)
            {
                GD.PushWarning($"'{_entries}' in {this} does not contain key '{item}'");
                return;
            }
            _entries[item] = weight;
        }

        public void AddEntry(T item, float weight)
        {
            if (_entries.ContainsKey(item))
            {
                GD.PushWarning($"'{_entries}' in {this} already contains key '{item}'");
                return;
            }
            _entries.Add(item, weight);
        }

        public void AddEntries(params (T, float)[] items)
        {
            foreach ((T item, float weight) in items)
            {
                AddEntry(item, weight);
            }
        }

        public void RemoveEntry(T item)
        {
            if (_entries.ContainsKey(item) == false)
            {
                GD.PushWarning($"'{_entries}' in {this} does not contain key '{item}'");
                return;
            }
            _entries.Remove(item);
        }

        public void RemoveEntries(params T[] items)
        {
            foreach (T item in items)
            {
                RemoveEntry(item);
            }
        }

        public void AssignEntries(Dictionary<T, float> entries)
        {
            _entries = entries;
        }

        public bool Validate()
        {
            float totalWeight = 0.0f;
            foreach (float weight in _entries.Values)
            {
                totalWeight += weight;
            }
            if (Mathf.IsEqualApprox(totalWeight, 1.0f) == false)
            {
                GD.PushWarning($"Total weight of '{_entries}' in '{this}' does not add up to 1.0 (100%), total weight is instead {totalWeight}");
                return false;
            }
            return true;
        }
    }
}
