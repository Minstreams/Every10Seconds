using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IceEngine
{
    public class UICanvasManager : MonoBehaviour
    {
        void Awake()
        {
            DontDestroyOnLoad(gameObject);
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
        public RectTransform slotMain;
        public RectTransform slotBasic;
        public RectTransform slotGrenade;
        public RectTransform slotItem;
        public Text hintText;

        public void SetBattleUI(bool on)
        {
            battleUIRoot.SetActive(on);
            if (on)
            {

                hintText.text = "";
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
                yield return 0;
            }
        }
        #endregion
    }
}