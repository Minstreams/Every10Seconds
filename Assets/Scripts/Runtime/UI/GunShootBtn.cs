using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace IceEngine
{
    public class GunShootBtn : MonoBehaviour
    {
        public void OnShoot(BaseEventData be)
        {
            var e = (PointerEventData)be;
            if (e.button == PointerEventData.InputButton.Left)
            {
                Ice.Gameplay.Player.UseCurrent();
            }
            else if (e.button == PointerEventData.InputButton.Right)
            {
                Ice.Gameplay.Player.ThrowGrenade();
            }
        }
        public void OnReleseShoot(BaseEventData be)
        {
            var e = (PointerEventData)be;
            if (e.button == PointerEventData.InputButton.Left)
            {
                Ice.Gameplay.Player.ReleaseCurrent();
            }
        }
    }
}
