using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    [Label("手上的手雷"), ThemeColor(1, 0, 1)]
    public class Grenade : Handable
    {
        [Label("基本属性")] public GrenadeInfo info;

        [Group]
        public GameObject instancePrefab;
        public Sprite icon;
        public float throwSpeed = 5;

        public int ID { get; set; }

        SlotItem slot;
        public override void OnPick(Pickable p, SlotBase s)
        {
            OnPlacedInSlot(s as SlotItem);

            var pg = p as PickableGrenade;
            info = pg.info;

            aimMark.gameObject.SetActive(false);
        }
        public override void OnDrop(Pickable p)
        {
            if (p == null) return;

            var pg = p as PickableGrenade;
            pg.info = info;
        }
        public void OnPlacedInSlot(SlotItem s)
        {
            slot = s;
            slot.SetIcon(icon);
        }
        public override Slot GetSlot() => Ice.Gameplay.UIMgr.slotGrenadeList[ID];

        public override void OnUse()
        {
            var ins = GameObject.Instantiate(instancePrefab).GetComponent<GrenadeInstance>();
            ins.info = info;
            ins.transform.position = transform.position;
            ins.ThrowTo(AimPos, throwSpeed);

            Ice.Gameplay.Player.DropGrenade(false);
        }
    }

    [System.Serializable]
    public class GrenadeInfo
    {
        [Label("爆炸时长")] public float time = 3;
        [Label("撞击减少时长")] public float hitTimeCost = 0;
        [Label("爆炸范围")] public float range = 3;
        [Label("伤害")] public float harm = 1;
        [Label("推力")] public float push = 1;
        [Label("友伤")] public bool harmPlayer = true;
    }
}
