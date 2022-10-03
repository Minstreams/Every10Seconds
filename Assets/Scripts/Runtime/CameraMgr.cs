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
        public float targetOrthographicSize = 2;


        void Update()
        {
            var offset = Ice.Gameplay.Player.focusPoint.position - transform.position;
            transform.Translate(offset * (1 - Mathf.Pow(1 - moveRate, Time.deltaTime)));
        }

        [Button]
        public void AlignSize()
        {
            cam.orthographicSize = targetOrthographicSize;
        }
    }
}
