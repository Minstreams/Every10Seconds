using System;
using UnityEngine;

namespace IceEngine
{
    [Label("扔出去的手雷实例"), ThemeColor(1, 0, 1)]
    public class GrenadeInstance : MonoBehaviour
    {
        [Label("爆炸时长")] public float time = 3;
        [Label("撞击减少时长")] public float hitTimeCost = 0;
        [Label("爆炸范围")] public float range = 3;

        void OnDrawGizmos()
        {
            using var _ = new GizmosColorScope(Color.red);
            Gizmos.DrawWireSphere(transform.position, range);
        }
    }
}
