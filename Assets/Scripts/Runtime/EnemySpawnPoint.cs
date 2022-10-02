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
        public GameObject enemy;
        public float interval = 10;
        public float speed = 1;
        public float health = 3;
        public Vector2 typeRage = Vector2.up;
        public float range;
        protected override void OnMorning()
        {
            StopAllCoroutines();
        }
        protected override void OnEvening()
        {
            StartCoroutine(RunMain());
        }
        IEnumerator RunMain()
        {
            while (true)
            {
                var offset = Random.insideUnitCircle * Random.value * range;
                var pos = transform.position + new Vector3(offset.x, 0, offset.y);
                var e = GameObject.Instantiate(enemy, pos, transform.rotation).GetComponent<Enemy>();
                e.maxHp = health;
                e.nav.speed = speed;
                e.SpawnAt(pos);
                e.anim.SetFloat("type", Random.Range(typeRage.x, typeRage.y));
                yield return new WaitForSeconds(interval);
            }
        }

        void OnDrawGizmos()
        {
            Gizmos.color = new Color(1, 0.6f, 0, 0.8f);
            var c = transform.position;
            for (float i = 0; i < Mathf.PI * 2; i += Mathf.PI / 16)
            {
                float i2 = i + Mathf.PI / 16;
                var p1 = c + new Vector3(Mathf.Sin(i) * range, 0, Mathf.Cos(i) * range);
                var p2 = c + new Vector3(Mathf.Sin(i2) * range, 0, Mathf.Cos(i2) * range);
                Gizmos.DrawLine(p1, p2);
            }
            Gizmos.color = Color.white;

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
