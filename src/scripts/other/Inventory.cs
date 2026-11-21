using Godot;
using System;
using System.Collections.Generic;

namespace Game;

public class Inventory<T>(int capacity) : Storage<T>(capacity) where T : class
{

}
