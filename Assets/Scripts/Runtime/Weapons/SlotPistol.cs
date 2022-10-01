using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IceEngine
{
    public class SlotPistol : MonoBehaviour
    {
        public Text ammoText;
        public void SetAmmo(int ammo)
        {
            ammoText.text = ammo.ToString();
        }
    }
}
