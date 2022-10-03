using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IceEngine
{
    public class UICanvasManager : MonoBehaviour
    {
        Player Player => Ice.Gameplay.Player;

        void Awake()
        {
            DontDestroyOnLoad(gameObject);
            Awake_Battle();
        }

        #region Notification
        [Header("Notification")]
        public RectTransform notification;
        public Text notificationText;
        public AnimationCurve notificationyCurve;
        [Range(0.1f, 10f)]
        public float notificationTime = 1;

        public void ShowNotification(string msg)
        {
            if (rNotification != null)
            {
                StopCoroutine(rNotification);
                rNotification = null;
            }
            rNotification = StartCoroutine(RunShowNotification(msg));
            Debug.Log("Notification: " + msg);
        }

        Coroutine rNotification;
        IEnumerator RunShowNotification(string msg)
        {
            notificationText.text = msg;
            float t = 0;
            while (t < 1)
            {
                yield return 0;
                t += Time.deltaTime / notificationTime;
                notification.anchoredPosition = new Vector2(0, notificationyCurve.Evaluate(t));
            }
            notification.anchoredPosition = Vector2.zero;
        }
        #endregion

        #region Battle
        [Header("Battle")]
        public GameObject battleUIRoot;
        public Slot slotMain;
        public Slot slotBasic;
        public Slot slotGrenade;
        public Slot slotItem;
        public Text hintText;
        public RectTransform hpBarRect;
        public RectTransform hpBar;

        void Awake_Battle()
        {
            slotBasic.OnClick(() =>
            {
                Player.SwitchToWeaponBasic();
            });
        }
        public void OnSwitchSlot(int index)
        {
            switch (index)
            {
                case 2:
                    slotBasic.Select();
                    break;
            }
        }
        public void SetBattleUI(bool on)
        {
            battleUIRoot.SetActive(on);
            if (on)
            {
                hintText.text = "";
                hpBarRect.sizeDelta = new Vector2(Player.maxHp / 100 * 128, 32);
                rBattleUpdate = StartCoroutine(RunBattleUpdate());
            }
            else
            {
                if (rBattleUpdate != null)
                {
                    StopCoroutine(rBattleUpdate);
                    rBattleUpdate = null;
                }
            }
        }
        Coroutine rBattleUpdate;
        IEnumerator RunBattleUpdate()
        {
            while (true)
            {
                Pickable.OnBattleUpdate();
                hpBar.anchorMin = new Vector2(1 - Player.hp / Player.maxHp, 0);
                yield return 0;
            }
        }
        #endregion
    }
}