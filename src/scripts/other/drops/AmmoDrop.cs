using Godot;

namespace Game;

#region Temp
public enum AmmoType
{
    Bullet,
    Shell,
}
public enum AmmoWeight
{
    Light,
    Medium,
    Heavy,
}
#endregion

[GlobalClass]
public partial class AmmoDrop : DropObject<(int, AmmoType, AmmoWeight)>
{

}
