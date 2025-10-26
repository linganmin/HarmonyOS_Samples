/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { productViewManager } from '@kit.AppGalleryKit';

const TAG: string = 'LoadService';

@Entry
@Component
struct LoadService {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    Column() {
      Button($r("app.string.load_service"))
        .id('load_service')
        .onClick(() => {
          try {
            const request: Want = {
              uri: 'store://appgallery.huawei.com/oper/addhome?referrer=xxx&id=xxx&installType=xxx&s=xxx'
            };
            productViewManager.loadService(this.context, request, {

              onReceive: (data: productViewManager.ServiceViewReceiveData) => {
                hilog.info(0, TAG, `loadService onReceive.result is ${data.result}, msg is ${data.msg}, formInfo is ${JSON.stringify(data.formInfo)}`);
              },
              onError: (error: BusinessError) => {
                hilog.error(0, TAG, `loadService onError.code is ${error.code}, message is ${error.message}`)
              },
              onAppear: () => {
                hilog.info(0, TAG, `loadService onAppear.`);
              },
              onDisappear: () => {
                hilog.info(0, TAG, `loadService onDisappear.`);
              }
            });
          } catch (error) {
            hilog.error(0, TAG, `loadService failed.code is ${(error as BusinessError).code}, message is ${(error as BusinessError).message}`);
          }
        })
        .width('100%')

    }
    .margin(16)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}