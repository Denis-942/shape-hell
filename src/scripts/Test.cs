using Godot;
using System;
using Utils;


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

            Level l = 100;
            GD.Print(l);
        }
    }
}
