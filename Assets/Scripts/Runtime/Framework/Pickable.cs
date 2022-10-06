using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    [RequireComponent(typeof(SphereCollider))]
    public abstract class Pickable : PlayerTrigger
    {
        #region Static
        static int? layerPick;
        static int? layerPickSelected;
        public static List<Pickable> toPickList = new();
        static void OnPrePick(Pickable p)
        {
            p.meshObj.layer = layerPickSelected ??= LayerMask.NameToLayer("PickableSelected");
            Ice.Gameplay.UIMgr.hintText.text = "E " + p.hint;
        }
        static void OnCancelPick(Pickable p)
        {
            p.meshObj.layer = layerPick ??= LayerMask.NameToLayer("Pickable");
            Ice.Gameplay.UIMgr.hintText.text = "";
        }
        public static void ToPick(Pickable p)
        {
            for (int i = 0; i < toPickList.Count; ++i)
            {
                var pp = toPickList[i];
                if (pp == p) return;
                if (pp.priority < p.priority)
                {
                    if (i == 0)
                    {
                        OnCancelPick(pp);
                        OnPrePick(p);
                    }
                    toPickList.Insert(i, p);
                    return;
                }
            }
            if (toPickList.Count == 0) OnPrePick(p);
            toPickList.Add(p);
        }
        public static void CancelPick(Pickable p)
        {
            for (int i = 0; i < toPickList.Count; ++i)
            {
                var pp = toPickList[i];
                if (pp == p)
                {
                    if (i == 0)
                    {
                        OnCancelPick(p);
                        if (toPickList.Count > 1)
                        {
                            OnPrePick(toPickList[1]);
                        }
                    }
                    toPickList.RemoveAt(i);
                    return;
                }
            }
        }
        public static void OnBattleUpdate()
        {
            if (Input.GetKeyDown(KeyCode.E))
            {
                if (toPickList.Count > 0)
                {
                    var p = toPickList[0];
                    if (p.OnPick())
                    {
                        OnCancelPick(p);
                        toPickList.RemoveAt(0);
                        if (toPickList.Count > 0) OnPrePick(toPickList[0]);
                    }
                }
            }
        }
        #endregion

        // Fields
        public GameObject meshObj;
        public int priority = 0;
        public string hint = "捡起";

        // Configurations
        public abstract bool OnPick();

        protected override void OnPlayerEnter() => ToPick(this);
        protected override void OnPlayerExit() => CancelPick(this);


        void OnDrawGizmos()
        {
            var col = GetComponent<SphereCollider>();
            if (col != null)
            {
                using var _ = new GizmosColorScope(Color.yellow);
                Gizmos.DrawWireSphere(col.transform.position + col.center, col.radius);
            }
        }
    }
}
