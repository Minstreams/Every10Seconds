using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using static Ice.Gameplay;

namespace IceEngine
{
    /// <summary>
    /// 关内Manager
    /// </summary>
    public class LevelManager : MonoBehaviour
    {
        public Player Player => Ice.Gameplay.Player;
        public UICanvasManager UIMgr => Ice.Gameplay.UIMgr;
        IceEngine.Internal.SettingGameplay Setting => Ice.Gameplay.Setting;

        public Light sun;
        public AnimationCurve intensityCurve;

        void Awake()
        {
            CurLevel = this;
        }
        void Start()
        {
            // 清除上一局状态
            Pickable.toPickList.Clear();

            // 初始化战斗UI
            UIMgr.OpenEye();
            UIMgr.SetBattleUI(true);

            // 玩家生成
            var sp = FindObjectOfType<SpawnPoint>();
            var pos = sp != null ? sp.transform.position : Vector3.zero;
            Player.SpawnAt(pos);
            Player.SwitchToWeaponBasic();

            // 保存数据
            Ice.Gameplay.SaveData();

            StartCoroutine(RunInLevel());
        }
        IEnumerator RunInLevel()
        {
            // Day
            CurTime = 0;
            while (true)
            {
                onMorning?.Invoke();
                isMorning = true;
                while (CurTime < 10)
                {
                    CurTime += Time.deltaTime;
                    var t = CurTime * 0.1f;
                    sun.transform.rotation = Quaternion.Euler(t * 180, 0, 0);
                    sun.intensity = intensityCurve.Evaluate(t);
                    yield return 0;
                }

                onEvening?.Invoke();
                isMorning = false;
                while (CurTime < 20)
                {
                    CurTime += Time.deltaTime;
                    var t = CurTime * 0.1f;
                    sun.transform.rotation = Quaternion.Euler(t * 180, 0, 0);
                    yield return 0;
                }
                CurTime -= 20;

                Data.days++;
            }
        }

        #region EnemyPool
        public int enemyPoolCapacity;
        Dictionary<GameObject, Queue<Enemy>> enemyPoolMap = new();
        public Enemy GetEnemyAt(GameObject prefab, Vector3 position, Quaternion rotation)
        {
            // Get Pool
            if (!enemyPoolMap.TryGetValue(prefab, out var pool))
            {
                enemyPoolMap.Add(prefab, pool = new Queue<Enemy>());
            }
            Enemy e;
            if (pool.Count >= enemyPoolCapacity) e = pool.Dequeue();
            else e = GameObject.Instantiate(prefab, position, rotation).GetComponent<Enemy>();
            pool.Enqueue(e);
            return e;
        }
        #endregion

        #region Loot
        [NonSerialized] public int coin = 0;

        public void AddCoin(int c)
        {
            coin += c;
            UIMgr.UpdateLootCoin();
        }
        public string GetStatisticText()
        {
            string res = "You've\n" +
                (Data.coinAll > 0 ? $"earned {Data.coinAll} {Setting.coinMark}\n" : "") +
               (Data.ammos > 0 ? $"shot {Data.ammos} bullets\n" : "") +
               (Data.enemiesBeaten > 0 ? $"beaten {Data.enemiesBeaten} dead walks\n" : "") +
                $"lived through {Data.days} days";
            return res;
        }
        public string GetLootText()
        {
            string res = (coin > 0 ? $"You've earned {coin} {Setting.coinMark}\n" : "");
            return res;
        }
        #endregion

        string sleepText = "";
        public void OnDroneEnterShelter()
        {
            // 结算
            UIMgr.ShowNotification($"You drone has brought your {coin} {Setting.coinMark} " +
                $"to basement");
            Data.coin += coin;
            Data.coinAll += coin;
            coin = 0;

            UIMgr.UpdateLootCoin();
        }
        public void EnterShelter()
        {
            // 结算
            sleepText = GetLootText();

            Data.coin += coin;
            Data.coinAll += coin;
            coin = 0;

            UIMgr.OpenShelterUI();
        }
        public void ExitShelter()
        {
            UIMgr.CloseShelterUI();
        }
        public void Sleep()
        {
            UIMgr.CloseEye(sleepText);
        }

        public void Die()
        {
            // 清空统计数据
            var text = GetStatisticText();
            Data.id++;
            Data.coinAll = 0;
            Data.ammos = 0;
            Data.enemiesBeaten = 0;
            Data.days = 0;

            UIMgr.CloseEye(text + $"\nnext seeker will follow your way." + $"\nRest in peace...");
        }
    }
}
