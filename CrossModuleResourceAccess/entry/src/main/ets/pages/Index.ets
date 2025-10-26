/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// [Start createModuleContext_start]
import { application, common } from '@kit.AbilityKit';
// [End createModuleContext_start]
import { Har1Page } from 'har1';
import { Hsp1Page } from 'hsp1';
import { Logger } from '../common/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'Index';

@Entry
@Component
struct Index {
  private navPathStack: NavPathStack = new NavPathStack();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    try {
      // [Start resourceManager_start]
      let stringInHar1 = this.context.resourceManager.getStringSync($r('app.string.access_resource_har1').id);
      let imgArrayInHar1 = this.context.resourceManager.getMediaContentSync($r('app.media.image_in_har1').id);
      // [End resourceManager_start]
      Logger.info(`string in har1 is:${stringInHar1}`);
      Logger.info(`image in har1 array length is:${imgArrayInHar1.buffer.byteLength}`);
      // use resourceManager get resource from hsp1
      // [Start createModuleContext_start]
      application.createModuleContext(this.context, 'hsp1').then(data => {
        let stringInHsp1 = data.resourceManager.getStringByNameSync('string_in_hsp1');
        let imgArrayInHsp2 = data.resourceManager.getMediaByNameSync('image_in_hsp1');
        // [StartExclude createModuleContext_start]
        Logger.info(`string in hsp1 is:${stringInHsp1}`);
        Logger.info(`image in hsp1 array length is:${imgArrayInHsp2.buffer.byteLength}`);
        // [EndExclude createModuleContext_start]
      })
      // [End createModuleContext_start]
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `get reource err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }

  @Builder
  PageMap(name: string) {
    if (name === 'Har1Page') {
      Har1Page()
    } else if (name === 'Hsp1Page') {
      Hsp1Page()
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column() {
        Column() {
          Text($r('app.string.access_resource_har1'))
            .fontSize(20)
            .fontWeight(700)
            .width('100%')
            .margin({ bottom: 2 })
          Text($r('app.string.string_in_har1'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize(16)
            .width('100%')
          Image($r('app.media.image_in_har1'))
            .width('100%')
            .height(150)
            .objectFit(ImageFit.TOP_START)
            .constraintSize({ maxWidth: 360 })
            .borderRadius(8)
            .margin({ top: 8 })
        }

        Column() {
          // [Start string_hsp1]
          Text($r('app.string.access_resource_hsp1'))
            // [End string_hsp1]
            .fontSize(20)
            .fontWeight(700)
            .width('100%')
            .margin({ bottom: 2 })
          // [Start string_hsp1]
          Text($r('[hsp1].string.string_in_hsp1'))
            // [End string_hsp1]
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize(16)
            .width('100%')
          // [Start string_hsp1]
          Image($r('[hsp1].media.image_in_hsp1'))
            // [End string_hsp1]
            .width('100%')
            .height(150)
            .objectFit(ImageFit.TOP_START)
            .constraintSize({ maxWidth: 360 })
            .borderRadius(8)
            .margin({ top: 8 })
        }
        .margin({ top: 24 })

        Blank()

        Button($r('app.string.jump_to_har1'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPathByName('Har1Page', '');
          })
        Button($r('app.string.jump_to_hsp1'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.navPathStack.pushPathByName('Hsp1Page', '');
          })
      }
      .padding(16)
      .height('100%')
      .width('100%')
    }
    .mode(NavigationMode.Stack)
    .title('Entry page')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .backgroundColor($r('sys.color.background_secondary'))
    .navDestination(this.PageMap)
  }
}