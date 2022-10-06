using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IceEngine
{
    public class GunShootBtn : MonoBehaviour
    {
        public void OnShoot() => Ice.Gameplay.Player.UseCurrent();
        public void OnReleseShoot() => Ice.Gameplay.Player.ReleaseCurrent();
        public void OnThrowGrenade() => Ice.Gameplay.Player.ThrowGrenade();
    }
}
