using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Bed : Pickable
    {
        public override bool OnPick()
        {
            Ice.Gameplay.CurLevel.Sleep();
            return true;
        }
    }
}
