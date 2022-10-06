using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace IceEngine
{
    public class Slot : MonoBehaviour
    {
        public Button slotButton;
        public RectTransform container;
        static List<Slot> slots = new();
        public Color slotEmpty;
        public Color slotNormal;
        public Color slotSelected;
        Color slotUnselected => curItem == null ? slotEmpty : slotNormal;
        void Awake()
        {
            slots.Add(this);
        }
        void OnDestroy()
        {
            slots.Remove(this);
        }
        public void OnClick(UnityAction act)
        {
            slotButton.onClick.AddListener(act);
        }
        public void Select()
        {
            foreach (var s in slots) s.SetColor(s.slotUnselected);
            SetColor(slotSelected);
        }

        void SetColor(Color c)
        {
            if (slotButton == null) return;

            var cs = slotButton.colors;
            cs.normalColor = c;
            slotButton.colors = cs;
        }

        GameObject curItem;
        public GameObject Load(GameObject prefab)
        {
            Unload();
            return curItem = GameObject.Instantiate(prefab, container);
        }
        public void Unload()
        {
            if (curItem != null)
            {
                Destroy(curItem);
                curItem = null;
            }
        }
    }
}
