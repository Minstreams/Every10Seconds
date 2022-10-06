using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Events;

namespace IceEngine
{
    [Label("扔出去的手雷实例"), ThemeColor(1, 0, 1)]
    public class GrenadeInstance : MonoBehaviour
    {
        public static Internal.SettingGameplay Setting => Ice.Gameplay.Setting;

        [Label("爆炸时长")] public float time = 3;
        [Label("撞击减少时长")] public float hitTimeCost = 0;
        [Label("爆炸范围")] public float range = 3;
        [Label("友伤")] public bool harmPlayer = true;
        [Label("爆炸回调")] public SimpleEvent onExplode;

        Transform Center => transform;
        float timer = 0;
        public void StartTick()
        {
            StartCoroutine(RunTick());
        }
        IEnumerator RunTick()
        {
            timer = time;
            while (timer > 0)
            {
                yield return 0;
                timer -= Time.deltaTime;
            }

            // Explode
            LayerMask mask = 1 << Setting.LayerEnemy;
            if (harmPlayer) mask |= 1 << Setting.LayerPlayer;
            Physics.OverlapSphere(Center.position, range, )
        }
        private void OnCollisionEnter(Collision collision)
        {
            timer -= hitTimeCost;
        }

        void OnDrawGizmos()
        {
            using var _ = new GizmosColorScope(Color.red);
            Gizmos.DrawWireSphere(Center.position, range);
        }
    }
}
