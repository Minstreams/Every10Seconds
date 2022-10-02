using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    [ExecuteInEditMode]
    public class SceneProp : MonoBehaviour
    {
#if UNITY_EDITOR
        protected virtual void Awake()
        {
            if (UnityEditor.EditorApplication.isPlaying) return;
            if (gameObject.scene.path == "") return;

            var funcGo = GameObject.Find("场景") ?? new GameObject("场景");
            transform.SetParent(funcGo.transform, true);
        }
#endif
    }
}
