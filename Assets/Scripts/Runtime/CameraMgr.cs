using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace IceEngine
{
    [ExecuteInEditMode]
    public class CameraMgr : MonoBehaviour
    {
        public Camera cam;
        [Range(0, 1)]
        public float moveRate = 0.1f;
#if UNITY_EDITOR
        bool selected = false;
#endif
        void Update()
        {
#if UNITY_EDITOR
            if (!EditorApplication.isPlaying)
            {
                var pl = FindObjectOfType<Player>();
                if (pl != null)
                {
                    transform.position = pl.transform.position;
                }
                else
                {
                    var sp = FindObjectOfType<SpawnPoint>();
                    if (sp != null)
                    {
                        transform.position = sp.transform.position;
                    }
                }
                if (Selection.activeGameObject == gameObject)
                {
                    if (!selected)
                    {
                        selected = true;
                        TraceCamaera();
                    }
                    else
                    {
                        AlignCamera();
                        TraceCamaera();
                    }
                }
                else
                {
                    if (selected)
                    {
                        selected = false;
                    }
                }
                return;
            }
            else
            {
                if (Selection.activeGameObject == gameObject || selected)
                {
                    Selection.activeGameObject = null;
                    selected = false;
                }
            }
#endif
            var offset = Ice.Gameplay.Player.focusPoint.position - transform.position;
            transform.Translate(offset * (1 - Mathf.Pow(1 - moveRate, Time.deltaTime)));
        }

#if UNITY_EDITOR
        public void TraceCamaera()
        {
            if (cam == null) return;
            var sv = SceneView.lastActiveSceneView;
            if (sv != null)
            {
                sv.camera.transform.position = cam.transform.position;
                sv.pivot = transform.position;
                sv.orthographic = cam.orthographic;
                sv.camera.fieldOfView = cam.fieldOfView;
                sv.camera.orthographicSize = cam.orthographicSize;
            }
        }
        public void AlignCamera()
        {
            if (cam == null) return;
            var sv = SceneView.lastActiveSceneView;
            if (sv != null)
            {
                cam.transform.position = sv.camera.transform.position;
                cam.transform.rotation = sv.camera.transform.rotation;
                var forward = cam.transform.forward;
                cam.transform.localPosition = Vector3.Dot(forward, cam.transform.localPosition) * forward;
                cam.orthographic = sv.camera.orthographic;
                cam.orthographicSize = sv.camera.orthographicSize;
                cam.fieldOfView = sv.camera.fieldOfView;
                EditorUtility.SetDirty(cam);
            }
        }
#endif
    }
}
