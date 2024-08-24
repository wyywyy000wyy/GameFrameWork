using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QualityPrefab : MonoBehaviour
{
    //[HideInInspector]
    //public List<GameObject> objects = new List<GameObject>();

    //public List<GameObject> VeryLow = new List<GameObject>();
    //public List<GameObject> Low = new List<GameObject>();
    //public List<GameObject> Medium = new List<GameObject>();
    //public List<GameObject> High = new List<GameObject>();
    //public List<GameObject> VeryHigh = new List<GameObject>();

    [Serializable]
    public class ShowInfo
    {
        public GameObject obj;
        public int show;

        public bool IsShow(int lod)
        {
            return (show & (1 << lod)) != 0;
        }

        public void SetShow(int lod, bool show)
        {
            if (show)
            {
                this.show |= (1 << lod);
            }
            else
            {
                this.show &= ~(1 << lod);
            }
        }
    }

    public List<ShowInfo> infos = new List<ShowInfo>();


    //public List<GameObject> GetLod(int lod)
    //{
    //    switch (lod)
    //    {
    //        case 0:
    //            return VeryLow;
    //        case 1:
    //            return Low;
    //        case 2:
    //            return Medium;
    //        case 3:
    //            return High;
    //        case 4:
    //            return VeryHigh;
    //        default:
    //            return Medium;
    //    }
    //}

    public void SetLod(int lod)
    {
        foreach(var info in infos)
        {
            if(info.IsShow(lod))
            {
                info.obj.SetActive(true);
            }
            else if(info.obj.activeSelf)
            {
                info.obj.SetActive(false);
            }
        }
        //var list = GetLod(lod);
        //foreach (var obj in objects)
        //{
        //    if(obj.activeSelf && !list.Contains(obj))
        //    obj.SetActive(false);
        //}

        //foreach (var obj in list)
        //{
        //    obj.SetActive(true);
        //}
    }
}
