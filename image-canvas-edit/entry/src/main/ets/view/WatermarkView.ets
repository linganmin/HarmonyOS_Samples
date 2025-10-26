/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { WatermarkPosition, WatermarkConfig } from '../utils/WatermarkUtil';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { image } from '@kit.ImageKit';
import { PixelMapManager } from '../utils/PixelMapManager';

const DOMAIN = 0xFF00;
const TAG = 'WatermarkView';

@Component
export struct WatermarkView {
  @Consume pixelMap: PixelMap | undefined;
  @Consume previewPixelMap: PixelMap | undefined;
  @Consume pixelMapManager?: PixelMapManager;
  @Consume('pixelMapInit') pixelMapInit: image.PixelMap;
  flushPixelMapChange: () => void = () => {
  };
  @State watermarkText: string = '';
  @State currentPosition: WatermarkPosition = WatermarkPosition.BOTTOM_RIGHT;
  @State fontSize: number = 24;
  @State watermarkOpacity: number = 0.8;
  @State watermarkColor: string = '#FFFFFF';
  @State rotation: number = 0;
  @State isRepeated: boolean = false;
  @State hasWatermark: boolean = false;
  @State originalPixelMap: PixelMap | undefined = undefined;

  aboutToAppear() {
    if (this.previewPixelMap && !this.originalPixelMap) {
      this.originalPixelMap = this.previewPixelMap;
    }
  }

  @Builder
  positionBtn(name: Resource, styleName: number) {
    Row() {
      Button(name, {
        controlSize: ControlSize.SMALL,
        buttonStyle: this.currentPosition === styleName ? ButtonStyleMode.EMPHASIZED :
          ButtonStyleMode.NORMAL
      })
        .fontSize(14)
        .fontColor(this.currentPosition === styleName ? '#FFFFFF' : '#99000000')
        .fontWeight(FontWeight.Medium)
        .padding({
          left: 16,
          right: 16
        })
        .onClick(() => {
          this.currentPosition = styleName;
        })

        .height(28)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(70)
    .height(28)
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.watermark_text'))
              .fontSize(16)
              .fontWeight(500)
            TextInput({ placeholder: $r('app.string.watermark_text') })
              .fontColor('#E5')
              .backgroundColor('#F5F5F5')
              .placeholderColor($r('sys.color.mask_secondary'))
              .padding({ left: 12, right: 12 })
              .width(120)
              .height(32)
              .onChange((value: string) => {
                this.watermarkText = value;
              })
          }
          .padding({ top: 13, bottom: 13 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          Divider()
            .strokeWidth(0.5)
            .color($r('sys.color.mask_fourth'))

          Column() {
            Row() {
              Text($r('app.string.watermark_position'))
                .fontSize(16)
                .fontWeight(500)
              Row() {
              }
              .width('10%')
            }
            .width('100%')
            .padding({ bottom: 13 })
            .justifyContent(FlexAlign.SpaceBetween)

            Tabs({ barPosition: BarPosition.End }) {
              TabContent().tabBar(this.positionBtn($r('app.string.position_top_left'), WatermarkPosition.TOP_LEFT))

              TabContent()
                .tabBar(this.positionBtn($r('app.string.position_top_right'), WatermarkPosition.TOP_RIGHT))


              TabContent()
                .tabBar(this.positionBtn($r('app.string.position_bottom_left'), WatermarkPosition.BOTTOM_LEFT))

              TabContent()
                .tabBar(this.positionBtn($r('app.string.position_bottom_right'), WatermarkPosition.BOTTOM_RIGHT))


              TabContent()
                .tabBar(this.positionBtn($r('app.string.position_center'), WatermarkPosition.CENTER))
            }
            .vertical(false)
            .scrollable(true)
            .barMode(BarMode.Scrollable)
            .barHeight(80)
            .animationDuration(400)
            .onChange((index: number) => {
              hilog.info(DOMAIN, TAG, '%{public}s', index.toString());
            })
            .fadingEdge(false)
            .barHeight(28)
            .height(30)
            .width('100%')
          }
          .padding({ top: 13, bottom: 13 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Divider()
            .strokeWidth(0.5)
            .color($r('sys.color.mask_fourth'))

          Row() {
            Text($r('app.string.watermark_size'))
              .fontSize(16)
              .fontWeight(500)
            Text(`${this.fontSize}px`)
              .fontSize(14)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .padding({ top: 13, bottom: 13 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          Row() {
            Slider({
              value: this.fontSize,
              min: 12,
              max: 72,
              step: 1
            })
              .width('100%')
              .trackColor('#F5F5F5')
              .onChange((value: number) => {
                this.fontSize = Math.round(value);
              })
          }
          .padding({ bottom: 13 })
          .width('100%')

          Divider()
            .strokeWidth(0.5)
            .color($r('sys.color.mask_fourth'))

          Row() {
            Text($r('app.string.watermark_opacity'))
              .fontSize(16)
              .fontWeight(500)
            Text(`${Math.round(this.watermarkOpacity * 100)}%`)
              .fontSize(14)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .padding({ top: 13, bottom: 13 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          Row() {
            Slider({
              value: this.watermarkOpacity,
              min: 0.1,
              max: 1.0,
              step: 0.1
            })
              .width('100%')
              .trackColor('#F5F5F5')
              .onChange((value: number) => {
                this.watermarkOpacity = Math.round(value * 10) / 10;
              })
          }
          .padding({ bottom: 13 })
          .width('100%')

          Divider()
            .strokeWidth(0.5)
            .color($r('sys.color.mask_fourth'))

          Row() {
            Text($r('app.string.watermark_rotation'))
              .fontSize(16)
              .fontWeight(500)
            Text(`${this.rotation}°`)
              .fontSize(14)
              .fontColor($r('sys.color.mask_secondary'))
          }
          .padding({ top: 13, bottom: 13 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          Row() {
            Slider({
              value: this.rotation,
              min: -45,
              max: 45,
              step: 1
            })
              .width('100%')
              .trackColor('#F5F5F5')
              .onChange((value: number) => {
                this.rotation = Math.round(value);
              })
          }
          .padding({ bottom: 13 })
          .width('100%')

          Divider()
            .strokeWidth(0.5)
            .color($r('sys.color.mask_fourth'))

          Row() {
            Text($r('app.string.watermark_repeat'))
              .fontSize(16)
              .fontWeight(500)
            Toggle({ type: ToggleType.Switch, isOn: this.isRepeated })
              .switchPointColor($r('sys.color.comp_background_list_card'))
              .onChange((isOn: boolean) => {
                this.isRepeated = isOn;
              })
          }
          .padding({ top: 13, bottom: 13 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          Divider()
            .strokeWidth(0.5)
            .color($r('sys.color.mask_fourth'))

          Row({ space: 12 }) {
            Button($r('app.string.add_watermark'),
              {
                buttonStyle: ButtonStyleMode.NORMAL,
                role: ButtonRole.NORMAL,
              })
              .opacity(this.watermarkText.length > 0 ? 1 : 0.4)
              .fontSize(14)
              .borderRadius(8)
              .width('calc(50% - 6vp)')
              .height(36)
              .enabled(this.watermarkText.length > 0)
              .onClick(() => {
                this.addWatermark();
              })

            Button($r('app.string.remove_watermark'), { buttonStyle: ButtonStyleMode.NORMAL, role: ButtonRole.ERROR })
              .opacity(this.watermarkText.length > 0 ? 1 : 0.4)
              .fontSize(14)
              .borderRadius(8)
              .width('calc(50% - 6vp)')
              .height(36)
              .enabled(this.hasWatermark)
              .onClick(() => {
                this.removeWatermark();
              })
          }
          .padding({
            top: 20,
            bottom: 16,
          })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .padding({
        top: 4,
        bottom: 4,
      })
      .backgroundColor('#FFF')
      .borderRadius(16)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .friction(0.6)
      .edgeEffect(EdgeEffect.None)
    }
    .width('100%')
  }

  // Add watermark
  private async addWatermark() {
    if (!this.previewPixelMap || this.watermarkText.trim() === '') {
      return;
    }
    try {
      const config: WatermarkConfig = {
        text: this.watermarkText,
        position: this.currentPosition,
        fontSize: this.fontSize,
        color: this.watermarkColor,
        opacity: this.watermarkOpacity,
        rotation: this.rotation
      };

      if (this.isRepeated) {
        this.pixelMapManager?.addRepeatedWatermark(this.previewPixelMap, config);
      } else {
        this.pixelMapManager?.addTextWatermark(this.previewPixelMap, config);
      }

      this.flushPixelMapChange();
      this.hasWatermark = true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s, %{public}s', 'Adding watermark failed:', JSON.stringify(error));
    }
  }

  private removeWatermark() {
    if (this.originalPixelMap) {
      this.previewPixelMap = this.originalPixelMap;
      this.hasWatermark = false;
      this.flushPixelMapChange();
    }
  }
}