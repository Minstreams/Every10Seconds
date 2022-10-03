using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Weapon : Handable
    {
        public WeaponSlotType weaponType;
    }

    public enum WeaponSlotType
    {
        Basic,
        Main
    }
}
