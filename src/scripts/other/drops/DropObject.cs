using System;
using System.Diagnostics;
using Game.Types;
using Godot;
using Utils.Types;

namespace Game;

public abstract partial class DropObject<T> : RigidBody3D
{
    private Drop<T> _drop;
    public Drop<T> Drop
    {
        get => _drop;
        set => _drop = value;
    }

    [Export]
    private MeshInstance3D _mesh;

    private float _despawnTimer = 60.0f;

    public override void _Ready()
    {
        Debug.Assert(_mesh != null, $"The '{nameof(_mesh)}' is null in '{Name}'");
    }

    public override void _Process(double delta)
    {
        _mesh.RotateY((float)delta * Mathf.Pi);
        _despawnTimer -= (float)delta;
        if (_despawnTimer <= 0.0f)
        {
            QueueFree();
        }
    }

    public T Collect()
    {
        QueueFree();
        return _drop.Collect();
    }
}
