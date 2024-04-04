#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using XLua;
using System.Collections.Generic;


namespace XLua.CSObjectWrap
{
    using Utils = XLua.Utils;
    
    public class UnityBehaviourFuncWrap
    {
		public static void __Register(RealStatePtr L)
        {
		    ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
		    Utils.BeginObjectRegister(typeof(UnityBehaviourFunc), L, translator, 0, 0, 0, 0);
			Utils.EndObjectRegister(typeof(UnityBehaviourFunc), L, translator, null, null, null, null, null);
			
			Utils.BeginClassRegister(typeof(UnityBehaviourFunc), L, null, 13, 0, 0);

            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Start", UnityBehaviourFunc.Start);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "OnDestroy", UnityBehaviourFunc.OnDestroy);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Update", UnityBehaviourFunc.Update);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "OnApplicationFocus", UnityBehaviourFunc.OnApplicationFocus);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "OnApplicationPause", UnityBehaviourFunc.OnApplicationPause);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "OnApplicationQuit", UnityBehaviourFunc.OnApplicationQuit);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "OnBeginDrag", UnityBehaviourFunc.OnBeginDrag);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "OnDrag", UnityBehaviourFunc.OnDrag);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "OnEndDrag", UnityBehaviourFunc.OnEndDrag);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "OnAnimatorStateEnter", UnityBehaviourFunc.OnAnimatorStateEnter);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "OnAnimatorStateExit", UnityBehaviourFunc.OnAnimatorStateExit);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Max", UnityBehaviourFunc.Max);
            

			Utils.RegisterFunc(L, Utils.CLS_IDX, "__CastFrom", __CastFrom);
            
            Utils.EndClassRegister(typeof(UnityBehaviourFunc), L, translator);
        }
		
		[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CastFrom(RealStatePtr L)
		{
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			LuaTypes lua_type = LuaAPI.lua_type(L, 1);
            if (lua_type == LuaTypes.LUA_TNUMBER)
            {
                translator.PushUnityBehaviourFunc(L, (UnityBehaviourFunc)LuaAPI.xlua_tointeger(L, 1));
            }
			
            else if(lua_type == LuaTypes.LUA_TSTRING)
            {

			    if (LuaAPI.xlua_is_eq_str(L, 1, "Start"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.Start);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "OnDestroy"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.OnDestroy);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "Update"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.Update);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "OnApplicationFocus"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.OnApplicationFocus);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "OnApplicationPause"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.OnApplicationPause);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "OnApplicationQuit"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.OnApplicationQuit);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "OnBeginDrag"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.OnBeginDrag);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "OnDrag"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.OnDrag);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "OnEndDrag"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.OnEndDrag);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "OnAnimatorStateEnter"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.OnAnimatorStateEnter);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "OnAnimatorStateExit"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.OnAnimatorStateExit);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "Max"))
                {
                    translator.PushUnityBehaviourFunc(L, UnityBehaviourFunc.Max);
                }
				else
                {
                    return LuaAPI.luaL_error(L, "invalid string for UnityBehaviourFunc!");
                }

            }
			
            else
            {
                return LuaAPI.luaL_error(L, "invalid lua type for UnityBehaviourFunc! Expect number or string, got + " + lua_type);
            }

            return 1;
		}
	}
    
    public class NetEventTypeWrap
    {
		public static void __Register(RealStatePtr L)
        {
		    ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
		    Utils.BeginObjectRegister(typeof(NetEventType), L, translator, 0, 0, 0, 0);
			Utils.EndObjectRegister(typeof(NetEventType), L, translator, null, null, null, null, null);
			
			Utils.BeginClassRegister(typeof(NetEventType), L, null, 4, 0, 0);

            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "CONNECT", NetEventType.CONNECT);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "CONNECT_ERROR", NetEventType.CONNECT_ERROR);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "CLOSE", NetEventType.CLOSE);
            

			Utils.RegisterFunc(L, Utils.CLS_IDX, "__CastFrom", __CastFrom);
            
            Utils.EndClassRegister(typeof(NetEventType), L, translator);
        }
		
		[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CastFrom(RealStatePtr L)
		{
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			LuaTypes lua_type = LuaAPI.lua_type(L, 1);
            if (lua_type == LuaTypes.LUA_TNUMBER)
            {
                translator.PushNetEventType(L, (NetEventType)LuaAPI.xlua_tointeger(L, 1));
            }
			
            else if(lua_type == LuaTypes.LUA_TSTRING)
            {

			    if (LuaAPI.xlua_is_eq_str(L, 1, "CONNECT"))
                {
                    translator.PushNetEventType(L, NetEventType.CONNECT);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "CONNECT_ERROR"))
                {
                    translator.PushNetEventType(L, NetEventType.CONNECT_ERROR);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "CLOSE"))
                {
                    translator.PushNetEventType(L, NetEventType.CLOSE);
                }
				else
                {
                    return LuaAPI.luaL_error(L, "invalid string for NetEventType!");
                }

            }
			
            else
            {
                return LuaAPI.luaL_error(L, "invalid lua type for NetEventType! Expect number or string, got + " + lua_type);
            }

            return 1;
		}
	}
    
    public class UnityEngineAnimatorUpdateModeWrap
    {
		public static void __Register(RealStatePtr L)
        {
		    ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
		    Utils.BeginObjectRegister(typeof(UnityEngine.AnimatorUpdateMode), L, translator, 0, 0, 0, 0);
			Utils.EndObjectRegister(typeof(UnityEngine.AnimatorUpdateMode), L, translator, null, null, null, null, null);
			
			Utils.BeginClassRegister(typeof(UnityEngine.AnimatorUpdateMode), L, null, 4, 0, 0);

            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Normal", UnityEngine.AnimatorUpdateMode.Normal);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "AnimatePhysics", UnityEngine.AnimatorUpdateMode.AnimatePhysics);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "UnscaledTime", UnityEngine.AnimatorUpdateMode.UnscaledTime);
            

			Utils.RegisterFunc(L, Utils.CLS_IDX, "__CastFrom", __CastFrom);
            
            Utils.EndClassRegister(typeof(UnityEngine.AnimatorUpdateMode), L, translator);
        }
		
		[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CastFrom(RealStatePtr L)
		{
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			LuaTypes lua_type = LuaAPI.lua_type(L, 1);
            if (lua_type == LuaTypes.LUA_TNUMBER)
            {
                translator.PushUnityEngineAnimatorUpdateMode(L, (UnityEngine.AnimatorUpdateMode)LuaAPI.xlua_tointeger(L, 1));
            }
			
            else if(lua_type == LuaTypes.LUA_TSTRING)
            {

			    if (LuaAPI.xlua_is_eq_str(L, 1, "Normal"))
                {
                    translator.PushUnityEngineAnimatorUpdateMode(L, UnityEngine.AnimatorUpdateMode.Normal);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "AnimatePhysics"))
                {
                    translator.PushUnityEngineAnimatorUpdateMode(L, UnityEngine.AnimatorUpdateMode.AnimatePhysics);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "UnscaledTime"))
                {
                    translator.PushUnityEngineAnimatorUpdateMode(L, UnityEngine.AnimatorUpdateMode.UnscaledTime);
                }
				else
                {
                    return LuaAPI.luaL_error(L, "invalid string for UnityEngine.AnimatorUpdateMode!");
                }

            }
			
            else
            {
                return LuaAPI.luaL_error(L, "invalid lua type for UnityEngine.AnimatorUpdateMode! Expect number or string, got + " + lua_type);
            }

            return 1;
		}
	}
    
    public class UnityEngineRuntimePlatformWrap
    {
		public static void __Register(RealStatePtr L)
        {
		    ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
		    Utils.BeginObjectRegister(typeof(UnityEngine.RuntimePlatform), L, translator, 0, 0, 0, 0);
			Utils.EndObjectRegister(typeof(UnityEngine.RuntimePlatform), L, translator, null, null, null, null, null);
			
			Utils.BeginClassRegister(typeof(UnityEngine.RuntimePlatform), L, null, 49, 0, 0);

            Utils.RegisterEnumType(L, typeof(UnityEngine.RuntimePlatform));

			Utils.RegisterFunc(L, Utils.CLS_IDX, "__CastFrom", __CastFrom);
            
            Utils.EndClassRegister(typeof(UnityEngine.RuntimePlatform), L, translator);
        }
		
		[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CastFrom(RealStatePtr L)
		{
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			LuaTypes lua_type = LuaAPI.lua_type(L, 1);
            if (lua_type == LuaTypes.LUA_TNUMBER)
            {
                translator.PushUnityEngineRuntimePlatform(L, (UnityEngine.RuntimePlatform)LuaAPI.xlua_tointeger(L, 1));
            }
			
            else if(lua_type == LuaTypes.LUA_TSTRING)
            {

                try
				{
                    translator.TranslateToEnumToTop(L, typeof(UnityEngine.RuntimePlatform), 1);
				}
				catch (System.Exception e)
				{
					return LuaAPI.luaL_error(L, "cast to " + typeof(UnityEngine.RuntimePlatform) + " exception:" + e);
				}

            }
			
            else
            {
                return LuaAPI.luaL_error(L, "invalid lua type for UnityEngine.RuntimePlatform! Expect number or string, got + " + lua_type);
            }

            return 1;
		}
	}
    
    public class UnityEngineUISelectableTransitionWrap
    {
		public static void __Register(RealStatePtr L)
        {
		    ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
		    Utils.BeginObjectRegister(typeof(UnityEngine.UI.Selectable.Transition), L, translator, 0, 0, 0, 0);
			Utils.EndObjectRegister(typeof(UnityEngine.UI.Selectable.Transition), L, translator, null, null, null, null, null);
			
			Utils.BeginClassRegister(typeof(UnityEngine.UI.Selectable.Transition), L, null, 5, 0, 0);

            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "None", UnityEngine.UI.Selectable.Transition.None);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "ColorTint", UnityEngine.UI.Selectable.Transition.ColorTint);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "SpriteSwap", UnityEngine.UI.Selectable.Transition.SpriteSwap);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Animation", UnityEngine.UI.Selectable.Transition.Animation);
            

			Utils.RegisterFunc(L, Utils.CLS_IDX, "__CastFrom", __CastFrom);
            
            Utils.EndClassRegister(typeof(UnityEngine.UI.Selectable.Transition), L, translator);
        }
		
		[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CastFrom(RealStatePtr L)
		{
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			LuaTypes lua_type = LuaAPI.lua_type(L, 1);
            if (lua_type == LuaTypes.LUA_TNUMBER)
            {
                translator.PushUnityEngineUISelectableTransition(L, (UnityEngine.UI.Selectable.Transition)LuaAPI.xlua_tointeger(L, 1));
            }
			
            else if(lua_type == LuaTypes.LUA_TSTRING)
            {

			    if (LuaAPI.xlua_is_eq_str(L, 1, "None"))
                {
                    translator.PushUnityEngineUISelectableTransition(L, UnityEngine.UI.Selectable.Transition.None);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "ColorTint"))
                {
                    translator.PushUnityEngineUISelectableTransition(L, UnityEngine.UI.Selectable.Transition.ColorTint);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "SpriteSwap"))
                {
                    translator.PushUnityEngineUISelectableTransition(L, UnityEngine.UI.Selectable.Transition.SpriteSwap);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "Animation"))
                {
                    translator.PushUnityEngineUISelectableTransition(L, UnityEngine.UI.Selectable.Transition.Animation);
                }
				else
                {
                    return LuaAPI.luaL_error(L, "invalid string for UnityEngine.UI.Selectable.Transition!");
                }

            }
			
            else
            {
                return LuaAPI.luaL_error(L, "invalid lua type for UnityEngine.UI.Selectable.Transition! Expect number or string, got + " + lua_type);
            }

            return 1;
		}
	}
    
    public class UnityEngineNetworkReachabilityWrap
    {
		public static void __Register(RealStatePtr L)
        {
		    ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
		    Utils.BeginObjectRegister(typeof(UnityEngine.NetworkReachability), L, translator, 0, 0, 0, 0);
			Utils.EndObjectRegister(typeof(UnityEngine.NetworkReachability), L, translator, null, null, null, null, null);
			
			Utils.BeginClassRegister(typeof(UnityEngine.NetworkReachability), L, null, 4, 0, 0);

            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "NotReachable", UnityEngine.NetworkReachability.NotReachable);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "ReachableViaCarrierDataNetwork", UnityEngine.NetworkReachability.ReachableViaCarrierDataNetwork);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "ReachableViaLocalAreaNetwork", UnityEngine.NetworkReachability.ReachableViaLocalAreaNetwork);
            

			Utils.RegisterFunc(L, Utils.CLS_IDX, "__CastFrom", __CastFrom);
            
            Utils.EndClassRegister(typeof(UnityEngine.NetworkReachability), L, translator);
        }
		
		[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CastFrom(RealStatePtr L)
		{
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			LuaTypes lua_type = LuaAPI.lua_type(L, 1);
            if (lua_type == LuaTypes.LUA_TNUMBER)
            {
                translator.PushUnityEngineNetworkReachability(L, (UnityEngine.NetworkReachability)LuaAPI.xlua_tointeger(L, 1));
            }
			
            else if(lua_type == LuaTypes.LUA_TSTRING)
            {

			    if (LuaAPI.xlua_is_eq_str(L, 1, "NotReachable"))
                {
                    translator.PushUnityEngineNetworkReachability(L, UnityEngine.NetworkReachability.NotReachable);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "ReachableViaCarrierDataNetwork"))
                {
                    translator.PushUnityEngineNetworkReachability(L, UnityEngine.NetworkReachability.ReachableViaCarrierDataNetwork);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "ReachableViaLocalAreaNetwork"))
                {
                    translator.PushUnityEngineNetworkReachability(L, UnityEngine.NetworkReachability.ReachableViaLocalAreaNetwork);
                }
				else
                {
                    return LuaAPI.luaL_error(L, "invalid string for UnityEngine.NetworkReachability!");
                }

            }
			
            else
            {
                return LuaAPI.luaL_error(L, "invalid lua type for UnityEngine.NetworkReachability! Expect number or string, got + " + lua_type);
            }

            return 1;
		}
	}
    
    public class UnityEngineTouchPhaseWrap
    {
		public static void __Register(RealStatePtr L)
        {
		    ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
		    Utils.BeginObjectRegister(typeof(UnityEngine.TouchPhase), L, translator, 0, 0, 0, 0);
			Utils.EndObjectRegister(typeof(UnityEngine.TouchPhase), L, translator, null, null, null, null, null);
			
			Utils.BeginClassRegister(typeof(UnityEngine.TouchPhase), L, null, 6, 0, 0);

            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Began", UnityEngine.TouchPhase.Began);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Moved", UnityEngine.TouchPhase.Moved);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Stationary", UnityEngine.TouchPhase.Stationary);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Ended", UnityEngine.TouchPhase.Ended);
            
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Canceled", UnityEngine.TouchPhase.Canceled);
            

			Utils.RegisterFunc(L, Utils.CLS_IDX, "__CastFrom", __CastFrom);
            
            Utils.EndClassRegister(typeof(UnityEngine.TouchPhase), L, translator);
        }
		
		[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CastFrom(RealStatePtr L)
		{
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			LuaTypes lua_type = LuaAPI.lua_type(L, 1);
            if (lua_type == LuaTypes.LUA_TNUMBER)
            {
                translator.PushUnityEngineTouchPhase(L, (UnityEngine.TouchPhase)LuaAPI.xlua_tointeger(L, 1));
            }
			
            else if(lua_type == LuaTypes.LUA_TSTRING)
            {

			    if (LuaAPI.xlua_is_eq_str(L, 1, "Began"))
                {
                    translator.PushUnityEngineTouchPhase(L, UnityEngine.TouchPhase.Began);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "Moved"))
                {
                    translator.PushUnityEngineTouchPhase(L, UnityEngine.TouchPhase.Moved);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "Stationary"))
                {
                    translator.PushUnityEngineTouchPhase(L, UnityEngine.TouchPhase.Stationary);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "Ended"))
                {
                    translator.PushUnityEngineTouchPhase(L, UnityEngine.TouchPhase.Ended);
                }
				else if (LuaAPI.xlua_is_eq_str(L, 1, "Canceled"))
                {
                    translator.PushUnityEngineTouchPhase(L, UnityEngine.TouchPhase.Canceled);
                }
				else
                {
                    return LuaAPI.luaL_error(L, "invalid string for UnityEngine.TouchPhase!");
                }

            }
			
            else
            {
                return LuaAPI.luaL_error(L, "invalid lua type for UnityEngine.TouchPhase! Expect number or string, got + " + lua_type);
            }

            return 1;
		}
	}
    
}