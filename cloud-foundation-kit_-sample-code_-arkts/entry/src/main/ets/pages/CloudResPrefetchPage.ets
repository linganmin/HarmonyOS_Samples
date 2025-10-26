/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { cloudResPrefetch } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Common } from '../common/Common';

const DOMAIN = 0x0000;
const TAG = 'CloudResPrefetchPage';

@Entry
@Component
struct CloudResPrefetchPage {
  @State prefetchData: string = '';

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

  build() {
    Column() {
      Navigation()
        .title($r('app.string.cloud_periodic_prefetch_title'))
        .height('50vp')
        .width('100%')
        .margin({ bottom: 10 })
        .titleMode(NavigationTitleMode.Mini)
      Text($r('app.string.cloud_periodic_prefetch_description'))
        .width('90%')
        .textAlign(TextAlign.Start)
        .margin({
          top: 20,
          bottom: 20
        })
        .fontSize($r('app.float.body_font_size'))

      Column() {
        Button({ type: ButtonType.Normal }) {
          Text($r('app.string.cloud_prefetch_registerTask_text'))
            .fontColor($r('app.color.white'))
            .margin({
              top: 5,
              bottom: 5
            })
        }
        .width('90%')
        .borderRadius($r('sys.float.corner_radius_level4'))
        .height('30vp')
        .margin({ top: 20 })
        .onClick(() => {
          try {
            cloudResPrefetch.registerPrefetchTask({});
            this.getUIContext().getPromptAction().openCustomDialog({
              builder: () => this.getDialogContent($r('app.string.cloud_prefetch_register'), TextAlign.Center),
              cornerRadius: 24
            }).catch((err: BusinessError) => {
              hilog.error(DOMAIN, TAG, `Failed to get dialog content, code: ${err.code}, message: ${err.message}`);
            });
          } catch (err) {
            hilog.error(DOMAIN, TAG, `Failed to register prefetch task, code: ${err.code}, message: ${err.message}`);
          }
        })

        Button({ type: ButtonType.Normal }) {
          Text($r('app.string.cloud_prefetch_periodic_text'))
            .fontColor($r('app.color.white'))
            .margin({
              top: 5,
              bottom: 5
            })
        }
        .width('90%')
        .borderRadius($r('sys.float.corner_radius_level4'))
        .height('30vp')
        .margin({ top: 20 })
        .onClick(() => {
          let startTime = new Date().getTime();
          let desc = Common.getStringSync($r('app.string.cloud_prefetch_desc').id);
          cloudResPrefetch.getPrefetchResult(cloudResPrefetch.PrefetchMode.PERIODIC_PREFETCH)
            .then((res: cloudResPrefetch.PrefetchResult) => {
              let endTime = new Date().getTime();
              let since = endTime - startTime;
              let msg = `${desc}${since}ms:\n${JSON.stringify(res.result)}`;
              this.getUIContext().getPromptAction().openCustomDialog({
                builder: () => this.getDialogContent(msg),
                cornerRadius: 24
              }).catch((err: BusinessError) => {
                hilog.error(DOMAIN, TAG, `Failed to get dialog content, code: ${err.code}, message: ${err.message}`);
              });
            })
            .catch((err: BusinessError) => {
              hilog.error(DOMAIN, 'testTag', `Failed to get prefetch data: code: ${err.code}, message: ${err.message}`);
              this.getUIContext().getPromptAction().openCustomDialog({
                builder: () => this.getDialogContent($r('app.string.cloud_prefetch_desc_err')),
                cornerRadius: 24
              }).catch((err: BusinessError) => {
                hilog.error(DOMAIN, TAG, `Failed to get dialog content, code: ${err.code}, message: ${err.message}`);
              });
            });
        })
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
  }
}
