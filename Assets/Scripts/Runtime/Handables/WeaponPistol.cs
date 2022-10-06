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
        public int ammoCountInOnShoot = 1;
        public override int LineCount => ammoCountInOnShoot;
        public override void OnUse()
        {
            for (int i = 0; i < ammoCountInOnShoot; i++)
            {
                TryShoot();
            }
        }

#if UNITY_EDITOR
        [Button]
        public void ShotgunTest()
        {
            for (int i = lineList.Count; i < LineCount; ++i)
            {
                lineList.Add(GameObject.Instantiate(lineRenderer, transform));
                lineCorList.Add(null);
            }
        }
#endif
    }
}
