﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Pickable : MonoBehaviour
    {
        #region Static
        static int? layerPick;
        static int? layerPickSelected;
        static List<Pickable> toPickList = new();
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
                    if (i == 0) OnCancelPick(pp);
                    toPickList.Insert(i, p);
                    OnPrePick(p);
                    return;
                }
            }
            toPickList.Add(p);
            OnPrePick(p);
        }
        public static void CancelPick(Pickable p)
        {
            for (int i = 0; i < toPickList.Count; ++i)
            {
                var pp = toPickList[i];
                if (pp == p)
                {
                    if (i == 0) OnCancelPick(p);
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
                    OnCancelPick(p);
                    p.OnPick();
                    toPickList.RemoveAt(0);
                    Destroy(p.gameObject);
                    if (toPickList.Count > 0) OnPrePick(toPickList[0]);
                }
            }
        }
        #endregion

        // Fields
        public GameObject meshObj;
        public int priority = 0;
        public string hint = "捡起";

        // Configurations
        public virtual void OnPick()
        {
            Ice.Gameplay.UIMgr.ShowNotification("Pick!");
        }

        void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                ToPick(this);
            }
        }
        void OnTriggerExit(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                CancelPick(this);
            }
        }


        void OnDrawGizmos()
        {
            var col = GetComponent<SphereCollider>();
            if (col != null)
            {
                Gizmos.color = Color.yellow;
                Gizmos.DrawWireSphere(col.transform.position, col.radius);
                Gizmos.color = Color.white;
            }
        }
    }
}
