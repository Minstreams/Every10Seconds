using System;
using UnityEngine;

namespace IceEngine
{
    [Label("扔出去的手雷实例"), ThemeColor(1, 0, 1)]
    public class GrenadeInstance : MonoBehaviour
    {
        [Group("Test")]
        [Label("爆炸时长")] public float time = 3;
        [Label("撞击减少时长")] public float hitTimeCost = 0;
        [Group]
        [Label("爆炸范围")] public float range = 3;

        [Label("测试一下")] public A1 Aawewe;
        [System.Serializable]
        public class A1
        {
            public float c1;
            public float c2;
        }

        void OnDrawGizmos()
        {

        }
    }
}
