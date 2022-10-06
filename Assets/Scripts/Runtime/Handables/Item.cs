using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Item : Handable
    {
        [Group("UI")]
        public Sprite icon;

        [NonSerialized] public SlotItem slot;

        public override Slot GetSlot() => Ice.Gameplay.UIMgr.slotItem;
        public override void OnPick(Pickable p, SlotBase s)
        {
            slot = s as SlotItem;
            slot.SetIcon(icon);
        }
    }
}
