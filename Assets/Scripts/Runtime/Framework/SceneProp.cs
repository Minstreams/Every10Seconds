using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    [ExecuteInEditMode]
    public class SceneProp : MonoBehaviour
    {
        public enum PropType
        {
            Brick,
        }
        public PropType type;
        public Transform brick;
        protected virtual void Awake()
        {
#if UNITY_EDITOR
            if (UnityEditor.EditorApplication.isPlaying) return;
            if (gameObject.scene.path == "") return;

            var funcGo = GameObject.Find("场景") ?? new GameObject("场景");
            if (!transform.IsChildOf(funcGo.transform)) transform.SetParent(funcGo.transform, true);
#endif
        }
        protected virtual void Update()
        {
#if UNITY_EDITOR
            switch (type)
            {
                case PropType.Brick:
                    transform.position = transform.position.Snap();
                    break;
            }
#endif
        }
#if UNITY_EDITOR
        [Button("随机旋转")]
        public void SetRandomRotation()
        {
            float RA() => Random.Range(0, 4) * 90;
            brick.rotation = Quaternion.Euler(RA(), RA(), RA());
            UnityEditor.EditorUtility.SetDirty(brick);
        }
#endif
    }

}
