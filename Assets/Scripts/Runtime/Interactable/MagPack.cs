using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    /// <summary>
    /// 弹药箱
    /// </summary>
    public class MagPack : Pickable
    {
        public AudioSource onPickSound;
        public AudioSource notValidSound;
        public override void OnPick()
        {
            var cur = Ice.Gameplay.Player.CurrentInHand;
            if (cur is WeaponGun gun && (gun.ammo != gun.maxAmmo || gun.mag != gun.maxMag))
            {
                gun.ammo = gun.maxAmmo;
                gun.mag = gun.maxMag;
                onPickSound.Play();
            }
            else
            {
                notValidSound.Play();
            }
        }
    }
}
