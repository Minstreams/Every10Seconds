using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IceEngine
{
    public class GunShootBtn : MonoBehaviour
    {
        public void OnShoot() => Ice.Gameplay.Player.Shoot();
        public void OnReleseShoot() => Ice.Gameplay.Player.ReleaseShoot();
    }
}
