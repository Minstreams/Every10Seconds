using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace IceEngine
{
    public class CameraMgr : MonoBehaviour
    {
        public Camera cam;
        [Range(0, 1)]
        public float moveRate = 0.1f;
        public static float targetOrthographicSize = 2;


        void Update()
        {
            var offset = Ice.Gameplay.Player.focusPoint.position - transform.position;
            var t = (1 - Mathf.Pow(1 - moveRate, Time.deltaTime));
            transform.Translate(offset * t);
            cam.orthographicSize = Mathf.Lerp(cam.orthographicSize, targetOrthographicSize, t);
        }

        [Button]
        public void AlignSize()
        {
            cam.orthographicSize = targetOrthographicSize;
        }
    }
}
