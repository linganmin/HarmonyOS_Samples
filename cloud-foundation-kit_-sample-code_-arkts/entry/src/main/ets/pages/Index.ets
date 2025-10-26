/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { cloudResPrefetch } from '@kit.CloudFoundationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Common } from '../common/Common';

const DOMAIN = 0x0000;
const TAG = 'Index';

@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        Button($r('app.string.cloud_function_title'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('90%')
          .height(50)
          .margin(30)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/FunctionPage'
            }).catch((err: BusinessError) => {
              hilog.error(DOMAIN, TAG, `Failed to push url, code: ${err.code}, message: ${err.message}`);
            });
          })
        Button($r('app.string.cloud_storage_label'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('90%')
          .height(50)
          .margin(30)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/StoragePage'
            }).catch((err: BusinessError) => {
              hilog.error(DOMAIN, TAG, `Failed to push url, code: ${err.code}, message: ${err.message}`);
            });
          })

        Button($r('app.string.cloud_db_label'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('90%')
          .height(50)
          .margin(30)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/CloudDatabasePage'
            }).catch((err: BusinessError) => {
              hilog.error(DOMAIN, TAG, `Failed to push url, code: ${err.code}, message: ${err.message}`);
            });
          })

        Button($r('app.string.cloud_res_prefetch_install_label'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('90%')
          .height(50)
          .margin(30)
          .onClick(() => {
            this.getPrefetchData(cloudResPrefetch.PrefetchMode.INSTALL_PREFETCH);
          })

        Button($r('app.string.cloud_res_prefetch_periodic_label'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('90%')
          .height(50)
          .margin(30)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/CloudResPrefetchPage'
            }).catch((err: BusinessError) => {
              hilog.error(DOMAIN, TAG, `Failed to push url, code: ${err.code}, message: ${err.message}`);
            });
          })
      }
      .width('100%')
    }
    .height('100%')
  }

  @Builder
  getDialogContent(msg: string | Resource, textAlign: TextAlign = TextAlign.Start, title?: string | Resource) {
    if (title) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .width('100%')
        .padding({
          top: 24,
          left: 24,
          right: 24
        })
    }
    Text(msg)
      .fontSize(16)
      .fontWeight(400)
      .width('100%')
      .padding({
        top: 24,
        bottom: 24,
        left: 24,
        right: 24
      })
      .textAlign(textAlign)
  }

  getPrefetchData(type: number) {
    let startTime = new Date().getTime();
    let desc = Common.getStringSync($r('app.string.cloud_prefetch_desc').id);
    let msg = $r('app.string.cloud_install_prefetch_description');
    cloudResPrefetch.getPrefetchResult(type)
      .then((data: cloudResPrefetch.PrefetchResult) => {
        let endTime = new Date().getTime();
        let since = endTime - startTime;
        let msg = `${desc}${since}ms:\n${JSON.stringify(data.result)}`;
        this.getUIContext().getPromptAction().openCustomDialog({
          builder: () => this.getDialogContent(msg),
          cornerRadius: 24
        }).catch((err: BusinessError) => {
          hilog.error(DOMAIN, TAG, `Failed to open custom dialog, code: ${err.code}, message: ${err.message}`);
        });
      })
      .catch((error: BusinessError) => {
        let title = $r('app.string.cloud_prefetch_desc_err');
        this.getUIContext().getPromptAction().openCustomDialog({
          builder: () => this.getDialogContent(msg, TextAlign.Start, title),
          cornerRadius: 24
        }).catch((err: BusinessError) => {
          hilog.error(DOMAIN, TAG, `Failed to open custom dialog, code: ${err.code}, message: ${err.message}`);
        });
        hilog.error(DOMAIN, TAG, `Failed to get prefetchData. code:${error.code}, message:${error.message}`);
      });
  }
}
