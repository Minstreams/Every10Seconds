using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Drone : Item
    {
        public GameObject droneDisplayerPrefab;
        public override void OnUse()
        {
            Ice.Gameplay.Player.DropItem(false);
            var go = GameObject.Instantiate(droneDisplayerPrefab);
            go.GetComponent<DroneEffectHolder>().Play(() =>
            {
                Ice.Gameplay.CurLevel.OnDroneEnterShelter();
                Destroy(go);
            });
        }
    }
}
