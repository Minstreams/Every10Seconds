using System;
using System.Collections;
using System.Collections.Generic;
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
        public float harm = 1;
        public float push = 1;
        public AnimationCurve pushCurve = AnimationCurve.Linear(0, 1, 1, 0);
        [Label("友伤")] public bool harmPlayer = true;
        [Label("爆炸回调")] public SimpleEvent onExplode;

        Transform Center => transform;
        float timer = 0;
        [Button]
        public void StartTick()
        {
            StopAllCoroutines();
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
            onExplode?.Invoke();
            var cols = Physics.OverlapSphere(Center.position, range, mask, QueryTriggerInteraction.Ignore);
            HashSet<Enemy> hittedEnemySet = new();
            foreach (var col in cols)
            {
                var vec = col.transform.position - Center.position;
                var len = vec.magnitude;
                var dir = vec / len;
                var p = push * pushCurve.Evaluate(len / range);

                var rig = col.attachedRigidbody;
                if (rig != null)
                {
                    rig.AddForce(rig.mass * p * dir, ForceMode.Impulse);
                }
                if (col.gameObject.layer == Setting.LayerEnemy)
                {
                    var e = col.GetComponentInParent<Enemy>();
                    if (e != null)
                    {
                        if (!hittedEnemySet.Contains(e))
                        {
                            hittedEnemySet.Add(e);
                            e.Harm(harm, dir * p);
                        }
                    }
                }
            }
        }
        private void OnCollisionEnter(Collision collision)
        {
            timer -= hitTimeCost;
        }

        void OnDrawGizmos()
        {
            using (new GizmosColorScope(Color.red))
            {
                Gizmos.DrawWireSphere(Center.position, range);
            }
            using (new GizmosColorScope(Color.red))
            {
                Gizmos.DrawWireCube(transform.position + Vector3.up * 1.2f, new Vector3(1, 0.1f, 0.1f));
            }
            using (new GizmosColorScope(Color.green))
            {
                var h = timer / time;
                Gizmos.DrawCube(transform.position + new Vector3(-0.5f + 0.5f * h, 1.2f, 0), new Vector3(h, 0.1f, 0.1f));
            }
        }
    }
}
