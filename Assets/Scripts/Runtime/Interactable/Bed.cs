using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Bed : Pickable
    {
        public Transform pos;
        public override bool OnPick()
        {
            Ice.Gameplay.Player.Sleep();
            Ice.Gameplay.Player.transform.position = pos.position;
            return true;
        }
    }
}
