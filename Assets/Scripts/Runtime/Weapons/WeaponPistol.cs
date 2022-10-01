using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class WeaponPistol : WeaponBasic
    {
        public AudioSource shotSound;
        public AudioSource hitSound;
        public ParticleSystem shotParts;
        public ParticleSystem hitParts;
        public LineRenderer lineRenderer;
        public Color lineColor;
        public float lineLifeTime = 0.2f;
        public Transform gunPoint;
        public Transform model;
        public float forceBackward = 0.1f;
        public float forceReboundRate = 0.1f;
        public float maxDis = 100;
        public int maxAmmo = 15;
        public GameObject slotPrefab;

        SlotPistol slot;
        int ammo;

        public override void OnPick(Pickable p)
        {
            var pb = p as PickableBasic;
            ammo = pb.ammo;
            slot = Ice.Gameplay.UIMgr.slotBasic.Load(slotPrefab).GetComponent<SlotPistol>();
            slot.SetAmmo(ammo);
        }
        public override void OnUpdate()
        {
            transform.LookAt(AimPos);
        }
        void FixedUpdate()
        {
            model.localPosition = model.localPosition * forceReboundRate;
        }
        public override void OnUse()
        {
            Ice.Gameplay.UIMgr.ShowNotification("Use");

            if (ammo == 0)
            {
                OnReload();
                return;
            }

            slot.SetAmmo(--ammo);

            Vector3 ammoDir = (AimPos - gunPoint.position).normalized;
            bool hited = Physics.Raycast(gunPoint.position, ammoDir, out var ammoHit, maxDis, -1);
            if (hited)
            {
                //Harm(ammoHit, ammoDir);
            }

            // 效果
            model.Translate(Vector3.back * forceBackward, Space.Self);
            shotSound.Play();
            shotParts.Emit(Random.Range(2, 5));
            lineRenderer.SetPosition(0, gunPoint.position);
            lineRenderer.SetPosition(1, hited ? ammoHit.point : gunPoint.position + ammoDir * maxDis);
            if (lineCoroutine != null)
            {
                StopCoroutine(lineCoroutine);
            }
            lineCoroutine = StartCoroutine(lineFade());
            if (hited)
            {
                hitParts.transform.position = ammoHit.point;
                hitParts.transform.rotation = Quaternion.LookRotation(ammoHit.normal);
                hitParts.Emit(Random.Range(2, 5));
                hitSound.Play();
            }
        }
        Coroutine lineCoroutine;
        IEnumerator lineFade()
        {
            Color c = lineColor;

            while (c.a > 0)
            {
                c.a -= Time.deltaTime / lineLifeTime;
                lineRenderer.endColor = c;
                yield return 0;
            }
            c.a = 0;
            lineRenderer.endColor = c;
        }
        public override void OnReload()
        {
            Ice.Gameplay.UIMgr.ShowNotification("OnReload");
            slot.SetAmmo(ammo = maxAmmo);
        }
    }
}
