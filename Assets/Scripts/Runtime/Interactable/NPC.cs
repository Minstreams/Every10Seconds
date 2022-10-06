using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Sys = Ice.Gameplay;

namespace IceEngine
{
    public class NPC : Interactable
    {
        public string npcName;
        public List<Dialog> dialogs = new();
        public string animTrigger = null;

        protected override void Awake()
        {
            base.Awake();
            if (!animTrigger.IsNullOrEmpty())
            {
                GetComponent<Animator>().SetTrigger(animTrigger);
            }
        }
        public Dialog GetDialog()
        {
            for (int i = dialogs.Count - 1; i >= 0; i--)
            {
                var dialog = dialogs[i];
                if (dialog.condition.IsConditionMeet())
                {
                    return dialog;
                }
            }
            return null;
        }
        public void OnPlayerExitRange()
        {
            Sys.CloseDialog();
        }
        protected override void OnPlayerEnter()
        {
            if (Sys.currentNPC != null) return;
            base.OnPlayerEnter();
        }
        public override bool OnPick()
        {
            Sys.StartDialog(GetDialog(), npcName);
            return true;
        }
    }
}