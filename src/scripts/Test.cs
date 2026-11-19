using Godot;
using System;
using Utils;
using System.Diagnostics.Contracts;
using System.Collections.Generic;

namespace Game
{
    [GlobalClass]
    public partial class Test : Node
    {
        public override void _Ready()
        {
            // var sv = new ScalableValue<int, int>(3, 2, (a, b) =>
            // {
            //     return a * b;
            // });

            // var sv = ScalableValue.Create(3, 2, (a, b) => a * b);
            // sv.Base = 4;
            // sv.Scalar = 3;
            // GD.Print(sv.Base);
            // GD.Print(sv.Scaled);
            // Level l = new(100);
            // GD.Print(l);

            Dictionary<int, float> entries = new() {
                {1, 0.4f},
                {2, 0.3f},
                {3, 0.2f},
                {4, 0.1f}
            };
            Dice<int> dice = new(new() {
                {1, 0.4f},
                {2, 0.3f},
                {3, 0.2f},
                // {4, 0.1f}
            });
            GD.Print(dice.Roll());
            GD.Print(dice.Roll());
            GD.Print(dice.Roll());
            GD.Print(dice.Roll());
            GD.Print(dice.Roll());
        }
    }
}
