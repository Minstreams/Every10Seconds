using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class ScreenText : TimerBehaviour
    {
        TextMesh tm;
        void Start()
        {
            tm = GetComponent<TextMesh>();
        }
        protected override void OnMorning()
        {
            tm.text = $"Good morning, NO. {Ice.Gameplay.Data.id}";
        }
        protected override void OnEvening()
        {
            tm.text = $"Good evening, NO. {Ice.Gameplay.Data.id}";
        }
    }
}
