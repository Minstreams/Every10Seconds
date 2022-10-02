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
        public Transform aimMark;
        public float harm = 20;
        public float push = 1;
        public LayerMask shotLayerMask;

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
            aimMark.position = AimPos;
            aimMark.LookAt(Camera.main.transform);
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
            Vector3 hitPoint = gunPoint.position + ammoDir * maxDis;
            if (Physics.Raycast(gunPoint.position, ammoDir, out var hit, maxDis, shotLayerMask))
            {
                hitPoint = hit.point;
                if (hit.collider.CompareTag("Enemy"))
                {
                    if (hit.rigidbody != null)
                    {
                        hit.rigidbody.AddForce(ammoDir * push * 15, ForceMode.Impulse);
                    }
                    hit.collider.GetComponentInParent<Enemy>().Harm(harm, ammoDir * push);
                }

                hitParts.transform.position = hitPoint;
                hitParts.transform.rotation = Quaternion.LookRotation(hit.normal);
                hitParts.Emit(Random.Range(2, 5));
                hitSound.Play();
            }

            // 效果
            model.Translate(Vector3.back * forceBackward, Space.Self);
            shotSound.Play();
            shotParts.Emit(Random.Range(2, 5));
            lineRenderer.SetPosition(0, gunPoint.position);
            lineRenderer.SetPosition(1, hitPoint);
            if (lineCoroutine != null)
            {
                StopCoroutine(lineCoroutine);
            }
            lineCoroutine = StartCoroutine(lineFade());
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
