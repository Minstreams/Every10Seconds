using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class WeaponGun : Weapon
    {
        [Group("效果")]
        public AudioSource shotSound;
        public ParticleSystem shotParts;
        public ParticleSystem ammoParts;
        public Vector2Int shotPartsEmitRange = new Vector2Int(2, 5);

        public AudioSource hitSound;
        public ParticleSystem hitParts;

        public LineRenderer lineRenderer;
        public Color lineColor;
        public float lineLifeTime = 0.2f;
        public virtual int LineCount => 1;

        public Transform gunPoint;

        public Transform model;
        public float forceBackward = 0.1f;
        public float forceReboundRate = 0.1f;

        [Group("属性")]
        public float maxDis = 100;
        public int maxAmmo = 15;
        public float harm = 20;
        public float push = 1;
        public LayerMask shotLayerMask;
        public int maxMag = 30;
        public bool infiniteAmmo;
        public float accurate = 0;
        public bool goThroughEnemies;

        [Group("UI")]
        public GameObject slotPrefab;
        public Transform aimMark;

        [Group("装弹")]
        public AudioSource reloadSound;
        public AudioSource reloadedSound;
        public AudioSource emptySound;
        public float reloadTime;
        public float reloadEndTime;

        [NonSerialized] public int ammo;
        [NonSerialized] public int mag;
        [NonSerialized] public SlotGun slot;
        [NonSerialized] public List<LineRenderer> lineList = new();
        [NonSerialized] public List<Coroutine> lineCorList = new();

        void Awake()
        {
            lineList.Add(lineRenderer);
            lineCorList.Add(null);
            for (int i = 1; i < LineCount; ++i)
            {
                lineList.Add(GameObject.Instantiate(lineRenderer, transform));
                lineCorList.Add(null);
            }
        }
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
        public override void OnDrop()
        {
            var uiSlot = weaponType switch
            {
                WeaponSlotType.Basic => Ice.Gameplay.UIMgr.slotBasic,
                WeaponSlotType.Main => Ice.Gameplay.UIMgr.slotMain,
                _ => Ice.Gameplay.UIMgr.slotBasic,
            };
            uiSlot.Unload();
        }

        public override void OnSwitchOn()
        {
            reloadedSound.Play();
            aimMark.gameObject.SetActive(true);
        }
        public override void OnSwitchOff()
        {
            aimMark.gameObject.SetActive(false);
            CancelReload();
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

            var rDisc = UnityEngine.Random.insideUnitCircle * accurate;
            Vector3 ammoDir = ((AimPos - gunPoint.position).normalized + new Vector3(rDisc.x, 0, rDisc.y)).normalized;
            Vector3 hitPoint = gunPoint.position + ammoDir * maxDis;
            bool OnHit(RaycastHit hit)
            {
                hitPoint = hit.point;
                // Hit Effects
                hitParts.transform.position = hitPoint;
                hitParts.transform.rotation = Quaternion.LookRotation(hit.normal);
                hitParts.Emit(UnityEngine.Random.Range(1, 4));
                hitSound.Play();

                if (hit.rigidbody != null)
                {
                    hit.rigidbody.AddForce(15 * push * ammoDir, ForceMode.Impulse);
                }

                if (hit.collider.gameObject.layer == Setting.LayerEnemy)
                {
                    var e = hit.collider.GetComponentInParent<Enemy>();
                    e.Harm(harm, ammoDir * push);
                    Ice.Gameplay.Data.ammos++;
                    return true;
                }
                return false;
            }
            if (goThroughEnemies)
            {
                var hits = Physics.RaycastAll(gunPoint.position, ammoDir, maxDis, shotLayerMask);
                foreach (var hit in hits) if (!OnHit(hit)) break;
            }
            else
            {
                if (Physics.Raycast(gunPoint.position, ammoDir, out var hit, maxDis, shotLayerMask)) OnHit(hit);
            }


            // 效果
            PlayShotEffectAt(hitPoint);
            Ice.Gameplay.CamMgr.AddPulse(ammoDir * forceBackward);

            return true;
        }
        int lineId = 0;
        public void PlayShotEffectAt(Vector3 hitPoint)
        {
            ammoParts.Emit(1);
            model.Translate(Vector3.back * forceBackward, Space.Self);
            shotParts.Emit(UnityEngine.Random.Range(shotPartsEmitRange.x, shotPartsEmitRange.y));
            shotSound.Play();
            if (++lineId >= LineCount) lineId = 0;
            var lineCoroutine = lineCorList[lineId];
            if (lineCoroutine != null)
            {
                StopCoroutine(lineCoroutine);
            }
            lineCorList[lineId] = StartCoroutine(lineFade(lineList[lineId], hitPoint));
        }
        IEnumerator lineFade(LineRenderer lineRenderer, Vector3 hitPoint)
        {
            lineRenderer.SetPosition(0, gunPoint.position);
            lineRenderer.SetPosition(1, hitPoint);
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
        public void CancelReload()
        {
            if (IsReloading)
            {
                StopCoroutine(reloadCoroutine);
                reloadCoroutine = null;
            }
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
                slot.SetMag(mag -= ammoOffset);
            }
        }
    }
}
