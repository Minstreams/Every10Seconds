using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Handable : MonoBehaviour
    {
        /// <summary>
        /// 瞄准的方向，影响转身判定，0为正前方，-90为正左方
        /// </summary>
        [Range(-180f, 180f)] public float aimAngleOffset = 0;
        [Range(0f, 1f)] public float ikLeftHand = 0;
        [Range(0f, 1f)] public float ikRightHand = 0;
        public GameObject pickablePrefab;
        public bool aimEnemy = true;
        [NonSerialized] public CharacterBase owner;

        protected Vector3 AimPos => Ice.Gameplay.Player.TargetLook;
        public virtual void OnUpdate() { }
        public virtual void OnUse() { }
        public virtual void OnEndUse() { }
        public virtual void OnReload() { }
        public virtual void OnPick(Pickable p) { }
        // 近战动画事件回调
        public virtual void OnCheckHit() { }
        public virtual void OnSwitchOff() { }
        public virtual void OnSwitchOn() { }
    }
}
