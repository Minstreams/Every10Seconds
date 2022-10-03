﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    [RequireComponent(typeof(HandEmpty))]
    public class Player : CharacterBase
    {
        protected override void Awake()
        {
            base.Awake();
            DontDestroyOnLoad(gameObject);
            handEmpty = GetComponent<HandEmpty>();
            currentInHand = handEmpty;
            cha = GetComponent<CharacterController>();
        }

        #region Life
        public override void SpawnAt(Vector3 pos)
        {
            base.SpawnAt(pos);
            hp = maxHp;
        }
        public override void Harm(float harm, Vector3 push)
        {
            base.Harm(harm, push);
            cha.Move(push);
        }
        #endregion

        #region Move
        [Header("移动参数")]
        public float baseSpeed = 2;
        public float gravity = 9.8f;
        CharacterController cha;
        #endregion

        #region Weapon
        [Header("武器参数")]
        public Transform posHand;
        public Transform posWeaponBasic;
        public Transform posWeaponMain;
        public Transform posGrenade;
        public Transform posItem;
        public LayerMask aimMask;

        HandEmpty handEmpty;
        public override Handable CurrentInHand => currentInHand;

        Handable currentInHand;
        Weapon weaponBasic;
        Weapon weaponMain;
        Handable item;

        Vector3 aimTarget = Vector3.zero;
        public override Vector3 TargetLook => aimTarget;

        public void SwitchTo(Handable h)
        {
            if (h == null) h = handEmpty;
            if (currentInHand == h) return;
            if (currentInHand != handEmpty)
            {
                if (currentInHand == weaponBasic)
                {
                    currentInHand.transform.SetParent(posWeaponBasic, false);
                }
                else if (currentInHand == weaponMain)
                {
                    currentInHand.transform.SetParent(posWeaponMain, false);
                }
                else if (currentInHand == item)
                {
                    currentInHand.transform.SetParent(posItem, false);
                }

                currentInHand.OnSwitchOff();
            }
            if (h != handEmpty)
            {
                h.transform.SetParent(posHand, false);
                h.OnSwitchOn();
            }
            currentInHand = h;
        }
        public void Drop(Handable h)
        {
            if (h == null) return;
            Vector3 dropPos = posHand.position;
            if (Physics.Raycast(dropPos, Vector3.down, out RaycastHit hit, 100, 1 << LayerMask.NameToLayer("Ground")))
            {
                dropPos = hit.point;
            }
            GameObject.Instantiate(h.pickablePrefab, dropPos, Quaternion.identity);
            Destroy(h);
        }

        public void PickWeaponGun(PickableGun p)
        {
            var weapon = GameObject.Instantiate(p.prefab).GetComponent<Weapon>();
            weapon.owner = this;
            weapon.OnPick(p);
            if (p.type == WeaponSlotType.Basic)
            {
                DropWeaponBasic();
                weaponBasic = weapon;
                SwitchToWeaponBasic();
            }
            else if (p.type == WeaponSlotType.Main)
            {
                DropWeaponMain();
                weaponMain = weapon;
                SwitchToWeaponMain();
            }
        }
        // Main
        public void SwitchToWeaponMain()
        {
            SwitchTo(weaponMain);
            Ice.Gameplay.UIMgr.OnSwitchSlot(1);
        }
        public void DropWeaponMain()
        {
            Drop(weaponMain);
            weaponMain = null;
        }
        // Basic
        public void SwitchToWeaponBasic()
        {
            SwitchTo(weaponBasic);
            Ice.Gameplay.UIMgr.OnSwitchSlot(2);
        }
        public void DropWeaponBasic()
        {
            Drop(weaponBasic);
            weaponBasic = null;
        }
        // Item
        public void SwitchToItem()
        {
            SwitchTo(item);
            Ice.Gameplay.UIMgr.OnSwitchSlot(3);
        }
        public void DropItem()
        {
            Drop(item);
            item = null;
        }
        #endregion

        void Update()
        {
            Shader.SetGlobalVector("_PlayerPosition", transform.position);

            var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            Debug.DrawRay(ray.origin, ray.direction * 100);
            if (Physics.Raycast(ray, out var raycastHit, 100, aimMask))
            {
                if (raycastHit.collider.CompareTag("Enemy"))
                {
                    aimTarget = raycastHit.collider.bounds.center;
                }
                else
                {
                    aimTarget = raycastHit.point;
                }
            }
            else
            {
                aimTarget = ray.origin - ray.direction / ray.direction.y * ray.origin.y;
            }
            Vector3 sightDir = (aimTarget - transform.position).normalized;
            Vector3 forward = sightDir;
            float h = Input.GetAxis("Horizontal");
            float v = Input.GetAxis("Vertical");
            float speed = 0;
            if (h != 0 || v != 0)
            {
                forward = (Camera.main.transform.right * h + Vector3.Cross(Camera.main.transform.right, Vector3.up) * v).normalized;    //目标前进方向归一化向量
                float hh = h * h;
                float vv = v * v;
                speed = (hh + vv) / (1 + (hh > vv ? vv / hh : hh / vv));    //速度的平方
            }
            speed *= baseSpeed;
            var vec = forward * speed;
            var curY = cha.velocity.y;
            if (curY <= 0) vec.y = curY - Time.deltaTime * gravity;
            cha.Move(vec * Time.deltaTime);
            Move(forward, speed, sightDir);

            // Weapon
            CurrentInHand.OnUpdate();
            if (Input.GetKeyDown(KeyCode.R))
            {
                CurrentInHand.OnReload();
            }
        }
        public void Shoot()
        {
            CurrentInHand.OnUse();
        }
        public void ReleaseShoot()
        {
            CurrentInHand.OnEndUse();
        }
    }
}