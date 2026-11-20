using Godot;
using System;
using Utils;
using System.Diagnostics.Contracts;
using System.Collections.Generic;
using System.Diagnostics;

namespace Game
{
    [GlobalClass]
    public partial class Test : Node
    {
        [Export]
        public PackedScene coinScene;

        [Export]
        public PackedScene ammoScene;

        public override void _Ready()
        {
            //             CoinDrop coin = coinScene.Instantiate<CoinDrop>();
            //
            //             Debug.Assert(coin != null);
            //
            //             coin.Drop.Data = 123;
            //
            //             GD.Print(coin.Drop.Data);
            //
            //             GD.Print(coin.Drop.Collect());
            //             if (coin == null)
            //             {
            //                 GD.Print("nulllll");
            //             }

            Drop<(int, AmmoType, AmmoWeight)> drop = new((10, AmmoType.Bullet, AmmoWeight.Light));

            AmmoDrop ammo = ammoScene.Instantiate<AmmoDrop>();

            ammo.Drop = drop;

            GD.Print(ammo.Collect());
        }
    }
}
