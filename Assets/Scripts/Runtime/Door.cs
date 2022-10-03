using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace IceEngine
{
    public class Door : Pickable
    {
        public GameObject doorObj;
        public GameObject doorMesh;
        public override void OnPick()
        {
            doorObj.SetActive(false);
        }
        protected override void OnPlayerEnter()
        {
            base.OnPlayerEnter();
            doorMesh.layer = LayerMask.NameToLayer("PickableSelected");
        }
        protected override void OnPlayerExit()
        {
            base.OnPlayerExit();
            doorObj.SetActive(true);
            doorMesh.layer = LayerMask.NameToLayer("Wall");
        }
    }
}
