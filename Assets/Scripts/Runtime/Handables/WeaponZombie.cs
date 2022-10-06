using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class WeaponZombie : Handable
    {
        public float interval = 5;
        public float range = 2;
        public float harm = 5;
        public float push = 1;

        float t = 0;
        bool IsInRange => Vector3.Distance(Ice.Gameplay.Player.focusPoint.position, transform.position) < range;
        void OnDrawGizmos()
        {
            using var _ = new GizmosColorScope(Color.red);
            Gizmos.DrawWireSphere(transform.position, range);
        }
        public override void OnUpdate()
        {
            base.OnUpdate();
            if (t <= 0)
            {
                if (IsInRange)
                {
                    OnUse();
                    t = interval;
                }
            }
            else
            {
                t -= Time.deltaTime;
            }
        }
        public override void OnUse()
        {
            base.OnUse();
            owner.anim.SetTrigger("Attack");
        }

        public override void OnCheckHit()
        {
            if (IsInRange)
            {
                Ice.Gameplay.Player.Harm(harm, transform.forward * push);
            }
        }
    }
}
