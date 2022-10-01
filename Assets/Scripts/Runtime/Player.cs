using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    [RequireComponent(typeof(WeaponEmpty))]
    public class Player : CharacterBase
    {
        protected override void Awake()
        {
            base.Awake();
            DontDestroyOnLoad(gameObject);
            weaponEmpty = GetComponent<WeaponEmpty>();
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
        public override Weapon CurrentWeapon => weaponEmpty;
        WeaponEmpty weaponEmpty;
        public Weapon weaponBasic;
        public Weapon weaponMain;

        Vector3 aimTarget = Vector3.zero;
        public override Vector3 TargetLook => aimTarget;
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
        }
    }
}
