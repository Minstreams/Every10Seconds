using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace IceEngine
{
    /// <summary>
    /// 玩家出生点
    /// </summary>
    [ExecuteInEditMode]
    public class SpawnPoint : MonoBehaviour
    {
        [HideInInspector]
        public bool valid = true;
        void OnDrawGizmos()
        {
            using var _ = new GizmosColorScope(new Color(valid ? 0 : 1, valid ? 1 : 0, 0, 0.3f));
            Gizmos.DrawWireSphere(transform.position, 0.5f);
        }

#if UNITY_EDITOR
        void Awake()
        {
            if (EditorApplication.isPlaying) return;
            if (gameObject.scene.path == "") return;

            var funcGo = GameObject.Find("功能") ?? new GameObject("功能");
            foreach (var o in funcGo.GetComponentsInChildren<SpawnPoint>())
            {
                if (o != this)
                {
                    valid = false;
                    break;
                }
            }
            if (valid)
            {
                transform.SetParent(funcGo.transform, true);
            }
            else
            {
                Debug.LogError("已有出生点，不能重复添加");
            }
        }

        [Button("放于地面")]
        public void PutOnGround()
        {
            if (Physics.Raycast(transform.position, Vector3.down, out RaycastHit hit, 100, 1 << LayerMask.NameToLayer("Ground"), QueryTriggerInteraction.Ignore))
            {
                transform.position = hit.point;
            }
        }
#endif
    }
}
