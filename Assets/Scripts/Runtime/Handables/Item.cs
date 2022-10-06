using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Item : Handable
    {
        [Header("UI")]
        public GameObject slotPrefab;
        public Transform aimMark;
        public Sprite icon;
        public bool lockTarget = true;

        [NonSerialized] public SlotItem slot;

        public override void OnPick(Pickable p)
        {
            //var pi = p as PickableItem;
            slot = Ice.Gameplay.UIMgr.slotItem.Load(slotPrefab).GetComponent<SlotItem>();
            slot.SetIcon(icon);
        }
        public override void OnDrop()
        {
            Ice.Gameplay.UIMgr.slotItem.Unload();
        }
        public override void OnUpdate()
        {
            if (lockTarget) transform.LookAt(AimPos);
            if (aimMark != null)
            {
                aimMark.position = AimPos;
                aimMark.LookAt(Camera.main.transform);
            }
        }

        public override void OnSwitchOn()
        {
            if (aimMark != null) aimMark.gameObject.SetActive(true);
        }
        public override void OnSwitchOff()
        {
            if (aimMark != null) aimMark.gameObject.SetActive(false);
        }
    }
}
