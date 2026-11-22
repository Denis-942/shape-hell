using Godot;
using System;
using Utils;

namespace Game.Types;

[Tool, GlobalClass]
public sealed partial class GunData : Resource
{
    [Export]
    public string WeaponName { get; set; }

    [Export]
    public Enums.FireType FireType
    {
        get => _fireType;
        private set
        {
            _fireType = value;
            AssignValues();
            NotifyPropertyListChanged();
        }
    }
    private Enums.FireType _fireType;

    [Export]
    public Enums.Rarity Rarity { get; set; }

    [Export]
    public int Rpm
    {
        get => _rpm;
        private set
        {
            if (value == _rpm) return;
            _rpm = value;
            AssignValues();
        }
    }
    private int _rpm = 60;

    [Export]
    public float Rps
    {
        get => _rps;
        private set
        {
            if (Mathf.IsEqualApprox(value, _rps)) return;
            _rps = value;
            AssignValues();
        }
    }
    private float _rps = 1.0f;

    [Export]
    public float FireDelay
    {
        get => _fireDelay;
        private set
        {
            if (Mathf.IsEqualApprox(value, _fireDelay)) return;
            _fireDelay = value;
            AssignValues();
        }
    }
    private float _fireDelay = 1.0f;

    [Export]
    public int BurstCount
    {
        get => _burstCount;
        private set
        {
            _burstCount = value;
            AssignValues();
        }
    }
    private int _burstCount = 3;

    [Export]
    public float BurstInterval
    {
        get => _burstInterval;
        private set
        {
            _burstInterval = value;
            AssignValues();
        }
    }
    private float _burstInterval = 0.1f;

    [Export]
    public int ShotCount
    {
        get => _shotCount;
        private set
        {
            _shotCount = value;
        }
    }
    private int _shotCount = 5;

    [Export]
    private float _baseDamage;
    public Utils.Types.ScalableValue<float, int> Damage;

    [Export]
    public Enums.AmmoType AmmoType { get; private set; }

    [Export]
    public Enums.AmmoWeight AmmoWeight { get; private set; }

    [Export]
    public int MaxAmmo { get; private set; }
    [Export]
    public float ReloadTime { get; private set; }
    [Export]
    public int Pierce { get; private set; }
    [Export]
    public float BulletRange { get; private set; }
    [Export]
    public float SpreadAngle { get; private set; }

    [Export]
    public PackedScene GunScene { get; private set; }
    [Export]
    public PackedScene DropScene { get; private set; }

    public int Ammo { get; set; }

    public Utils.Types.Level Level { get; set; }


    public GunData()
    {
        // INFO temporary scaling
        Damage = new(_baseDamage, 1, (b, s) => b * s);
        Level.Changed += (newLevel) => Damage.Scalar = newLevel;
    }

    // TODO: public Gun CreateInstance() {}

    public override void _ValidateProperty(Godot.Collections.Dictionary property)
    {
        StringName name = property["name"].AsStringName();
        var usage = property["usage"].As<PropertyUsageFlags>();

        if (name == PropertyName.Rpm || name == PropertyName.Rps)
        {
            if (FireType == Enums.FireType.Burst)
            {
                // enable readonly
                usage |= PropertyUsageFlags.ReadOnly;
            }
            else
            {
                // disable readonly
                usage &= ~PropertyUsageFlags.ReadOnly;
            }
        }
        if (name == PropertyName.BurstCount || name == PropertyName.BurstInterval)
        {
            if (FireType != Enums.FireType.Burst)
            {
                // disable visibility
                usage &= ~PropertyUsageFlags.Editor;
            }
            else
            {
                // enable visibility
                usage |= PropertyUsageFlags.Editor;
            }
        }
        if (name == PropertyName.ShotCount)
        {
            if (FireType == Enums.FireType.Shotgun)
            {
                // enable visibility
                usage |= PropertyUsageFlags.Editor;
            }
            else
            {
                // disable visibility
                usage &= ~PropertyUsageFlags.Editor;
            }
        }
        property["usage"] = (int)usage;
        base._ValidateProperty(property);
    }


    private float GetBurstTime()
    {
        return (BurstCount - 1) * BurstInterval;
    }

    private void AssignValues()
    {
        switch (FireType)
        {
            case Enums.FireType.Single:
                Rps = _rpm / 60.0f;
                FireDelay = 1.0f / _rps;
                break;
            case Enums.FireType.Burst:
                Rpm = Mathf.RoundToInt(BurstCount / (GetBurstTime() + _fireDelay) * 60);
                Rps = BurstCount / (GetBurstTime() + _fireDelay);
                break;
            case Enums.FireType.Shotgun:
                Rps = _rpm / 60.0f;
                FireDelay = 1.0f / _rps;
                break;

        }
    }
}
