using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace IceEngine
{
    public class Door : Pickable
    {
        public Collider doorCollider;
        public UnityAction onOpen;
        public override void OnPick()
        {
            doorCollider.enabled = false;
            onOpen?.Invoke();
        }
        protected override void OnPlayerExit()
        {
            base.OnPlayerExit();
            doorCollider.enabled = true;
        }
    }
}
