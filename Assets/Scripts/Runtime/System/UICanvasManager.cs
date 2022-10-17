using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IceEngine
{
    public class UICanvasManager : MonoBehaviour
    {
        Player Player => Ice.Gameplay.Player;
        public static Internal.SettingGameplay Setting => Ice.Gameplay.Setting;
        Ice.Gameplay.PlayerData Data => Ice.Gameplay.Data;

        void Awake()
        {
            DontDestroyOnLoad(gameObject);
            Awake_Battle();
        }

        #region Notification
        [Group("Notification")]
        public RectTransform notification;
        public Text notificationText;
        public AnimationCurve notificationyCurve;
        [Range(0.1f, 10f)]
        public float notificationTime = 1;

        Queue<string> notificationQueue = new();
        public void ShowNotification(string msg)
        {
            if (rNotification != null)
            {
                notificationQueue.Enqueue(msg);
            }
            else
            {
                rNotification = StartCoroutine(RunShowNotification(msg));
            }
        }

        Coroutine rNotification;
        IEnumerator RunShowNotification(string msg)
        {
            Debug.Log("Notification: " + msg);

            notificationText.text = msg;
            float t = 0;
            while (t < 1)
            {
                yield return 0;
                t += Time.deltaTime / notificationTime;
                notification.anchoredPosition = new Vector2(0, notificationyCurve.Evaluate(t));
            }
            notification.anchoredPosition = Vector2.zero;

            if (notificationQueue.Count > 0) rNotification = StartCoroutine(RunShowNotification(notificationQueue.Dequeue()));
            else rNotification = null;
        }
        #endregion

        #region Battle
        [Group("Battle")]
        public GameObject battleUIRoot;
        public Slot slotMain;
        public Slot slotBasic;
        public Slot slotItem;
        public Slot slotGrenadeRect;
        public List<Slot> slotGrenadeList = new();
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
            slotGrenadeRect.OnClick(() =>
            {
                Player.SwitchToGrenade();
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
                    slotGrenadeRect.Select();
                    break;
            }
        }
        public void SetBattleUI(bool on)
        {
            battleUIRoot.SetActive(on);
            if (rBattleUpdate != null)
            {
                StopCoroutine(rBattleUpdate);
                rBattleUpdate = null;
            }
            if (on)
            {
                hintText.text = "";
                hpBarRect.sizeDelta = new Vector2(Player.maxHp / 100 * 128, 32);
                rBattleUpdate = StartCoroutine(RunBattleUpdate());
            }
        }
        Coroutine rBattleUpdate;
        IEnumerator RunBattleUpdate()
        {
            while (true)
            {
                Interactable.OnBattleUpdate();
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
                    Ice.Gameplay.DoNPCAction(cc.npcAction);
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
        public Text blackText;
        public AnimationCurve openEyeCurve;
        public float openEyeTime;
        public AnimationCurve closeEyeCurve;
        public float closeEyeTime;

        Coroutine openEyeRoutine;
        [Button]
        public void OpenEye()
        {
            if (openEyeRoutine != null) StopCoroutine(openEyeRoutine);
            openEyeRoutine = StartCoroutine(RunOpenEye());
        }
        IEnumerator RunOpenEye()
        {
            blackText.text = "";
            float t = 0;
            while (t < 1)
            {
                black.color = new Color(0, 0, 0, openEyeCurve.Evaluate(t));
                yield return 0;
                t += Time.deltaTime / openEyeTime;
            }
            openEyeRoutine = null;
        }
        Coroutine closeEyeRoutine;
        [Button]
        public void CloseEye(string note)
        {
            if (openEyeRoutine != null)
            {
                StopCoroutine(openEyeRoutine);
                openEyeRoutine = null;
            }
            if (closeEyeRoutine != null) return;
            closeEyeRoutine = StartCoroutine(RunCloseEye(note));
        }
        IEnumerator RunCloseEye(string note)
        {
            blackText.text = note;
            float t = 0;
            while (t < 1)
            {
                black.color = new Color(0, 0, 0, closeEyeCurve.Evaluate(t));
                yield return 0;
                t += Time.deltaTime / closeEyeTime;
            }
            // EyeClosed, Restart
            UnityEngine.SceneManagement.SceneManager.LoadScene(0);
            closeEyeRoutine = null;
        }
        #endregion

        #region Shelter
        [Group("Shelter")]
        public GameObject shelterUIObj;
        public GameObject lootUIObj;
        public Text coinText;
        public Text lootCoinText;
        public AudioSource coinJumpSound;
        public float coinJumpRate = 0.05f;
        public Color jumpColor = Color.white;

        public string GetCoinText(int coin, string mark) => coin == 0 ? "" : $"{coin} {mark}";



        public void OpenShelterUI()
        {
            lootUIObj.SetActive(false);
            if (rLootUpdate != null)
            {
                StopCoroutine(rLootUpdate);
                rLootUpdate = null;
            }

            shelterUIObj.SetActive(true);
            UpdateCoin();
            coinText.text = GetCoinText(lastCoin, Setting.coinMark);

            if (rShelterUpdate != null)
            {
                StopCoroutine(rShelterUpdate);
                rShelterUpdate = null;
            }
            rShelterUpdate = StartCoroutine(RunShelterUpdate());
        }
        public void CloseShelterUI()
        {
            shelterUIObj.SetActive(false);
            if (rShelterUpdate != null)
            {
                StopCoroutine(rShelterUpdate);
                rShelterUpdate = null;
            }

            lootCoin = lastLootCoin = 0;
            lootUIObj.SetActive(true);
            UpdateLootCoin();
            lootCoinText.text = GetCoinText(lastLootCoin, Setting.coinMark);

            if (rLootUpdate != null)
            {
                StopCoroutine(rLootUpdate);
                rLootUpdate = null;
            }
            rLootUpdate = StartCoroutine(RunLootUpdate());
        }
        public void UpdateCoin()
        {
            coinTarget = Data.coin;
        }

        public void UpdateLootCoin()
        {
            lootCoinTarget = Ice.Gameplay.CurLevel.coin;
        }

        float coinTarget = 0;
        float coin = 0;
        int lastCoin = 0;

        Coroutine rShelterUpdate;
        IEnumerator RunShelterUpdate()
        {
            while (true)
            {
                coin += (coinTarget - 0.1f - coin) * coinJumpRate;
                coinText.color = Color.Lerp(coinText.color, new Color(0.8f, 0.8f, 0.8f), coinJumpRate);
                var c = Mathf.CeilToInt(coin);
                if (c != lastCoin)
                {
                    // Jump
                    coinJumpSound.Play();
                    lastCoin = c;
                    coinText.text = GetCoinText(c, Setting.coinMark);
                    coinText.color = jumpColor;
                }
                yield return 0;
            }
        }


        float lootCoinTarget = 0;
        float lootCoin = 0;
        int lastLootCoin = 0;

        Coroutine rLootUpdate;
        IEnumerator RunLootUpdate()
        {
            while (true)
            {
                lootCoin += (lootCoinTarget - 0.1f - lootCoin) * coinJumpRate;
                lootCoinText.color = Color.Lerp(lootCoinText.color, new Color(0.8f, 0.8f, 0.8f), coinJumpRate);
                var c = Mathf.CeilToInt(lootCoin);
                if (c != lastLootCoin)
                {
                    // Jump
                    coinJumpSound.Play();
                    lastLootCoin = c;
                    lootCoinText.text = GetCoinText(c, Setting.coinMark);
                    lootCoinText.color = jumpColor;
                }
                yield return 0;
            }
        }
        #endregion
    }
}