/**
 * 应用事件
 */
#include <cstring>
// [Start application_events1]
#include "napi/native_api.h"
#include "json/json.h"
#include "hilog/log.h"
#include "hiappevent/hiappevent.h"

#undef LOG_TAG
#define LOG_TAG "testTag"
// [End application_events1]

// [Start application_events2]
static HiAppEvent_Watcher *appEventWatcher;


static void OnReceive(const char *domain, const struct HiAppEvent_AppEventGroup *appEventGroups, uint32_t groupLen) {
    for (int i = 0; i < groupLen; ++i) {
        for (int j = 0; j < appEventGroups[i].infoLen; ++j) {
            OH_LOG_INFO(LogType::LOG_APP, "HiAppEvent eventInfo.domain=%{public}s", appEventGroups[i].appEventInfos[j].domain);
            OH_LOG_INFO(LogType::LOG_APP, "HiAppEvent eventInfo.name=%{public}s", appEventGroups[i].appEventInfos[j].name);
            OH_LOG_INFO(LogType::LOG_APP, "HiAppEvent eventInfo.eventType=%{public}d", appEventGroups[i].appEventInfos[j].type);
            if (strcmp(appEventGroups[i].appEventInfos[j].domain, "button") == 0 &&
                strcmp(appEventGroups[i].appEventInfos[j].name, "click") == 0) {
                Json::Value params;
                Json::Reader reader(Json::Features::strictMode());
                if (reader.parse(appEventGroups[i].appEventInfos[j].params, params)) {
                    auto time = params["click_time"].asInt64();
                    OH_LOG_INFO(LogType::LOG_APP, "HiAppEvent eventInfo.params.click_time=%{public}lld", time);
                }
            }
        }
    }
}


static napi_value RegisterWatcher(napi_env env, napi_callback_info info) {
    // Developers customize observer names, and the system identifies different observers based on different names.
    appEventWatcher = OH_HiAppEvent_CreateWatcher("onReceiverWatcher");
    // Set the event name for the subscription to click.
    const char *names[] = {"click"};
    // Developers subscribe to application events of interest, and button related events are subscribed here.
    OH_HiAppEvent_SetAppEventFilter(appEventWatcher, "button", 0, names, 1);
    // The developer sets the implemented callback function, and the observer immediately triggers the OnReceive callback upon receiving the event.
    OH_HiAppEvent_SetWatcherOnReceive(appEventWatcher, OnReceive);
    // Enable the observer to start monitoring subscribed events.
    OH_HiAppEvent_AddWatcher(appEventWatcher);
    return {};
}
// [End application_events2]


// [Start application_events4]
static napi_value WriteAppEvent(napi_env env, napi_callback_info info) {
    auto params = OH_HiAppEvent_CreateParamList();
    OH_HiAppEvent_AddInt64Param(params, "click_time", time(nullptr));
    OH_HiAppEvent_Write("button", "click", EventType::BEHAVIOR, params);
    OH_HiAppEvent_DestroyParamList(params);
    return {};
}
// [End application_events4]

// [Start application_events9]
static napi_value RemoveWatcher(napi_env env, napi_callback_info info) {
    // Make the observer stop listening to the event
    OH_HiAppEvent_RemoveWatcher(appEventWatcher);
    return {};
}
// [End application_events9]

// [Start application_events10]
static napi_value DestroyWatcher(napi_env env, napi_callback_info info) {
    // Destroy the created observer and set appEventWatcher to null ptr.
    OH_HiAppEvent_DestroyWatcher(appEventWatcher);
    appEventWatcher = nullptr;
    return {};
}
// [End application_events10]

EXTERN_C_START
// [Start application_events5]
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"registerWatcher", nullptr, RegisterWatcher, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"writeAppEvent", nullptr, WriteAppEvent, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
// [End application_events5]
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterLibcppModule(void)
{
    napi_module_register(&demoModule);
}
