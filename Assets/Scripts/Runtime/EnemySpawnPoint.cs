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
                var e = GameObject.Instantiate(enemy, transform.position, transform.rotation).GetComponent<Enemy>();
                e.maxHp = health;
                e.nav.speed = speed;
                e.SpawnAt(transform.position);
                e.anim.SetFloat("type", Random.Range(typeRage.x, typeRage.y));
                yield return new WaitForSeconds(interval);
            }
        }

        void OnDrawGizmos()
        {
            Gizmos.color = new Color(1, 0.6f, 0, 0.8f);
            Gizmos.DrawWireSphere(transform.position, 0.5f);
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
