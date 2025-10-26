//
// Created on 2025/6/3.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include <cstring>
/**
 * 应用事件
 */
#include "napi/native_api.h"
#include "json/json.h"
#include "hilog/log.h"
#include "hiappevent/hiappevent.h"

#undef LOG_TAG
#define LOG_TAG "testTag"

// [Start application_events3]
//Define a variable to cache pointers to observers created.
static HiAppEvent_Watcher *appEventWatcher;


// Developers can implement callback functions to retrieve events that have been monitored, where the events pointer points to content that is only valid within that function.
static void OnTake(const char *const *events, uint32_t eventLen) {
    Json::Reader reader(Json::Features::strictMode());
    for (int i = 0; i < eventLen; ++i) {
        OH_LOG_INFO(LogType::LOG_APP, "HiAppEvent eventInfo=%{public}s", events[i]);
        Json::Value eventInfo;
        if (reader.parse(events[i], eventInfo)) {
            auto domain = eventInfo["domain_"].asString();
            auto name = eventInfo["name_"].asString();
            auto type = eventInfo["type_"].asInt();
            OH_LOG_INFO(LogType::LOG_APP, "HiAppEvent eventInfo.domain=%{public}s", domain.c_str());
            OH_LOG_INFO(LogType::LOG_APP, "HiAppEvent eventInfo.name=%{public}s", name.c_str());
            OH_LOG_INFO(LogType::LOG_APP, "HiAppEvent eventInfo.eventType=%{public}d", type);
            if (domain == "button" && name == "click") {
                auto clickTime = eventInfo["click_time"].asInt64();
                OH_LOG_INFO(LogType::LOG_APP, "HiAppEvent eventInfo.params.click_time=%{public}lld", clickTime);
            }
        }
    }
}


// Developers can implement subscription callback functions themselves to customize the processing of event data obtained.
static void OnTrigger(int row, int size) {
    // After receiving the callback, retrieve the specified number of received events.
    OH_HiAppEvent_TakeWatcherData(appEventWatcher, row, OnTake);
}


static napi_value RegisterWatcher(napi_env env, napi_callback_info info) {
    // Developers customize observer names, and the system identifies different observers based on different names.
    appEventWatcher = OH_HiAppEvent_CreateWatcher("onTriggerWatcher");
    // Set the event name for the subscription to click.
    const char *names[] = {"click"};
    // Developers subscribe to application events of interest, and button related events are subscribed here.
    OH_HiAppEvent_SetAppEventFilter(appEventWatcher, "button", 0, names, 1);
    // Developers need to meet the conditions set by OH_SiAppEvent_SetTriggerCondition to trigger implemented callback functions.
    OH_HiAppEvent_SetWatcherOnTrigger(appEventWatcher, OnTrigger);
    // Developers can set the conditions for subscription triggered callbacks, where the onTrigger callback is triggered when the number of new event dots is set to 1.
    OH_HiAppEvent_SetTriggerCondition(appEventWatcher, 1, 0, 0);
    // Enable the observer to start monitoring subscribed events.
    OH_HiAppEvent_AddWatcher(appEventWatcher);
    return {};
}
// [End application_events3]
