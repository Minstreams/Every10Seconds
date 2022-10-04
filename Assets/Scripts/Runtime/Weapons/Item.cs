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
            transform.LookAt(AimPos);
            aimMark.position = AimPos;
            aimMark.LookAt(Camera.main.transform);
        }

        public override void OnSwitchOn()
        {
            aimMark.gameObject.SetActive(true);
        }
        public override void OnSwitchOff()
        {
            aimMark.gameObject.SetActive(false);
        }
    } 
}
