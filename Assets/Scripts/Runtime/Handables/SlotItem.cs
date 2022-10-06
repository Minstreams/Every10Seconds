using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IceEngine
{
    public class SlotItem : SlotBase
    {
        public Image icon;
        public void SetIcon(Sprite tex)
        {
            icon.sprite = tex;
        }
    }
}
