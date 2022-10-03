using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace IceEngine
{
    /// <summary>
    /// 逃生点
    /// </summary>
    public class ExitPoint : PlayerTrigger
    {
#if UNITY_EDITOR
        void OnDrawGizmos()
        {
            var box = GetComponent<BoxCollider>();
            Gizmos.color = Color.cyan;
            Gizmos.DrawWireCube(transform.position + box.center, box.size);
            Gizmos.color = Color.white;
        }
#endif
        protected override void OnPlayerEnter()
        {
            Ice.Gameplay.Escape();
        }
    }
}
