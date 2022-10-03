using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    /// <summary>
    /// 连发武器
    /// </summary>
    public class WeaponUZI : WeaponGun
    {
        public float shootRate = 4;
        public bool instantShoot;
        public override void OnUse()
        {
            autoShootRoutine = StartCoroutine(RunAutoShoot());
        }
        public override void OnEndUse()
        {
            if (autoShootRoutine != null)
            {
                StopCoroutine(autoShootRoutine);
                autoShootRoutine = null;
            }
        }
        Coroutine autoShootRoutine;
        IEnumerator RunAutoShoot()
        {
            var interval = new WaitForSeconds(1 / shootRate);
            if (!instantShoot) yield return interval;
            while (true)
            {
                if (!TryShoot())
                {
                    autoShootRoutine = null;
                    break;
                }
                yield return interval;
            }
        }
    }
}
