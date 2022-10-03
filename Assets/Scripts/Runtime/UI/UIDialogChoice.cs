using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IceEngine
{
    public class UIDialogChoice : MonoBehaviour
    {
        public RectTransform rect;
        public Button btn;
        public Text uiText;
        public void SetText(string text)
        {
            uiText.text = text;
        }
    }
}
