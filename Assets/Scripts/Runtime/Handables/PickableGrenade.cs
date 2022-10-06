using System;
using UnityEngine;

namespace IceEngine
{
    public class PickableGrenade : Pickable
    {


        public override bool OnPick()
        {
            Ice.Gameplay.Player.PickGrenade(this);
            Destroy(gameObject);
            return true;
        }
    }
}
