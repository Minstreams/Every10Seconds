using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    /// <summary>
    /// 基础武器
    /// </summary>
    public class PickableGun : Pickable
    {
        public WeaponSlotType type;
        public GameObject prefab;
        public int ammo = 15;
        public int mag = 15;
        public override void OnPick()
        {
            Ice.Gameplay.UIMgr.ShowNotification("捡起了一个手枪");
            Ice.Gameplay.Player.PickWeaponGun(this);
            Destroy(gameObject);
        }
    }
}
