using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class CameraSizeArea : PlayerTrigger
    {
        public float size = 2;
        protected override void OnPlayerEnter()
        {
            base.OnPlayerEnter();
            CameraMgr.targetOrthographicSize = size;
        }
    }
}
