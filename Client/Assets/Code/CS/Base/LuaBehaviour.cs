using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using DG.Tweening;
using DG.Tweening.Core.Easing;

//namespace Hugula.Framework
//{
[LuaCallCSharp]
    public class LuaBehaviour : MonoBehaviour
    {
        public static LuaBehaviour Create(LuaTable luaObj, string name = "LuaBehaviour")
        {
            GameObject go = new GameObject(name);
            LuaBehaviour b = go.AddComponent<LuaBehaviour>();
            b.SetLuaObj(luaObj);

            return b;
        }

        public static void Delete(LuaBehaviour b)
        {
            if(b)
            {
                GameObject go = b.gameObject;
                b.SetLuaObj(null);
                GameObject.Destroy(go);
            }
        }

        LuaFunction StartFunc;
        LuaFunction UpdateFunc;
        LuaFunction OnDisableFunc;
        LuaFunction OnEnableFunc;
        LuaTable _luaObj;
        public void SetLuaObj(LuaTable luaObj)
        {
            if(luaObj != null)
            {
                _luaObj = luaObj;
                StartFunc = luaObj.Get<LuaFunction>("Start");
                UpdateFunc = luaObj.Get<LuaFunction>("Update");
                OnDisableFunc = luaObj.Get<LuaFunction>("OnDisable");
                OnEnableFunc = luaObj.Get<LuaFunction>("OnEnable");
                luaObj.Set("CS", this);
            }
            else
            {
                if(_luaObj != null)
                {
                    _luaObj.Set("CS", 0);
                }
                StartFunc = null;
                UpdateFunc = null;
                OnDisableFunc = null;
                OnEnableFunc = null;
                _luaObj = null;
            }
        }
        public void Start()
        {
            StartFunc?.Call();
        }
        public void Update()
        {
            UpdateFunc?.Call();

        }
        public void OnDisable()
        {
            OnDisableFunc?.Call();

        }
        public void OnEnable()
        {
            OnEnableFunc?.Call();
        }

    public static float SampleEase(float cur, Ease ease = Ease.Unset)
    {
        if (ease == Ease.Unset)
        {
            return cur;
        }
        else
        {
            return EaseManager.Evaluate(ease, null, cur, 1, 0, 0);
        }
    }
}
//}