/*
* FAQ:ABR进行Buffer分辨率调整引起其他Pass渲染效果异常，该如何解决？
 */
// [Start SetPerCameraShaderVariables1]
void SetPerCameraShaderVariables(CommandBuffer cmd, ref CameraData cameraData, bool isTargetFlipped)
{
    Camera camera = cameraData.camera;
    float scaledCameraWidth = (float)cameraData.cameraTargetDescriptor.width;
    float scaledCameraHeight = (float)cameraData.cameraTargetDescriptor.height;
    // The scale is the ABR Buffer resolution factor obtained through the HMS-ABR_SetScale interface
    scaledCameraWidth *= scale;
    scaledCameraHeight *= scale;
    cmd.SetGlobalVector(ShaderPropertyId.scaledScreenParams, new Vector4(scaledCameraWidth, scaledCameraHeight, 1.0f + 1.0f / scaledCameraWidth, 1.0f + 1.0f / scaledCameraHeight));
}
// [End SetPerCameraShaderVariables1]
// [Start SetPerCameraShaderVariables2]
// Called after Buffer rendering
float scale = 1.0f;
errorCode = HMS_ABR_GetNextScale(context_, &scale);
if (errorCode != ABR_SUCCESS) {
    GOLOGE("HMS_ABR_GetNextScale execution failed, error code: %d.", errorCode);
}

// Synchronize and adjust rendering data based on Buffer resolution factor
void SetViewUniformParameters()
{
    ViewUniformParameters.BufferSize.X = (int)(ViewUniformParameters.BufferSize.X * scale);
    ViewUniformParameters.BufferSize.Y = (int)(ViewUniformParameters.BufferSize.Y * scale);
    ViewUniformParameters.BufferInvSize.X /= scale;
    ViewUniformParameters.BufferInvSize.Y /= scale;
}
// [End SetPerCameraShaderVariables2]