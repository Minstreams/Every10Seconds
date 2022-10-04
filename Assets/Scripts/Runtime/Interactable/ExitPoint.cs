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
            Gizmos.color = isShelter ? Color.cyan : Color.red;
            Gizmos.DrawWireCube(transform.position + box.center, box.size);
            Gizmos.color = Color.white;
        }
#endif

        public bool isShelter;
        protected override void OnPlayerEnter()
        {
            if (isShelter) Ice.Gameplay.UIMgr.OpenShelterUI();
            else Ice.Gameplay.UIMgr.CloseShelterUI();
        }
    }
}
