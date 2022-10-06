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
        public int ammo = 15;
        public int mag = 15;
        public override bool OnPick()
        {
            Ice.Gameplay.Player.PickWeaponGun(this);
            Destroy(gameObject);
            return true;
        }
    }
}
