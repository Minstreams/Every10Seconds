using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IceEngine
{
    public class SlotGun : SlotBase
    {
        public Text ammoText;
        public Text magText;
        public void SetAmmo(int ammo)
        {
            ammoText.text = ammo.ToString();
        }
        public void SetMag(int mag)
        {
            if (magText != null) magText.text = mag.ToString();
        }
    }
}
