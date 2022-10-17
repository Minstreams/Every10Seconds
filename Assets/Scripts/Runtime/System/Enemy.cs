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
        public int type;
        public int coin = 1;
        [Label("光耐受")] public float lightThres = 1;
        public override Handable CurrentInHand => weapon;

        Light Sun => Ice.Gameplay.CurLevel.sun;
        [System.NonSerialized] public NavMeshAgent nav;
        [System.NonSerialized] public float extraLight = 0;
        protected override void Awake()
        {
            base.Awake();
            nav = GetComponent<NavMeshAgent>();
            weapon.owner = this;
        }
        void Update()
        {
            if (isDead) return;

            float light = Physics.Raycast(focusPoint.position, -Sun.transform.forward, 50, Setting.MaskGroundAndWall) ? 0 : Sun.intensity;
            light += extraLight;

            if (light < lightThres)
            {
                // In Shadow
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
            else
            {
                // In Light
                if (nav.hasPath) nav.ResetPath();
                Move(transform.forward, 0, transform.forward);
            }
        }


        public override void SpawnAt(Vector3 pos)
        {
            base.SpawnAt(pos);
            hp = maxHp;
            nav.enabled = true;
            hitBox.gameObject.SetActive(true);
            aimBox.enabled = true;
            weapon.gameObject.SetActive(true);
            anim.SetFloat("type", type);
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
            hitBox.gameObject.SetActive(false);
            aimBox.enabled = false;
            weapon.gameObject.SetActive(false);
            Ice.Gameplay.Data.enemiesBeaten++;
            Ice.Gameplay.Player.AddCoin(coin, focusPoint.position);
        }
    }
}
