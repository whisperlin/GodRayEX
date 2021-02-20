using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Lightbeam))]
public class LightbeamTexture : MonoBehaviour
{

 
    public Camera cam;
    public float offset = 1f;
 
    public Shader shader;
    //public 


    // Update is called once per frame
    void LateUpdate()
    {
   
        if (null == cam)
        {
            cam = new GameObject("Lightbeam Camera").AddComponent<Camera>();
            cam.gameObject.transform.parent = transform;

        }
        if (null == lightbeam)
        {
            lightbeam = GetComponent<Lightbeam>();
        }
        if (null == meshRenderer)
        {
            meshRenderer = GetComponent<MeshRenderer>();
        }

        if (null == shader)
            shader = Shader.Find("Lightbeam/DepthShader");
 

        cam.transform.localPosition = Vector3.zero;
        cam.transform.forward = -transform.up;
        if (null == rt)
            rt = new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32);
        cam.targetTexture = rt;
        cam.enabled = false;
        RenderTexture();
    }

    readonly int _WorldToLightbeam = Shader.PropertyToID("_WorldToLightbeam");
    readonly int LightbeamDepth = Shader.PropertyToID("LightbeamDepth");
    public RenderTexture rt;
    public Lightbeam lightbeam;
    public MeshRenderer meshRenderer;

    private void RenderTexture()
    {
        meshRenderer.enabled = false;
 
        cam.backgroundColor = Color.black;
        cam.clearFlags = CameraClearFlags.SolidColor;

        cam.transform.localPosition = transform.up*offset;
        cam.transform.forward = -transform.up;
        cam.SetReplacementShader(shader, "");
 
        cam.targetTexture = rt;
 


        Shader.SetGlobalTexture(LightbeamDepth, rt);


        Matrix4x4 V = cam.worldToCameraMatrix;
        Matrix4x4 P = GL.GetGPUProjectionMatrix(cam.projectionMatrix, true);
        Matrix4x4 VP = P * V;

 

       // Shader.SetGlobalMatrix(_WorldToLightbeam, VP);

        cam.Render();
        var mat = meshRenderer.sharedMaterial;
        mat.EnableKeyword("LIGHT_BEAM_DEPTH");
        mat.SetMatrix(_WorldToLightbeam, VP);
        Shader.DisableKeyword("LIGHT_BEAM_DEPTH");
        meshRenderer.enabled = true;
    }
     
}
