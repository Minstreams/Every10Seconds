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

        [Label("基本属性")] public GrenadeInfo info;

        [Group]
        public AnimationCurve pushCurve = AnimationCurve.Linear(0, 1, 1, 0);
        [Label("爆炸回调")] public SimpleEvent onExplode;

        Transform Center => transform;
        float timer = 0;
        public void ThrowTo(Vector3 aimPos, float speed)
        {
            var g = Physics.gravity.y;
            var pos = transform.position;
            var vec = aimPos - pos;
            var vecXZ = vec; vecXZ.y = 0;
            var disXZ = vecXZ.magnitude;
            var t = disXZ / speed;
            var speedY = (vec.y - 0.5f * g * t * t) / t;

            GetComponent<Rigidbody>().velocity = vecXZ.normalized * speed + Vector3.up * speedY;

            StartTick();
        }
        [Button]
        public void StartTick()
        {
            StopAllCoroutines();
            StartCoroutine(RunTick());
        }
        IEnumerator RunTick()
        {
            timer = info.time;
            while (timer > 0)
            {
                yield return 0;
                timer -= Time.deltaTime;
            }

            // Explode
            LayerMask mask = 1 << Setting.LayerEnemy;
            if (info.harmPlayer) mask |= 1 << Setting.LayerPlayer;
            onExplode?.Invoke();
            var cols = Physics.OverlapSphere(Center.position, info.range, mask, QueryTriggerInteraction.Ignore);
            HashSet<Enemy> hittedEnemySet = new();
            bool hittedPlayer = false;
            foreach (var col in cols)
            {
                var vec = col.transform.position - Center.position;
                var len = vec.magnitude;
                var dir = vec / len;
                var p = info.push * pushCurve.Evaluate(len / info.range);

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
                            e.Harm(info.harm, dir * p);
                        }
                    }
                }
                else if (info.harmPlayer && col.gameObject.layer == Setting.LayerPlayer)
                {
                    var pl = col.GetComponentInParent<Player>();
                    if (pl != null && !hittedPlayer)
                    {
                        hittedPlayer = true;
                        pl.Harm(info.harm, dir * p);
                    }
                }
            }
        }
        private void OnCollisionEnter(Collision collision)
        {
            timer -= info.hitTimeCost;
        }

        void OnDrawGizmos()
        {
            using (new GizmosColorScope(Color.red))
            {
                Gizmos.DrawWireSphere(Center.position, info.range);
            }
            using (new GizmosColorScope(Color.red))
            {
                Gizmos.DrawWireCube(transform.position + Vector3.up * 1.2f, new Vector3(1, 0.1f, 0.1f));
            }
            using (new GizmosColorScope(Color.green))
            {
                var h = timer / info.time;
                Gizmos.DrawCube(transform.position + new Vector3(-0.5f + 0.5f * h, 1.2f, 0), new Vector3(h, 0.1f, 0.1f));
            }
        }
    }
}
