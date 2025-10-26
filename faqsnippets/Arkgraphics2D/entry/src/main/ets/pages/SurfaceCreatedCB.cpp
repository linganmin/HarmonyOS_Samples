/*
* FAQ:如何主动关闭CPU访问窗口缓冲区数据降低功耗
 */
// [Start OnSurfaceCreatedCB]
void OnSurfaceCreatedCB(OH_NativeXComponent *component, void *window) {    
    uint64_t usage = 0;
    int32_t ret = OH_NativeWindow_NativeWindowHandleOpt((OHNativeWindow*)window, GET_USAGE, &usage);
    usage &= ~NATIVEBUFFER_USAGE_CPU_READ;
    int32_t ret2 = OH_NativeWindow_NativeWindowHandleOpt((OHNativeWindow*)window, SET_USAGE, usage);
}
// [End OnSurfaceCreatedCB]