using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
#if UNITY_EDITOR
using UnityEditor.ShortcutManagement;
#endif
using UnityEngine;
using XLua;

[LuaCallCSharp]
public class Main : MonoBehaviour
{
    public static LuaEnv currentLuaEnv { get; set; }

    public static Main instance;

    // Start is called before the first frame update
    void Start()
    {
        m_StopAllCoroutines = false;
        GameObject.DontDestroyOnLoad(gameObject);
        instance = this;
        //XLoader.Initialize(true);
        initLua();
    }
#if (UNITY_IPHONE || UNITY_TVOS || UNITY_WEBGL || UNITY_SWITCH) && !UNITY_EDITOR
        [DllImport("__Internal", CallingConvention = CallingConvention.Cdecl)]
#else
    [DllImport("xlua", CallingConvention = CallingConvention.Cdecl)]
#endif
    static extern int luaopen_cmsgpack_safe(System.IntPtr L);

    void initLua()
    {
        currentLuaEnv = new LuaEnv();
        currentLuaEnv.Global.Set<string, bool>("_ANDROID", true);
        currentLuaEnv.Global.Set<string, bool>("_CLIENT", true);




        currentLuaEnv.AddLoader((ref string fn) =>
        {
            return LuaFilePicker.Load(fn);
        });
        currentLuaEnv.AddBuildin("pb", XLua.LuaDLL.Lua.LoadLuaProfobuf);
        luaopen_cmsgpack_safe(currentLuaEnv.L);
        currentLuaEnv.DoString("require '" + "pre_main" + "'");
        //currentLuaEnv.DoString("require '" + Defines.LuaEntryFileName + "'");

        string path = Application.dataPath + "/Code/Lua/";

        GameFrameWorkClientLib.nfclient_lib_init( currentLuaEnv.L, path);
    }

#if UNITY_EDITOR
    [Shortcut("HotReload", KeyCode.F5)]
#endif
    public static void HotReload()
    {
        if (currentLuaEnv != null)
        {
            var rrquire_all = currentLuaEnv.Global.GetInPath<LuaFunction>("hot_require.rrquire_all");
            rrquire_all.Call();
        }
    }

    // Update is called once per frame
    void Update()
    {
        GameFrameWorkClientLib.nfclient_lib_loop();
        if (currentLuaEnv != null)
        {
            currentLuaEnv.Tick();
            //currentLuaEnv.Global.Get<LuaFunction>("update").Call();
        }
#if UNITY_EDITOR || UNITY_STANDALONE
        if (Input.GetKeyUp(KeyCode.F5))
        {
            HotReload();
        }
#endif
    }

    void OnDestroy()
    {
        GameFrameWorkClientLib.nfclient_lib_clear();
    }


    #region delay
    private static bool m_StopAllCoroutines = false;
    public static void MarkStopAllCoroutines()
    {
        m_StopAllCoroutines = true;
        instance?.StopAllCoroutines();
    }
    public static void StopDelay(object arg)
    {
        var ins = instance;
        if (ins != null && arg is Coroutine)
            ins.StopCoroutine((Coroutine)arg);
    }

    public static Coroutine Delay(LuaFunction luafun, float time, object args)
    {
        if (m_StopAllCoroutines) return null;
        var ins = instance;
        var _corout = DelayDo(luafun, time, args);
        var cor = ins.StartCoroutine(_corout);
        return cor;
    }

    private static IEnumerator DelayDo(LuaFunction luafun, float time, object args)
    {
        yield return new WaitForSeconds(time);
#if !HUGULA_RELEASE
        UnityEngine.Profiling.Profiler.BeginSample($"{luafun} DelayDo");
#endif
        luafun.Call(args);
#if !HUGULA_RELEASE
        UnityEngine.Profiling.Profiler.EndSample();
#endif
    }

    public static Coroutine DelayFrame(LuaFunction luafun, int frame, object args)
    {
        if (m_StopAllCoroutines) return null;
        var ins = instance;
        var _corout = DelayFrameDo(luafun, frame, args);
        var cor = ins?.StartCoroutine(_corout);
        return cor;
    }

    private static IEnumerator DelayFrameDo(LuaFunction luafun, int frame, object args)
    {
        var waitFrame = GetWaitForFrame(frame);
        yield return waitFrame;
#if !HUGULA_RELEASE
        UnityEngine.Profiling.Profiler.BeginSample($"{luafun} DelayFrameDo");
#endif
        luafun.Call(args);
#if !HUGULA_RELEASE
        UnityEngine.Profiling.Profiler.EndSample();
#endif
    }

    static Hugula.Utils.ObjectPool<WaitForSec> WaitForSecPool = new Hugula.Utils.ObjectPool<WaitForSec>(null, null, 16, 8);
    public static WaitForSec GetWaitForSec(float sec)
    {
        var waitSec = WaitForSecPool.Get();
        waitSec.m_TmEnd = Time.time + sec;
        return waitSec;
    }

    public class WaitForSec : IEnumerator
    {


        public float m_TmEnd;

        bool IEnumerator.MoveNext()
        {
            if (Time.time > m_TmEnd)
            {
                WaitForSecPool.Release(this);
            }
            return Time.time <= m_TmEnd;
        }

        object IEnumerator.Current
        {
            get
            {
                return null;
            }
        }

        void IEnumerator.Reset()
        {

        }
    }

    static Hugula.Utils.ObjectPool<WaitForFrame> WaitForFramePool = new Hugula.Utils.ObjectPool<WaitForFrame>(null, null, 32, 8);
    public static WaitForFrame GetWaitForFrame(int frame)
    {
        var waitFrame = WaitForFramePool.Get();
        waitFrame.m_EndCount = Time.frameCount + frame;
        return waitFrame;
    }

    // [XLua.LuaCallCSharp]
    public class WaitForFrame : IEnumerator
    {

        public int m_EndCount;

        bool IEnumerator.MoveNext()
        {
            if (Time.frameCount > m_EndCount)
            {
                WaitForFramePool.Release(this);
            }
            return Time.frameCount <= m_EndCount;
        }

        object IEnumerator.Current
        {
            get
            {
                return null;
            }
        }

        void IEnumerator.Reset()
        {

        }
    }
    #endregion
}
