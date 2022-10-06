using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class PickableGrenade : Pickable
    {
        public GameObject prefab;

        public override bool OnPick()
        {
            Ice.Gameplay.Player.PickGrenade(this);
            Destroy(gameObject);
            return true;
        }
    }
}
