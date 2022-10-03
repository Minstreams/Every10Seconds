using System.Collections;
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
        WeaponBasic weaponBasic;
        Handable weaponMain;

        Vector3 aimTarget = Vector3.zero;
        public override Vector3 TargetLook => aimTarget;

        public void SwitchTo(Handable h)
        {
            if (h == null) h = handEmpty;
            if (currentInHand == h) return;
            if (currentInHand != handEmpty)
            {
                if (currentInHand is WeaponBasic wb)
                {
                    wb.transform.SetParent(posWeaponBasic, false);
                }
            }
            if (h != handEmpty) h.transform.SetParent(posHand, false);
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
        public void PickWeaponBasic(PickableBasic p)
        {
            DropWeaponBasic();
            weaponBasic = GameObject.Instantiate(p.prefab).GetComponent<WeaponBasic>();
            weaponBasic.owner = this;
            weaponBasic.OnPick(p);
            SwitchToWeaponBasic();
        }
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
        #endregion

        void Update()
        {
            Shader.SetGlobalVector("_PlayerPosition", transform.position);

            var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
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
            if (Input.GetMouseButtonDown(0))
            {
                CurrentInHand.OnUse();
            }
            if (Input.GetMouseButtonUp(0))
            {
                CurrentInHand.OnEndUse();
            }
            if (Input.GetKeyDown(KeyCode.R))
            {
                CurrentInHand.OnReload();
            }
        }
    }
}
