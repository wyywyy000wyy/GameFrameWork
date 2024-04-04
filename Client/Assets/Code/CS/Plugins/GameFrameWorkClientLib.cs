using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class GameFrameWorkClientLib : MonoBehaviour
{
    // Start is called before the first frame update
#if (UNITY_IPHONE || UNITY_TVOS || UNITY_WEBGL || UNITY_SWITCH) && !UNITY_EDITOR
        [DllImport("__Internal", CallingConvention = CallingConvention.Cdecl)]
#else
    [DllImport("GameFrameWorkClientLib", CallingConvention = CallingConvention.Cdecl)]
#endif
    public static extern int nfclient_lib_clear();

#if (UNITY_IPHONE || UNITY_TVOS || UNITY_WEBGL || UNITY_SWITCH) && !UNITY_EDITOR
        [DllImport("__Internal", CallingConvention = CallingConvention.Cdecl)]
#else
    [DllImport("GameFrameWorkClientLib", CallingConvention = CallingConvention.Cdecl)]
#endif
    public static extern int nfclient_lib_init(string strArgvList);

    #if (UNITY_IPHONE || UNITY_TVOS || UNITY_WEBGL || UNITY_SWITCH) && !UNITY_EDITOR
        [DllImport("__Internal", CallingConvention = CallingConvention.Cdecl)]
#else
    [DllImport("GameFrameWorkClientLib", CallingConvention = CallingConvention.Cdecl)]
#endif
    public static extern int nfclient_lib_loop();
    
}
