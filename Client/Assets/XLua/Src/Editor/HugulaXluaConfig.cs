using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEngine;
using XLua;

namespace XLua.Editor
{
    public static class HugulaXluaConfig
    {


        //[LuaCallCSharp]
        //public static IEnumerable<Type> LuaCallCSharp
        //{
        //    get
        //    {
        //        List<string> namespaces = new List<string>() // 在这里添加名字空间
        //        {
        //            "UnityEngine",
        //            //"UnityEngine.UI",
        //            //"UnityEngine.AI",
        //            //"UnityEngine.Events",
        //            //"DG.Tweening",
        //        };

        //        var unityTypes = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
        //                          where !(assembly.ManifestModule is System.Reflection.Emit.ModuleBuilder)
        //                          from type in assembly.GetExportedTypes()
        //                          where type.Namespace != null && namespaces.Contains(type.Namespace) && !isExcluded(type) &&
        //                        type.BaseType != typeof(MulticastDelegate) && !type.IsInterface
        //                          select type);

        //        string[] customAssemblys = new string[] {
        //            "Assembly-CSharp",
        //        };

        //        var genericTypes = new HashSet<Type>();
        //        Action<Type> findParentType = (Type t) =>
        //        {
        //            while (t != null && t.BaseType != null && t.BaseType.FullName != null && (t.IsGenericType || t.BaseType.IsGenericType))
        //            {
        //                genericTypes.Add(t);
        //                t = t.BaseType;
        //            }
        //        };

        //        foreach (var cuAsse in customAssemblys)
        //        {
        //            var types = Assembly.Load(cuAsse).GetExportedTypes();
        //            foreach (var type in types)
        //            {
        //                if (namespaces.Contains(type.Namespace) && type.BaseType != null && type.BaseType.FullName != null && type.BaseType.IsGenericType)
        //                {
        //                    genericTypes.Add(type.BaseType);
        //                    findParentType(type.BaseType.BaseType);
        //                }
        //            }
        //        }

        //        // foreach (var t in genericTypes)
        //        // {
        //        //     Debug.Log($"genericTypes :{t}");
        //        // }

        //        var customlist = new List<Type>();


        //        //customlist.Add(typeof(UnityEngine.Profiling.Profiler));
        //        //customlist.Add(typeof(UnityEngine.EventSystems.EventSystem));

        //        return unityTypes.Concat(customlist).Concat(genericTypes);
        //    }
        //}
        [LuaCallCSharp]
        public static List<Type> LuaCallCSharp
        {
            get
            {
                var types = new List<Type>();
                types.Add(typeof(UnityEngine.MonoBehaviour));
                types.Add(typeof(DG.Tweening.DOTween));
                types.Add(typeof(DG.Tweening.Sequence));
                return types;
            }
        }
        static List<string> exclude = new List<string>
        {

        };
        static bool isExcluded(Type type)
        {
            var fullName = type.FullName;
            for (int i = 0; i < exclude.Count; i++)
            {
                if (fullName.Contains(exclude[i]))
                {
                    return true;
                }
            }
            return false;
        }

        [LuaCallCSharp]
        public static IEnumerable<Type> LuaCallCSharp2
        {
            get
            {
                List<string> namespaces = new List<string>() // 在这里添加名字空间
                {
                    "DG.Tweening",
                };

                var unityTypes = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
                                  where !(assembly.ManifestModule is System.Reflection.Emit.ModuleBuilder)
                                  from type in assembly.GetExportedTypes()
                                  where type.Namespace != null && namespaces.Contains(type.Namespace) && !isExcluded(type) &&
                                type.BaseType != typeof(MulticastDelegate) && !type.IsInterface
                                  select type);

                string[] customAssemblys = new string[] {
                    "Assembly-CSharp",
                };

                var genericTypes = new HashSet<Type>();
                Action<Type> findParentType = (Type t) =>
                {
                    while (t != null && t.BaseType != null && t.BaseType.FullName != null && (t.IsGenericType || t.BaseType.IsGenericType))
                    {
                        genericTypes.Add(t);
                        t = t.BaseType;
                    }
                };

                foreach (var cuAsse in customAssemblys)
                {
                    var types = Assembly.Load(cuAsse).GetExportedTypes();
                    foreach (var type in types)
                    {
                        if (namespaces.Contains(type.Namespace) && type.BaseType != null && type.BaseType.FullName != null && type.BaseType.IsGenericType)
                        {
                            genericTypes.Add(type.BaseType);
                            findParentType(type.BaseType.BaseType);
                        }
                    }
                }
                var customlist = new List<Type>();
                //customlist.Add(typeof(Action<object, object, int>));

                return unityTypes.Concat(customlist).Concat(genericTypes);
            }
        }

[CSharpCallLua]
        public static List<Type> CSharpCallLua
        {
            get
            {

                var types = new List<Type>();
                ////自定义方法
                //types.Add(typeof(Func<object, int, Component, int, RectTransform, Component>));
                //types.Add(typeof(Action<object, object, int>));
                //types.Add(typeof(Action<object, float>));
                //types.Add(typeof(Action<object, object>));
                //types.Add(typeof(Action<object, float, float>));
                //types.Add(typeof(UnityEngine.Events.UnityAction<float>));
                //types.Add(typeof(UnityEngine.Events.UnityAction));
                //types.Add(typeof(System.Func<System.Object, int, int>));
                //types.Add(typeof(Action<object, object, int>));
                //types.Add(typeof(System.Action<object>));
                //types.Add(typeof(System.Func<string, float, string>));

                //types.Add(typeof(Func<object, int, Component, int, RectTransform, Component>));
                //types.Add(typeof(Action<object, object, int, int>));
                //types.Add(typeof(Func<object, int, int>));
                //types.Add(typeof(Action<object, Component, int>));
                //types.Add(typeof(Action<Vector2>));
                //types.Add(typeof(System.Action<object, object, string, string, string, string>));
                //types.Add(typeof(System.Collections.IList));
                //types.Add(typeof(Func<string, string>));
                types.Add(typeof(System.Collections.IEnumerator));

                //types.Add(typeof(System.Action<object, string, UnityEngine.Object>)); //poolmanager call back回调

                //types.Add(typeof(Action<Vector2>));
                //types.Add(typeof(System.Action<object, object, string, string, string, string>));
                //types.Add(typeof(System.Func<int, object, bool>));

                //types.Add(typeof(System.Collections.Specialized.NotifyCollectionChangedEventArgs));
                //types.Add(typeof(System.Collections.IList));

                //types.Add(typeof(Action<float, float, float>));
                //types.Add(typeof(Action<float, float>));
                //types.Add(typeof(Action<int>));
                //types.Add(typeof(Func<int, int>));
                //types.Add(typeof(Action<object>));
                //types.Add(typeof(Action<int, bool>));

                //types.Add(typeof(System.Action<Vector2, Vector2>));
                //types.Add(typeof(System.Action<object, string, UnityEngine.Object>)); //poolmanager call back回调

                //types.Add(typeof(List<UnityEngine.Vector3>));
                //types.Add(typeof(List<float>));
                //types.Add(typeof(List<int>));


                //types.Add(typeof(Action<string, UnityEngine.Object>));
                //types.Add(typeof(DateTime));

                //types.Add(typeof(UnityEngine.RuntimePlatform));
                //types.Add(typeof(System.Object));
                //types.Add(typeof(Func<string, bool>));
                //types.Add(typeof(Func<string, bool, Action, bool>));

                return types;
            }

        }
        //--------------end 纯lua编程配置参考----------------------------
    }
}