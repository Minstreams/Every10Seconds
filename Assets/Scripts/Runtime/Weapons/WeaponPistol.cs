using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    /// <summary>
    /// 单发武器
    /// </summary>
    public class WeaponPistol : WeaponGun
    {
        public override void OnUse()
        {
            TryShoot();
        }
    }
}
