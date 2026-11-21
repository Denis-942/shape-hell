using System.Collections.Generic;

namespace Utils.Constants
{
    public static class ErrorMessages
    {
        public static string INDEX_OUT_OF_BOUNDS(int index) => $"Index '{index}' is out of bounds";
        public static string INDEX_OUT_OF_BOUNDS<T>(int index, ICollection<T> collection) =>
            $"Index {index} in collection of type {collection.GetType()} is out of bounds";
        public static string NULL_ARGUMENT(string argName, System.Type argType) =>
            $"Argument '{argName}' of type {argType} is null";
    }
}

namespace Game.Constants
{
    public static class ErrorMessages
    {
        public static string STORAGE_FULL<T>(Storage<T> storage) where T : class =>
            $"Storage '{storage}' is full";

        public static string SLOT_IN_USE<T>(int index, Storage<T> storage) where T : class =>
            $"Slot at index '{index}' in storage '{storage}' is already in use";

        public static string SLOT_EMPTY<T>(int index, Storage<T> storage) where T : class =>
            $"Slot at index '{index}' in storage '{storage}' is empty";
    }
}
