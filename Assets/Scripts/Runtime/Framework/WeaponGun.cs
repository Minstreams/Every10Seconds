using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class WeaponGun : Weapon
    {
        [Header("效果")]
        public AudioSource shotSound;
        public ParticleSystem shotParts;
        public ParticleSystem ammoParts;
        public Vector2Int shotPartsEmitRange = new Vector2Int(2, 5);

        public AudioSource hitSound;
        public ParticleSystem hitParts;

        public LineRenderer lineRenderer;
        public Color lineColor;
        public float lineLifeTime = 0.2f;

        public Transform gunPoint;

        public Transform model;
        public float forceBackward = 0.1f;
        public float forceReboundRate = 0.1f;

        [Header("属性")]
        public float maxDis = 100;
        public int maxAmmo = 15;
        public float harm = 20;
        public float push = 1;
        public LayerMask shotLayerMask;
        public int maxMag = 30;
        public bool infiniteAmmo;

        [Header("UI")]
        public GameObject slotPrefab;
        public Transform aimMark;

        [Header("装弹")]
        public AudioSource reloadSound;
        public AudioSource reloadedSound;
        public AudioSource emptySound;
        public float reloadTime;
        public float reloadEndTime;

        [NonSerialized] public int ammo;
        [NonSerialized] public int mag;
        [NonSerialized] public SlotGun slot;

        public override void OnPick(Pickable p)
        {
            var pb = p as PickableGun;
            ammo = pb.ammo;
            mag = pb.mag;

            var uiSlot = weaponType switch
            {
                WeaponSlotType.Basic => Ice.Gameplay.UIMgr.slotBasic,
                WeaponSlotType.Main => Ice.Gameplay.UIMgr.slotMain,
                _ => Ice.Gameplay.UIMgr.slotBasic,
            };
            slot = uiSlot.Load(slotPrefab).GetComponent<SlotGun>();
            slot.SetAmmo(ammo);
            slot.SetMag(mag);
        }

        public override void OnSwitchOn()
        {
            reloadedSound.Play();
            aimMark.gameObject.SetActive(true);
        }
        public override void OnSwitchOff()
        {
            aimMark.gameObject.SetActive(false);
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

        public bool TryShoot()
        {
            if (IsReloading) return false;
            if (!infiniteAmmo && ammo == 0 && mag == 0)
            {
                emptySound.Play();
                return false;
            }

            if (ammo == 0)
            {
                OnReload();
                return false;
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
                        hit.rigidbody.AddForce(15 * push * ammoDir, ForceMode.Impulse);
                    }
                    var e = hit.collider.GetComponentInParent<Enemy>();
                    e.Harm(harm, ammoDir * push);
                }

                // Hit Effects
                hitParts.transform.position = hitPoint;
                hitParts.transform.rotation = Quaternion.LookRotation(hit.normal);
                hitParts.Emit(UnityEngine.Random.Range(2, 5));
                hitSound.Play();
            }

            // 效果
            PlayShotEffectAt(hitPoint);

            return true;
        }
        public void PlayShotEffectAt(Vector3 hitPoint)
        {
            ammoParts.Emit(1);
            model.Translate(Vector3.back * forceBackward, Space.Self);
            shotParts.Emit(UnityEngine.Random.Range(shotPartsEmitRange.x, shotPartsEmitRange.y));
            shotSound.Play();
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
            reloadSound.Play();
            reloadCoroutine = StartCoroutine(RunReload(reloadTime));
        }

        Coroutine reloadCoroutine;
        public bool IsReloading => reloadCoroutine != null;
        IEnumerator RunReload(float reloadTime)
        {
            yield return new WaitForSeconds(reloadTime);
            reloadedSound.Play();
            yield return new WaitForSeconds(reloadEndTime);
            OnReloaded();
            reloadCoroutine = null;
        }
        protected virtual void OnReloaded()
        {
            if (infiniteAmmo)
            {
                slot.SetAmmo(ammo = maxAmmo);
            }
            else
            {
                var ammoOffset = Mathf.Min(mag, maxAmmo - ammo);
                slot.SetAmmo(ammo += ammoOffset);
                mag -= ammoOffset;
            }
        }
    }
}
