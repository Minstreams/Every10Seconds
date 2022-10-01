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
        }

        public void SpawnAt(Vector3 pos)
        {
            transform.position = pos;
        }
        #region Move
        [Header("移动参数")]
        public float baseSpeed = 2;
        #endregion

        #region Weapon
        public Transform posHand;
        public Transform posWeaponBasic;
        public Transform posWeaponMain;
        public Transform posGrenade;
        public Transform posItem;

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
            if (Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out var raycastHit, 100, -1))
            {
                aimTarget = raycastHit.point;
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
            transform.position += forward * speed * Time.deltaTime;
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
