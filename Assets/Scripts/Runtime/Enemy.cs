using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace IceEngine
{
    public class Enemy : CharacterBase
    {
        public Handable weapon;
        public Collider hitBox;
        public Collider aimBox;
        public float chaseDistance;
        public override Handable CurrentInHand => weapon;

        [System.NonSerialized] public NavMeshAgent nav;
        protected override void Awake()
        {
            base.Awake();
            nav = GetComponent<NavMeshAgent>();
            weapon.owner = this;
        }
        void Update()
        {
            if (isDead) return;

            if (IsMorning)
            {
                Move(transform.forward, 0, transform.forward);
            }
            else
            {
                var p = Ice.Gameplay.Player.transform.position;
                var pp = transform.position;
                var sightDir = (p - pp).normalized;
                nav.destination = p - sightDir * chaseDistance;

                var vec = nav.velocity;
                var speed = vec.magnitude;
                var forward = speed == 0 ? transform.forward : vec / speed;

                Move(forward, speed, sightDir);

                CurrentInHand.OnUpdate();
            }
        }


        public override void SpawnAt(Vector3 pos)
        {
            base.SpawnAt(pos);
            hp = maxHp;
            nav.enabled = true;
            hitBox.enabled = true;
            aimBox.enabled = true;
            weapon.gameObject.SetActive(true);
        }
        public override void Harm(float harm, Vector3 push)
        {
            if (isDead) return;
            base.Harm(harm, push);
            nav.velocity += push;
        }
        public override void Die(Vector3 push)
        {
            if (isDead) return;
            base.Die(push);
            nav.ResetPath();
            nav.enabled = false;
            hitBox.enabled = false;
            aimBox.enabled = false;
            weapon.gameObject.SetActive(false);
        }

        protected override void OnMorning()
        {
            if (isDead) return;
            nav.ResetPath();
        }
    }
}
