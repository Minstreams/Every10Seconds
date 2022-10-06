using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace IceEngine
{
    [ExecuteInEditMode]
    public class EnemySpawnPoint : TimerBehaviour
    {
        public List<GameObject> enemyList = new();
        [Label("间隔时间")] public float interval = 10;
        [Label("速度")] public float speed = 1;
        [Label("生命值")] public float health = 3;
        [Label("生成范围半径")] public float radius;
        public Vector2 range;
        public Vector2 timeRange;
        public Vector2Int coinRange;
        public float weaponInterval = 5;
        public float weaponRange = 2;
        public float weaponHarm = 5;
        public float weaponPush = 0.3f;


        float t;

        void Update()
        {
#if UNITY_EDITOR
            if (!EditorApplication.isPlaying) return;
#endif
            if (t <= 0)
            {
                if (CurTime >= timeRange.x && CurTime <= timeRange.y)
                {
                    var dis = Vector3.Distance(transform.position, Ice.Gameplay.Player.transform.position);
                    if (dis >= range.x && dis <= range.y)
                    {
                        var offset = Random.insideUnitCircle * radius;
                        var pos = transform.position + new Vector3(offset.x, 0, offset.y);
                        var e = Ice.Gameplay.CurLevel.GetEnemyAt(enemyList[Random.Range(0, enemyList.Count)], pos, transform.rotation);
                        e.maxHp = health;
                        e.nav.speed = speed;
                        e.coin = Random.Range(coinRange.x, coinRange.y + 1);
                        if (e.CurrentInHand is WeaponZombie wz)
                        {
                            wz.interval = weaponInterval;
                            wz.range = weaponRange;
                            wz.harm = weaponHarm;
                            wz.push = weaponPush;
                        }
                        e.SpawnAt(pos);
                        t += interval;
                    }
                }
            }
            else
            {
                t -= Time.deltaTime;
            }
        }
        void OnDrawGizmos()
        {
            void DrawDisc(float radius, Color color)
            {
                using var _ = new GizmosColorScope(color);
                var c = transform.position;
                for (float i = 0; i < Mathf.PI * 2; i += Mathf.PI / 16)
                {
                    float i2 = i + Mathf.PI / 16;
                    var p1 = c + new Vector3(Mathf.Sin(i) * radius, 0, Mathf.Cos(i) * radius);
                    var p2 = c + new Vector3(Mathf.Sin(i2) * radius, 0, Mathf.Cos(i2) * radius);
                    Gizmos.DrawLine(p1, p2);
                }
            }
            DrawDisc(radius, new Color(1, 0.6f, 0, 0.8f));
            DrawDisc(range.x, new Color(0, 0.6f, 1, 1));
            DrawDisc(range.y, new Color(0, 1, 0.6f, 1));
        }

#if UNITY_EDITOR
        void Awake()
        {
            if (EditorApplication.isPlaying) return;
            if (gameObject.scene.path == "") return;

            var funcGo = GameObject.Find("功能") ?? new GameObject("功能");
            transform.SetParent(funcGo.transform, true);
        }

        [Button("放于地面")]
        public void PutOnGround()
        {
            if (Physics.Raycast(transform.position, Vector3.down, out RaycastHit hit, 100, 1 << LayerMask.NameToLayer("Ground"), QueryTriggerInteraction.Ignore))
            {
                transform.position = hit.point;
            }
        }
#endif
    }
}
