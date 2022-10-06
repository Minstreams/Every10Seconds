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
        public float camDis = 2;
        public static float targetOrthographicSize = 2;
        public float pulseRate = 1;

        Vector3 targetPos;
        void Awake()
        {
            Ice.Gameplay.CamMgr = this;    
        }
        void Update()
        {
            var offset = Ice.Gameplay.Player.focusPoint.position - transform.position;
            var t = (1 - Mathf.Pow(1 - moveRate, Time.deltaTime));
            transform.Translate(offset * t);
            var size = Mathf.Lerp(cam.orthographicSize, targetOrthographicSize, t);
            cam.orthographicSize = size;
            size *= camDis;
            targetPos = new Vector3(size, size * 1.41421f, -size);
            cam.transform.localPosition += (targetPos - cam.transform.localPosition) * t;
        }

        public void AddPulse(Vector3 push)
        {
            cam.transform.Translate(push * pulseRate, Space.World);
        }

        [Button]
        public void AlignSize()
        {
            cam.orthographicSize = targetOrthographicSize;
        }
    }
}
