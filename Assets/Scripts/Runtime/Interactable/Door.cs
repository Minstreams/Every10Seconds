using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace IceEngine
{
    public class Door : Interactable
    {
        public GameObject doorObj;
        public GameObject doorMesh;
        public override bool OnPick()
        {
            doorObj.SetActive(false);
            return true;
        }
        protected override void OnPlayerEnter()
        {
            base.OnPlayerEnter();
            doorMesh.layer = Setting.LayerPickableSelected;
        }
        protected override void OnPlayerExit()
        {
            base.OnPlayerExit();
            doorObj.SetActive(true);
            doorMesh.layer = Setting.LayerWall;
        }
    }
}
