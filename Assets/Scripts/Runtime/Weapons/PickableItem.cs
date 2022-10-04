using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class PickableItem : Pickable
    {
        public GameObject prefab;

        public override bool OnPick()
        {
            Ice.Gameplay.Player.PickItem(this);
            Destroy(gameObject);
            return true;
        }
    }
}
