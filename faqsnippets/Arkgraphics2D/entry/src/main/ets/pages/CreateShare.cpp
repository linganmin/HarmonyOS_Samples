/*
* FAQ:EGL绘制是否支持多线程？如何在多线程的场景下同时操作一块buffer进行图形绘制
 */
// [Start CreateShareEglContext]
void CreateShareEglContext() 
{
  if (renderContext == nullptr) { // RenderContext is the main thread context 
    RS_LOGE("renderContext_ is nullptr");
    return;
  }
  eglShareContext = renderContext->CreateShareContext(); // Create share context 
  if (eglShareContext == EGL_NO_CONTEXT) {
    RS_LOGE("eglShareContext is EGL_NO_CONTEXT");
    return;
  }
  if (!eglMakeCurrent(renderContext->GetEGLDisplay(), EGL_NO_SURFACE, EGL_NO_SURFACE, eglShareContext)) {
    RS_LOGE("eglMakeCurrent failed");
    return;
  }
}
// [End CreateShareEglContext]