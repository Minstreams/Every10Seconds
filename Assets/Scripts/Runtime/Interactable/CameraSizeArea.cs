using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class CameraSizeArea : PlayerTrigger
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
        public float size = 2;
        public bool isShelter;
        protected override void OnPlayerEnter()
        {
            base.OnPlayerEnter();
            CameraMgr.targetOrthographicSize = size;
            if (isShelter) Ice.Gameplay.CurLevel.EnterShelter();
            else Ice.Gameplay.CurLevel.ExitShelter();
        }
    }
}
