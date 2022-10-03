using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace IceEngine
{
    public class Door : Pickable
    {
        public GameObject doorObj;
        public override void OnPick()
        {
            doorObj.SetActive(false);
        }
        protected override void OnPlayerExit()
        {
            base.OnPlayerExit();
            doorObj.SetActive(true);
        }
    }
}
