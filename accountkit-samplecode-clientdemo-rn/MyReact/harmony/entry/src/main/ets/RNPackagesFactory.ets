/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import type { RNPackageContext, RNPackage } from '@rnoh/react-native-openharmony/ts';
import { RNHuaweiAuthPackage } from 'react-native-huawei-authentication/ts';
import { WebViewPackage } from '@react-native-oh-tpl/react-native-webview/ts';
import { SafeAreaViewPackage } from '@react-native-oh-tpl/react-native-safe-area-context/ts';
import { RNCCheckBoxPackage } from '@react-native-ohos/checkbox/ts';
import { RNLocalizePackage } from '@react-native-oh-tpl/react-native-localize/ts';
import GestureHandlerPackage from '@react-native-oh-tpl/react-native-gesture-handler';

export function createRNPackages(ctx: RNPackageContext): RNPackage[] {
  return [
    new RNHuaweiAuthPackage(ctx),
    new WebViewPackage(ctx),
    new SafeAreaViewPackage(ctx),
    new RNCCheckBoxPackage(ctx),
    new RNLocalizePackage(ctx),
    new GestureHandlerPackage(ctx)
  ];
}
