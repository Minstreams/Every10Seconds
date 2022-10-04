using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace IceEngine
{
    [Serializable]
    [CreateAssetMenu(fileName = "Dialog", menuName = "对话")]
    public class Dialog : ScriptableObject
    {
        public Condition condition = new();
        public List<DialogBlock> blockList = new();
    }
    [Serializable]
    public class DialogBlock
    {
        public string content;
        public List<DialogChoice> dialogChoices = new();
    }
    [Serializable]
    public class DialogChoice
    {
        public string content;
        public int nextId;
        public UnityEvent action;
    }

    [Serializable]
    public class Condition
    {
        public bool alwaysTrue;
        public bool IsConditionMeet()
        {
            if (alwaysTrue) return true;
            return false;
        }
    }
}
