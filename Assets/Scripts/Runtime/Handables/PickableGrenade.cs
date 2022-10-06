using System;
using UnityEngine;

namespace IceEngine
{
    public class PickableGrenade : Pickable
    {
        [Label("基本属性")] public GrenadeInfo info;

        public override bool OnPick()
        {
            Ice.Gameplay.Player.PickGrenade(this);
            Destroy(gameObject);
            return true;
        }
    }
}
