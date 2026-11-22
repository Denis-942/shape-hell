using Godot;
using Game.Types;
using System;
using System.Threading.Tasks;

public partial class Gun : Node3D
{
    public event Action<int> AmmoAmountChanged;

    public GunData Data { get; private set; }

    private double _timer = 0.0f;
    private bool _shooting = false;
    private bool _reloading = false;


    public override void _Process(double delta)
    {
        if (_timer > 0.0) _timer -= delta;

        if (_timer <= 0.0)
        {
            if (CanShoot())
            {
                Shoot();
            }
        }
    }

    private async void Shoot()
    {
        _shooting = true;
        switch (Data.FireType)
        {
            case Game.Enums.FireType.Single:
                Fire();
                Data.Ammo -= 1;
                AmmoAmountChanged?.Invoke(Data.Ammo);
                break;
            case Game.Enums.FireType.Burst:
                Fire();
                for (int i = 0; i < Mathf.Min(Data.BurstCount, Data.Ammo); i++)
                {
                    await Task.Delay((int)(Data.BurstInterval * 1000.0));
                    Fire();
                }
                break;
            case Game.Enums.FireType.Shotgun:
                for (int i = 0; i < Data.ShotCount; i++)
                {
                    Fire();
                }
                Data.Ammo -= 1;
                AmmoAmountChanged?.Invoke(Data.Ammo);
                break;
        }
        _shooting = false;
    }

    private void Fire()
    {
        // TODO: implement
    }

    public void StartShooting()
    {
        _shooting = true;
    }
    public void StopShooting()
    {
        _shooting = false;
    }

    public async void Reload()
    {
        if (Data.Ammo == 0 || _reloading) return;

        // TODO: return condition for player not having ammo

        _reloading = true;
        await Task.Delay((int)(Data.ReloadTime * 1000.0));
        int ammoNeeded = Data.MaxAmmo - Data.Ammo;

        // TODO: calculate ammo added amount based on the amount of ammo the player has

        // INFO temporary, will be replaced with '+= ammoAdded' or something similar
        Data.Ammo += ammoNeeded;

        // TODO: remove ammo from player

        _reloading = false;
        AmmoAmountChanged?.Invoke(Data.Ammo);
    }

    private bool CanShoot()
    {
        return _timer <= 0.0f && Data.Ammo > 0 && _reloading == false && _shooting == false;
    }
}
