using Godot;

namespace Game.Types;

[GlobalClass]
public partial class AmmoDrop : DropObject<(int, Enums.AmmoType, Enums.AmmoWeight)>
{

}
