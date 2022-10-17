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
        void Update()
        {
            if (isDead) return;
            Shader.SetGlobalVector("_PlayerPosition", transform.position);

            var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            Debug.DrawRay(ray.origin, ray.direction * 100);
            int mask = CurrentInHand.aimEnemy ? Setting.maskPlayerAim | (1 << Setting.LayerEnemyAimBox) : Setting.maskPlayerAim;
            if (Physics.Raycast(ray, out var raycastHit, 100, mask))
            {
                if (CurrentInHand.aimEnemy && raycastHit.collider.CompareTag("Enemy"))
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
            if (Input.GetKeyDown(KeyCode.Alpha1))
            {
                SwitchToWeaponMain();
            }
            if (Input.GetKeyDown(KeyCode.Alpha2))
            {
                SwitchToWeaponBasic();
            }
            if (Input.GetKeyDown(KeyCode.Alpha3))
            {
                SwitchToItem();
            }
            if (Input.GetKeyDown(KeyCode.Alpha4))
            {
                SwitchToGrenade();
            }
        }

        #region Life
        public override void SpawnAt(Vector3 pos)
        {
            base.SpawnAt(pos);
            hp = maxHp;
            cha.enabled = true;
        }
        public override void Harm(float harm, Vector3 push)
        {
            base.Harm(harm, push);
            if (isDead) return;
            cha.Move(push);
        }
        public override void Die(Vector3 push)
        {
            if (isDead) return;
            base.Die(push);
            Ice.Gameplay.CurLevel.Die();
            DropItem();
            DropWeaponBasic();
            DropWeaponMain();
            cha.enabled = false;
            StopAllCoroutines();
        }
        public void Sleep()
        {
            if (isDead) return;
            base.Die(Vector3.zero);
            DropItem();
            DropWeaponBasic();
            DropWeaponMain();
            Ice.Gameplay.CurLevel.Sleep();
            cha.enabled = false;
            StopAllCoroutines();
        }
        #endregion

        #region Move
        [Group("移动参数")]
        public float baseSpeed = 2;
        public float gravity = 9.8f;
        CharacterController cha;
        #endregion

        #region Weapon
        [Group("武器道具")]
        public Transform posHand;

        #region Utility
        HandEmpty handEmpty;
        public override Handable CurrentInHand => currentInHand;
        Handable currentInHand;
        public override Vector3 TargetLook => aimTarget;
        Vector3 aimTarget = Vector3.zero;

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
                else
                {
                    // grenade
                    var g = currentInHand as Grenade;
                    g.transform.SetParent(posGrenadeList[g.ID], false);
                }
                currentInHand.transform.localRotation = Quaternion.identity;

                currentInHand.OnSwitchOff();
            }
            if (h != handEmpty)
            {
                h.transform.SetParent(posHand, false);
                h.OnSwitchOn();
            }
            currentInHand = h;
        }
        Handable Pick(Pickable p)
        {
            var h = Instantiate(p.prefab).GetComponent<Handable>();
            h.owner = this;
            h.OnPick(p, h.GetSlot().Load(h.slotPrefab).GetComponent<SlotBase>());
            return h;
        }
        public void Drop(Handable h, bool generatePickable = true)
        {
            if (h == null) return;
            Pickable p = null;
            if (generatePickable)
            {
                Vector3 dropPos = posHand.position;
                if (Physics.Raycast(dropPos, Vector3.down, out RaycastHit hit, 100, 1 << Setting.LayerGround))
                {
                    dropPos = hit.point;
                }
                p = GameObject.Instantiate(h.pickablePrefab, dropPos, Quaternion.identity).GetComponent<Pickable>();
            }
            var slot = h.GetSlot();
            if (slot != null) slot.Unload();
            h.OnDrop(p);
            Destroy(h.gameObject);
        }
        public void UseCurrent()
        {
            if (isDead) return;
            CurrentInHand.OnUse();
        }
        public void ReleaseCurrent()
        {
            CurrentInHand.OnRelease();
        }
        #endregion

        #region Weapon
        public Transform posWeaponBasic;
        public Transform posWeaponMain;

        Weapon weaponBasic;
        Weapon weaponMain;

        public void PickWeaponGun(PickableGun p)
        {
            if (isDead) return;

            if (p.type == WeaponSlotType.Basic)
            {
                DropWeaponBasic(!p.replaceCurrentDirrectly);
                weaponBasic = Pick(p) as Weapon;
                SwitchToWeaponBasic();
            }
            else if (p.type == WeaponSlotType.Main)
            {
                DropWeaponMain(!p.replaceCurrentDirrectly);
                weaponMain = Pick(p) as Weapon;
                SwitchToWeaponMain();
            }
        }
        // Main
        public void SwitchToWeaponMain()
        {
            SwitchTo(weaponMain);
            Ice.Gameplay.UIMgr.OnSwitchSlot(1);
        }
        public void DropWeaponMain(bool generatePickable = true)
        {
            if (currentInHand == weaponMain) currentInHand = handEmpty;
            Drop(weaponMain, generatePickable);
            weaponMain = null;
        }
        // Basic
        public void SwitchToWeaponBasic()
        {
            SwitchTo(weaponBasic);
            Ice.Gameplay.UIMgr.OnSwitchSlot(2);
        }
        public void DropWeaponBasic(bool generatePickable = true)
        {
            if (currentInHand == weaponBasic) currentInHand = handEmpty;
            Drop(weaponBasic, generatePickable);
            weaponBasic = null;
        }
        #endregion

        #region Item
        public Transform posItem;

        Item item;

        public void PickItem(PickableItem p)
        {
            if (isDead) return;

            DropItem(!p.replaceCurrentDirrectly);
            item = Pick(p) as Item;
            SwitchToItem();
        }
        public void SwitchToItem()
        {
            SwitchTo(item);
            Ice.Gameplay.UIMgr.OnSwitchSlot(3);
        }
        public void DropItem(bool generatePickable = true)
        {
            if (currentInHand == item) currentInHand = handEmpty;
            Drop(item, generatePickable);
            item = null;
        }
        #endregion

        #region Grenade
        [Header("Grenade")]
        public List<Transform> posGrenadeList;
        public int grenadeCount = 2;

        List<Grenade> grenadeList = new();

        void PlaceAllGrenades()
        {
            foreach (var g in grenadeList) g.GetSlot().Unload();
            for (int i = 0; i < grenadeList.Count; ++i)
            {
                var g = grenadeList[i];
                g.ID = i;
                g.OnPlacedInSlot(g.GetSlot().Load(g.slotPrefab).GetComponent<SlotItem>());
                g.transform.SetParent(posGrenadeList[g.ID], false);
                g.OnSwitchOff();
            }
        }
        public void PickGrenade(PickableGrenade p)
        {
            if (isDead) return;
            if (grenadeList.Count >= grenadeCount) DropLastGrenade(!p.replaceCurrentDirrectly);

            var g = Instantiate(p.prefab).GetComponent<Grenade>();
            g.owner = this;
            g.ID = grenadeList.Count;
            g.OnPick(p, g.GetSlot().Load(g.slotPrefab).GetComponent<SlotBase>());
            grenadeList.Add(g);
            g.transform.SetParent(posGrenadeList[g.ID], false);
            if (CurrentInHand == handEmpty || CurrentInHand is Grenade) SwitchToGrenade();
        }
        public void SwitchToGrenade()
        {
            SwitchTo(grenadeList.Count == 0 ? null : grenadeList[^1]);
            Ice.Gameplay.UIMgr.OnSwitchSlot(4);
        }
        public void DropGrenade(bool generatePickable = true)
        {
            if (grenadeList.Count == 0) return;

            var g = grenadeList[^1];
            bool holding = g == CurrentInHand;
            Drop(g, generatePickable);
            grenadeList.RemoveAt(grenadeList.Count - 1);

            if (holding)
            {
                if (grenadeList.Count == 0)
                    if (weaponMain != null)
                        SwitchToWeaponMain();
                    else SwitchToWeaponBasic();
                else SwitchToGrenade();
            }
        }
        public void DropLastGrenade(bool generatePickable = true)
        {
            if (grenadeList.Count == 0) return;
            Drop(grenadeList[0], generatePickable);
            grenadeList.RemoveAt(0);
            PlaceAllGrenades();
        }
        public void ThrowGrenade()
        {
            if (isDead) return;
            if (grenadeList.Count > 0)
                grenadeList[^1].OnUse();
        }
        #endregion

        #endregion

        #region Effects
        [Group("特效")]
        public ParticleSystem coinEmitter;
        const float coinDelayTime = 1.5f;
        readonly WaitForSeconds coinDelay = new(coinDelayTime);
        public void AddCoin(int coin, Vector3 pos)
        {
            if (isDead) return;
            coinEmitter.transform.position = pos;
            coinEmitter.Emit(coin);
            StartCoroutine(RunAddCoin(coin));
        }
        IEnumerator RunAddCoin(int coin)
        {
            yield return coinDelay;
            Ice.Gameplay.CurLevel.AddCoin(coin);
        }
        #endregion


    }
}
