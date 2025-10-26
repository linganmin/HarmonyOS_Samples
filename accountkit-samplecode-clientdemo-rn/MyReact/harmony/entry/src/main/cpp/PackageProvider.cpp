/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
#include "RNOH/PackageProvider.h"
#include "generated/RNOHGeneratedPackage.h"
#include "CheckboxPackage.h"
#include "WebViewPackage.h"
#include "SafeAreaViewPackage.h"
#include "GestureHandlerPackage.h"

using namespace rnoh;

std::vector<std::shared_ptr<Package>> PackageProvider::getPackages(Package::Context ctx) {
    return {
        std::make_shared<RNOHGeneratedPackage>(ctx),
        std::make_shared<CheckboxPackage>(ctx),
        std::make_shared<WebViewPackage>(ctx),
        std::make_shared<SafeAreaViewPackage>(ctx),
        std::make_shared<GestureHandlerPackage>(ctx)
    };
}
