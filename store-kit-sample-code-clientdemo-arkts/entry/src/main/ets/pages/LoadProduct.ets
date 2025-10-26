/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { productViewManager } from '@kit.StoreKit';

const TAG: string = 'LoadProduct';

@Entry
@Component
struct LoadProduct {
  context = getContext(this) as common.UIAbilityContext;

  build() {
    Column() {
      Button($r("app.string.load_product"))
        .id('load_product')
        .onClick(() => {
          try {
            let params: Record<string, string> = { 'bundleName': 'com.huawei.hmsapp.appgallery' };
            const request: Want = {
              parameters: params
            };
            productViewManager.loadProduct(this.context, request, {
              onError: (error: BusinessError) => {
                hilog.error(0, TAG, `loadProduct onError. code is ${error.code}, message is ${error.message}`);
              }
            });
          } catch (error) {
            hilog.error(0, TAG, `loadProduct failed. code is ${(error as BusinessError).code}, message is ${(error as BusinessError).message}`);
          }
        })
        .width('100%')

    }
    .margin(16)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}