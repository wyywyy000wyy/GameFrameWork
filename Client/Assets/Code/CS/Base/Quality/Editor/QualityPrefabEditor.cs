using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using NUnit.Framework;
using static UnityEditor.PlayerSettings;

[CustomEditor(typeof(QualityPrefab))]
public class QualityPrefabEditor : Editor
{
    string[] lodtxt = new string[] { "VeryLow", "Low", "Medium", "High", "VeryHigh" };

    static bool isParent(GameObject parent, GameObject child)
    {
        if (child == null || parent == null)
            return false;

        if (parent == child)
            return true;

        var p = child.transform.parent;
        while (p != null)
        {
            if (p.gameObject == parent)
                return true;
            p = p.parent;
        }

        return false;
    }

    QualityPrefab myScript;
    GameObject targetGo;
    bool[] expand = new bool[5];
    private void OnEnable()
    {
        myScript = (QualityPrefab)target;
        targetGo = myScript.gameObject;
        var trans = myScript.GetComponentsInChildren<Transform>(true);

        //myScript.objects.Clear();
        foreach (var t in trans)
        {
            if (t.gameObject != myScript.gameObject)
            {
                add_if_not_exist(myScript.infos, t.gameObject);
            }

        }
    }

    static void add_if_not_exist(List<QualityPrefab.ShowInfo> list, GameObject go, int lod = -1)
    {
        QualityPrefab.ShowInfo findInfo = null;
        foreach (var info in list)
        {
            if (info.obj == go)
            {
                findInfo = info;
                break;
            }
        }
        if (findInfo == null)
        {
            findInfo = new QualityPrefab.ShowInfo();
            findInfo.obj = go;
            list.Add(findInfo);
        }
        if(lod >= 0)
        {
            findInfo.show |= 1 << lod;
        }
    }

    void removeNull()
    {
        for (int i = myScript.infos.Count - 1; i >= 0; i--)
        {
            if (myScript.infos[i] == null || myScript.infos[i].obj == null)
            {
                myScript.infos.RemoveAt(i);
            }
            else
            {
                myScript.infos[i].obj.SetActive(false);
            }
        }
        EditorUtility.SetDirty(target);
    }

    public override void OnInspectorGUI()
    {
        //DrawDefaultInspector();
        serializedObject.Update();

        //QualityPrefab myScript = (QualityPrefab)target;
        //GameObject targetGo = myScript.gameObject;

        for (int i = 0; i < 5; i++)
        {
            //List<GameObject> list = myScript.GetLod(i);

            Rect dirRect = EditorGUILayout.BeginHorizontal();
            GUIContent content = new GUIContent();
            int showCount = 0;
            foreach (var info in myScript.infos)
            {
                if (info.IsShow(i))
                {
                    showCount++;
                }
            }
            content.text = $"{lodtxt[i]} (���� {showCount}  ��ק�������)";
            content.tooltip = "��ק���ֻ�ռ������gameObject";
            EditorGUILayout.LabelField(content);
            if ((Event.current.type == EventType.DragUpdated || Event.current.type == EventType.DragExited)
    && dirRect.Contains(Event.current.mousePosition))
            {
                DragAndDrop.visualMode = DragAndDropVisualMode.Generic;

                if (Event.current.type == EventType.DragExited)
                {
                    var objs = DragAndDrop.objectReferences;
                    foreach (var obj in objs)
                    {
                        if (obj is GameObject)
                        {
                            GameObject t = (GameObject)obj;
                            if (t.activeSelf && t.gameObject != myScript.gameObject && isParent(targetGo,t))
                            {
                                add_if_not_exist(myScript.infos, t, i);
                            }
                        }
                    }
                    expand[i] = true;
                    EditorUtility.SetDirty(target);
                }

            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("�Ѽ�����"))
            {
                //list.Clear();
                var trans = myScript.GetComponentsInChildren<Transform>(true);

                //myScript.objects.Clear();

                foreach (var t in trans)
                {
                    if (t.gameObject != myScript.gameObject)
                    {
                        add_if_not_exist(myScript.infos, t.gameObject, i);
                    }

                }
                expand[i] = true;
                EditorUtility.SetDirty(target);

            }
            if(i != 4 && GUILayout.Button("����" + lodtxt[i+1]))
            {
                foreach (var info in myScript.infos)
                {
                    bool isShow = info.IsShow(i + 1);
                    info.SetShow(i, isShow);
                }
                expand[i] = true;
                EditorUtility.SetDirty(target);
            }

            if (GUILayout.Button("���"))
            {
                foreach (var info in myScript.infos)
                {
                    info.show &= ~(1 << i);
                }
                EditorUtility.SetDirty(target);

            }
            if (GUILayout.Button("Ԥ��"))
            {
                myScript.SetLod(i);
            }
            if (GUILayout.Button((expand[i] ? "����" : "չ��")))
            {
                expand[i] = !expand[i];
            }
            EditorGUILayout.EndHorizontal();
            if (expand[i])
            {
                foreach (var info in myScript.infos)
                {
                    if(!info.IsShow(i))
                    {
                        continue;
                    }
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.ObjectField(info.obj, typeof(GameObject), true);
                    if (GUILayout.Button("ɾ��"))
                    {
                        info.show &= ~(1 << i);
                        EditorUtility.SetDirty(target);
                        break;
                    }
                    EditorGUILayout.EndHorizontal();
                }
            }
            EditorGUILayout.Space(12);
            
            //SerializedProperty gameObjectsList = serializedObject.FindProperty(lodtxt[i]);

            //EditorGUILayout.PropertyField(gameObjectsList, true);

            //serializedObject.ApplyModifiedProperties();
        }
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("��������� �û��ӽڵ�"))
        {
            removeNull();
            EditorUtility.SetDirty(target);
        }
        if (GUILayout.Button("�ӽڵ㣿"))
        {
            Transform[] trans = targetGo.GetComponentsInChildren<Transform>();
            Debug.Log($"�ӽڵ� {trans.Length > 1}");
        }

        EditorGUILayout.EndHorizontal();
    }
}
