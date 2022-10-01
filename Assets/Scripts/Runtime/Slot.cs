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
        public GameObject selection;
        static List<Slot> slots = new();
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
            foreach (var s in slots) s.selection.SetActive(false);
            selection.SetActive(true);
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
