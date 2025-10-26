/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
 
#ifndef STORE_KIT_LOG_HPP
#define STORE_KIT_LOG_HPP
#include <hilog/log.h>
 
constexpr unsigned int FG_DOMAIN = 0xD005810;
#define LOGI(...) ((void)OH_LOG_Print(LOG_APP, LOG_INFO, FG_DOMAIN, "[fido2ndk]", __VA_ARGS__))
#define LOGD(...) ((void)OH_LOG_Print(LOG_APP, LOG_DEBUG, FG_DOMAIN, "[fido2ndk]", __VA_ARGS__))
#define LOGW(...) ((void)OH_LOG_Print(LOG_APP, LOG_WARN, FG_DOMAIN, "[fido2ndk]", __VA_ARGS__))
#define LOGE(...) ((void)OH_LOG_Print(LOG_APP, LOG_ERROR, FG_DOMAIN, "[fido2ndk]", __VA_ARGS__))
 
#endif // STORE_KIT_LOG_HPP