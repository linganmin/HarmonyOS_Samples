// [Start define_js_bridge]
// Define the JSBridge function
static void ProxyMethod1(const char* webTag, void* userData) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "ArkWeb", "Method1 webTag :%{public}s",webTag);
}

static void ProxyMethod2(const char* webTag, void* userData) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "ArkWeb", "Method2 webTag :%{public}s",webTag);
}

static void ProxyMethod3(const char* webTag, void* userData) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "ArkWeb", "Method3 webTag :%{public}s",webTag);
}

void RegisterCallback(const char *webTag) {
    int myUserData = 100;
    //Create function method structure
    ArkWeb_ProxyMethod m1 = {
        .methodName = "method1",
        .callback = ProxyMethod1,
        .userData = (void *)&myUserData
    };
    ArkWeb_ProxyMethod m2 = {
        .methodName = "method2",
        .callback = ProxyMethod2,
        .userData = (void *)&myUserData
    };
    ArkWeb_ProxyMethod m3 = {
        .methodName = "method3",
        .callback = ProxyMethod3,
        .userData = (void *)&myUserData
    };
    ArkWeb_ProxyMethod methodList[2] = {m1,m2};
    
    //Create a JSBridge object structure
    ArkWeb_ProxyObject obj = {
        .objName = "ndkProxy",
        .methodList = methodList,
        .size = 2
    };
    // Get the ArkWeb_Controller API structure
    ArkWeb_AnyNativeAPI* apis = OH_ArkWeb_GetNativeAPI(ArkWeb_NativeAPIVariantKind::ARKWEB_NATIVE_CONTROLLER);
    ArkWeb_ControllerAPI* ctrlApi = reinterpret_cast<ArkWeb_ControllerAPI*>(apis);

        // Call the registration interface, registration function
        ctrlApi->registerJavaScriptProxy(webTag, &obj);
    
    ArkWeb_ProxyMethod asyncMethodList[1] = {m3};
    ArkWeb_ProxyObject obj2 = {
        .objName = "ndkProxy",
    .methodList = asyncMethodList,
    .size = 1
    };
    ctrlApi->registerAsyncJavaScriptProxy(webTag, &obj2);
}
// [End define_js_bridge]