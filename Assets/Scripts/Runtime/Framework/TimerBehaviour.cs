using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class TimerBehaviour : MonoBehaviour
    {
        public static Internal.SettingGameplay Setting => Ice.Gameplay.Setting;

        void OnEnable()
        {
#if UNITY_EDITOR
            if (!UnityEditor.EditorApplication.isPlaying) return;
#endif
            Ice.Gameplay.onMorning += OnMorning;
            Ice.Gameplay.onEvening += OnEvening;
        }
        void OnDisable()
        {
#if UNITY_EDITOR
            if (!UnityEditor.EditorApplication.isPlaying) return;
#endif
            Ice.Gameplay.onMorning -= OnMorning;
            Ice.Gameplay.onEvening -= OnEvening;
        }
        protected bool IsMorning => Ice.Gameplay.isMorning;
        protected float CurTime => Ice.Gameplay.CurTime;
        protected virtual void OnMorning() { }
        protected virtual void OnEvening() { }
    }
}
