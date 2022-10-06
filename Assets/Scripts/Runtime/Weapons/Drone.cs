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
            int coin = Ice.Gameplay.CurLevel.coin;
            Ice.Gameplay.CurLevel.OnDroneEnterShelter();
            go.GetComponent<DroneEffectHolder>().Play(() =>
            {
                if (Ice.Gameplay.UIMgr != null)
                {
                    Ice.Gameplay.UIMgr.ShowNotification($"You drone has brought your {coin} {Ice.Gameplay.Setting.coinMark} " +
                    $"to basement");
                }
                Destroy(go);
            });
        }
    }
}
