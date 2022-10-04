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
            slotMain.OnClick(() =>
            {
                Player.SwitchToWeaponMain();
            });
            slotBasic.OnClick(() =>
            {
                Player.SwitchToWeaponBasic();
            });
            slotItem.OnClick(() =>
            {
                Player.SwitchToItem();
            });
            CloseDialog();
        }
        public void OnSwitchSlot(int index)
        {
            switch (index)
            {
                case 1:
                    slotMain.Select();
                    break;
                case 2:
                    slotBasic.Select();
                    break;
                case 3:
                    slotItem.Select();
                    break;
                case 4:
                    slotGrenade.Select();
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

        #region Dialog
        public const float choiceHeight = 128 + 16;

        public GameObject choicePrefab;
        public GameObject dialogObj;
        public Text npcName;
        public RectTransform choiceRect;
        public Text npcContent;
        readonly List<UIDialogChoice> choices = new();
        public void SetDialogNPC(string name)
        {
            npcName.text = name;
        }
        public void DisplayDialogBlock(DialogBlock block)
        {
            dialogObj.SetActive(true);

            // Load Choices
            foreach (var c in choices)
            {
                Destroy(c.gameObject);
            }
            choices.Clear();

            npcContent.text = block.content;
            var cs = block.dialogChoices;
            var size = choiceRect.sizeDelta;
            size.y = choiceHeight * cs.Count;
            choiceRect.sizeDelta = size;
            for (int i = 0; i < cs.Count; i++)
            {
                var c = GameObject.Instantiate(choicePrefab, choiceRect).GetComponent<UIDialogChoice>();
                var anchorY = (i + 1.0f) / (cs.Count + 1);
                c.rect.anchorMin = new Vector2(0, anchorY);
                c.rect.anchorMax = new Vector2(1, anchorY);
                c.SetText(cs[i].content);
                var cc = cs[i];
                c.btn.onClick.AddListener(() =>
                {
                    Ice.Gameplay.ToDialogBlock(cc.nextId);
                    cc.action?.Invoke();
                });
                choices.Add(c);
            }
        }
        public void CloseDialog()
        {
            dialogObj.SetActive(false);
            foreach (var c in choices)
            {
                Destroy(c.gameObject);
            }
            choices.Clear();
        }
        #endregion

        #region Black
        public Image black;
        public AnimationCurve openEyeCurve;
        public float openEyeTime;
        public AnimationCurve closeEyeCurve;
        public float closeEyeTime;

        [Button]
        public void OpenEye()
        {
            StartCoroutine(RunOpenEye());
        }
        IEnumerator RunOpenEye()
        {
            float t = 0;
            while (t < 1)
            {
                black.color = new Color(0, 0, 0, openEyeCurve.Evaluate(t));
                yield return 0;
                t += Time.deltaTime / openEyeTime;
            }
        }
        [Button]
        public void CloseEye()
        {
            StartCoroutine(RunCloseEye());
        }
        IEnumerator RunCloseEye()
        {
            float t = 0;
            while (t < 1)
            {
                black.color = new Color(0, 0, 0, closeEyeCurve.Evaluate(t));
                yield return 0;
                t += Time.deltaTime / closeEyeTime;
            }
            // EyeClosed, Restart
            UnityEngine.SceneManagement.SceneManager.LoadScene(0);
        }
        #endregion
    }
}