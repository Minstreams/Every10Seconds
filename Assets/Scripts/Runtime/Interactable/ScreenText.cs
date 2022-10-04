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
            tm.text = $"Good morning, seeker NO. {Ice.Gameplay.Data.id}\n{ExtraText}";
        }
        protected override void OnEvening()
        {
            tm.text = $"Good evening, seeker NO. {Ice.Gameplay.Data.id}\n{ExtraText}";
        }
        string ExtraText => Ice.Gameplay.CurLevel.GetStatisticText();
    }
}
