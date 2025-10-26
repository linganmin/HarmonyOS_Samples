/*
* FAQ:集成ABR后，从游戏引擎获取到的Native纹理内容为空，该如何解决?
 */
// [Start GetScaledTexture]
// Called after Buffer rendering
GLuint originTexture;
GLuint scaledTexture;
errorCode = HMS_ABR_GetScaledTexture_GLES(context_, originTexture, &scaledTexture);
if (errorCode != ABR_SUCCESS) {
    GOLOGE("HMS_ABR_GetScaledTexture_GLES execution failed, error code: %d.", errorCode);
}
// [End GetScaledTexture]