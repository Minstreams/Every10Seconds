using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Handable : MonoBehaviour
    {
        public static Internal.SettingGameplay Setting => Ice.Gameplay.Setting;

        [Group("IK"), Tooltip("瞄准的方向，影响转身判定，0为正前方，-90为正左方")]
        [Range(-180f, 180f)] public float aimAngleOffset = 0;
        [Range(0f, 1f)] public float ikLeftHand = 0;
        [Range(0f, 1f)] public float ikRightHand = 0;
        [Group("基本")]
        public GameObject pickablePrefab;
        public GameObject slotPrefab;
        public bool aimEnemy = true;
        public Transform aimMark;
        public bool lockTarget = true;
        [NonSerialized] public CharacterBase owner;

        protected Vector3 AimPos => Ice.Gameplay.Player.TargetLook;
        public virtual void OnUpdate()
        {
            if (lockTarget) transform.LookAt(AimPos);
            if (aimMark != null)
            {
                aimMark.position = AimPos;
                aimMark.LookAt(Camera.main.transform);
            }
        }
        public virtual void OnUse() { }
        public virtual void OnRelease() { }
        public virtual void OnReload() { }
        public virtual void OnPick(Pickable p, SlotBase s) { }
        public virtual Slot GetSlot() => null;
        public virtual void OnDrop() { }
        // 近战动画事件回调
        public virtual void OnCheckHit() { }
        public virtual void OnSwitchOn()
        {
            if (aimMark != null) aimMark.gameObject.SetActive(true);
        }
        public virtual void OnSwitchOff()
        {
            if (aimMark != null) aimMark.gameObject.SetActive(false);
        }
    }
}
