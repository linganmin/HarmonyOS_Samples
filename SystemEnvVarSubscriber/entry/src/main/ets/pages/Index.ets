/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import Logger from '../common/Logger';

const TAG = 'IndexLogTag';

@Entry
@Component
struct Index {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @StorageLink('systemLanguage') systemLanguage: string | undefined = this.context.config.language;
  @StorageLink('colorMode') colorMode: ConfigurationConstant.ColorMode | undefined = this.context.config.colorMode;
  @StorageLink('hasPointerDevice') hasPointerDevice: boolean | undefined = this.context.config.hasPointerDevice;
  @StorageLink('fontSizeScale') fontSizeScale: number | undefined = this.context.config.fontSizeScale;
  @StorageLink('fontWeightScale') fontWeightScale: number | undefined = this.context.config.fontWeightScale;
  @State screenDirection: display.Orientation = display.Orientation.PORTRAIT;
  @State screenDensity: number = 0;
  @State displayId: number = 0;

  getScreenData() {
    try {
      let displayInstance = display.getDefaultDisplaySync();
      this.screenDirection = displayInstance.orientation;
      this.screenDensity = displayInstance.densityDPI;
      this.displayId = displayInstance.id;
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getDefaultDisplaySync err, code: ${error.code}, mesage: ${error.message}`);
    }
  }

  aboutToAppear(): void {
    this.getScreenData();
    display.on('change', (data: number) => {
      Logger.info(`Listening enabled. Data: ${data}`);
      this.getScreenData();
    });
  }

  aboutToDisappear(): void {
    display.off('change', (data: number) => {
      Logger.info(`Succeeded in unregistering the callback for display remove. Data: ${JSON.stringify(data)}`);
    });
  }

  build() {
    Scroll() {
      Column() {
        Text($r('app.string.page_title'))
          .width('100%')
          .fontWeight(700)
          .fontSize(30)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.ohos_id_color_primary'))
          .padding({
            left: 12,
            top: 64,
            right: 20,
            bottom: 8
          })

        List() {
          ListItem() {
            EnvVarItem({ title: $r('app.string.item_system_language'), text: this.systemLanguage })
          }

          ListItem() {
            EnvVarItem({ title: $r('app.string.item_color_mode'), text: this.colorMode?.toString() })
          }

          ListItem() {
            EnvVarItem({ title: $r('app.string.item_screen_direction'), text: this.screenDirection.toString() })
          }

          ListItem() {
            EnvVarItem({ title: $r('app.string.item_screen_density'), text: this.screenDensity.toString() })
          }

          ListItem() {
            EnvVarItem({ title: $r('app.string.item_display_id'), text: this.displayId.toString() })
          }

          ListItem() {
            EnvVarItem({ title: $r('app.string.item_has_pointer_device'), text: this.hasPointerDevice?.toString() })
          }

          ListItem() {
            EnvVarItem({ title: $r('app.string.item_fontsize_scale'), text: this.fontSizeScale?.toString() })
          }

          ListItem() {
            EnvVarItem({ title: $r('app.string.item_font_weight_scale'), text: this.fontWeightScale?.toString() })
          }
        }
        .divider({
          strokeWidth: 1,
          color: '#F5F5F5'
        })
        .borderRadius(16)
        .width('calc(100% - 32vp)')
        .height(391)
        .backgroundColor(Color.White)
        .margin({ top: 18 })
        .padding({
          left: 12,
          right: 12
        })
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .backgroundColor('#F1F3F5')
    .width('100%')
    .height('100%')
  }
}

@Component
struct EnvVarItem {
  title: ResourceStr = '';
  @Prop text: string;

  build() {
    Row() {
      Text(this.title)
        .fontWeight(500)
        .fontSize(16)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
      Text(this.text)
        .fontWeight(400)
        .fontSize(14)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height(48)
    .width('100%')
  }
}