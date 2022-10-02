using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    [ExecuteInEditMode]
    public class PlayerTrigger : MonoBehaviour
    {
#if UNITY_EDITOR
        protected virtual void Awake()
        {
            if (UnityEditor.EditorApplication.isPlaying) return;
            if (gameObject.scene.path == "") return;

            var funcGo = GameObject.Find("功能") ?? new GameObject("功能");
            transform.SetParent(funcGo.transform, true);
        }
#endif

        void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                OnPlayerEnter();
            }
        }
        void OnTriggerExit(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                OnPlayerExit();
            }
        }

        protected virtual void OnPlayerEnter() { }
        protected virtual void OnPlayerExit() { }
    }
}
