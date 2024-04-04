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
    public class MapWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(Map);
			Utils.BeginObjectRegister(type, L, translator, 0, 5, 6, 6);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Move", _m_Move);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "StartMap", _m_StartMap);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "PosToBlockId", _m_PosToBlockId);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "NewMapSection", _m_NewMapSection);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "ReleaseMapSection", _m_ReleaseMapSection);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "sceneCameraTrans", _g_get_sceneCameraTrans);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "mapLevel0", _g_get_mapLevel0);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "mapLevel1", _g_get_mapLevel1);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "mapLevel2", _g_get_mapLevel2);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "scaleValue0", _g_get_scaleValue0);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "scaleValue1", _g_get_scaleValue1);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "sceneCameraTrans", _s_set_sceneCameraTrans);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "mapLevel0", _s_set_mapLevel0);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "mapLevel1", _s_set_mapLevel1);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "mapLevel2", _s_set_mapLevel2);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "scaleValue0", _s_set_scaleValue0);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "scaleValue1", _s_set_scaleValue1);
            
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 32, 1, 0);
			
			
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_REGION_COUNT_X", Map.MAP_REGION_COUNT_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_REGION_COUNT_Y", Map.MAP_REGION_COUNT_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_SECTION_COUNT_X", Map.MAP_SECTION_COUNT_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_SECTION_COUNT_Y", Map.MAP_SECTION_COUNT_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_TILE_COUNT_X", Map.MAP_TILE_COUNT_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_TILE_COUNT_Y", Map.MAP_TILE_COUNT_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_BLOCK_COUNT_X", Map.MAP_BLOCK_COUNT_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_BLOCK_COUNT_Y", Map.MAP_BLOCK_COUNT_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_CELL_COUNT_X", Map.MAP_CELL_COUNT_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_CELL_COUNT_Y", Map.MAP_CELL_COUNT_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_BLOCK_COUNT_TOTAL_X", Map.MAP_BLOCK_COUNT_TOTAL_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_BLOCK_COUNT_TOTAL_Y", Map.MAP_BLOCK_COUNT_TOTAL_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_REGION_COUNT", Map.MAP_REGION_COUNT);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_SECTION_COUNT", Map.MAP_SECTION_COUNT);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_TILE_COUNT", Map.MAP_TILE_COUNT);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_BLOCK_COUNT", Map.MAP_BLOCK_COUNT);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_CELL_COUNT", Map.MAP_CELL_COUNT);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_CELL_DEMANSION_X", Map.MAP_CELL_DEMANSION_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_CELL_DEMANSION_Y", Map.MAP_CELL_DEMANSION_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_BLOCK_DEMANSION_X", Map.MAP_BLOCK_DEMANSION_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_BLOCK_DEMANSION_Y", Map.MAP_BLOCK_DEMANSION_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_TILE_DEMANSION_X", Map.MAP_TILE_DEMANSION_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_TILE_DEMANSION_Y", Map.MAP_TILE_DEMANSION_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_SECTION_DEMANSION_X", Map.MAP_SECTION_DEMANSION_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_SECTION_DEMANSION_Y", Map.MAP_SECTION_DEMANSION_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_REGION_DEMANSION_X", Map.MAP_REGION_DEMANSION_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_REGION_DEMANSION_Y", Map.MAP_REGION_DEMANSION_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_DEMANSION_X", Map.MAP_DEMANSION_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_DEMANSION_Y", Map.MAP_DEMANSION_Y);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_START_X", Map.MAP_START_X);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "MAP_START_Y", Map.MAP_START_Y);
            
			Utils.RegisterFunc(L, Utils.CLS_GETTER_IDX, "Instance", _g_get_Instance);
            
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					Map gen_ret = new Map();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to Map constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Move(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
            
            
			    int gen_param_count = LuaAPI.lua_gettop(L);
            
                if(gen_param_count == 4&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    int _x = LuaAPI.xlua_tointeger(L, 2);
                    int _y = LuaAPI.xlua_tointeger(L, 3);
                    int _level = LuaAPI.xlua_tointeger(L, 4);
                    
                    gen_to_be_invoked.Move( _x, _y, _level );
                    
                    
                    
                    return 0;
                }
                if(gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    int _x = LuaAPI.xlua_tointeger(L, 2);
                    int _y = LuaAPI.xlua_tointeger(L, 3);
                    
                    gen_to_be_invoked.Move( _x, _y );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to Map.Move!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_StartMap(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    gen_to_be_invoked.StartMap(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PosToBlockId(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Vector3 _targetPos;translator.Get(L, 2, out _targetPos);
                    
                        int gen_ret = gen_to_be_invoked.PosToBlockId( _targetPos );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_NewMapSection(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        MapSection gen_ret = gen_to_be_invoked.NewMapSection(  );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ReleaseMapSection(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    MapSection _sect = (MapSection)translator.GetObject(L, 2, typeof(MapSection));
                    
                    gen_to_be_invoked.ReleaseMapSection( _sect );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_Instance(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			    translator.Push(L, Map.Instance);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_sceneCameraTrans(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.sceneCameraTrans);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_mapLevel0(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.mapLevel0);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_mapLevel1(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.mapLevel1);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_mapLevel2(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                translator.Push(L, gen_to_be_invoked.mapLevel2);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_scaleValue0(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, gen_to_be_invoked.scaleValue0);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_scaleValue1(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, gen_to_be_invoked.scaleValue1);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_sceneCameraTrans(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.sceneCameraTrans = (UnityEngine.Transform)translator.GetObject(L, 2, typeof(UnityEngine.Transform));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_mapLevel0(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.mapLevel0 = (UnityEngine.GameObject)translator.GetObject(L, 2, typeof(UnityEngine.GameObject));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_mapLevel1(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.mapLevel1 = (UnityEngine.GameObject)translator.GetObject(L, 2, typeof(UnityEngine.GameObject));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_mapLevel2(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.mapLevel2 = (UnityEngine.GameObject)translator.GetObject(L, 2, typeof(UnityEngine.GameObject));
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_scaleValue0(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.scaleValue0 = (float)LuaAPI.lua_tonumber(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_scaleValue1(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                Map gen_to_be_invoked = (Map)translator.FastGetCSObj(L, 1);
                gen_to_be_invoked.scaleValue1 = (float)LuaAPI.lua_tonumber(L, 2);
            
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
