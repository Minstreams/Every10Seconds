using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class TimerBehaviour : MonoBehaviour
    {
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
        protected virtual void OnMorning() { }
        protected virtual void OnEvening() { }
    }
}
