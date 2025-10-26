/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { PixelMapManager } from '../pages/PixelMapManager';
import { CommonConstants } from '../common/constant/CommonConstants';

interface translateListType {
  icon: string,
  title: Resource | string,
  color: string,
  selectColor: string
}

@Component
export default struct TranslateView {
  pixelMapManager?: PixelMapManager;

  @Consume currentTranslateData: number[];
  @Consume currentTranslateMode: number;
  @State translateList: translateListType[] = [
    {
      icon: 'camera_panopor_horizontal',
      title: $r('app.string.horizontal'),
      color: '#fff',
      selectColor: '#ff000000'
    },
    {
      icon: 'camera_panover_vertical',
      title: $r('app.string.vertical'),
      color: '#fff',
      selectColor: '#ff000000'
    },
  ];

  onTranslateChange?: (value: number, mode: SliderChangeMode) => void;

  build() {
    Column() {
      Row() {
        Slider({
          value: this.currentTranslateData[this.currentTranslateMode],
          step: 1,
          min: 0,
          max: 1000
        })
          .trackColor('#1affffff')
          .selectedColor(Color.White)
          .width(CommonConstants.SLIDER_WIDTH)
          .showSteps(true)
          .showTips(true, this.currentTranslateData[this.currentTranslateMode].toFixed())
          .clip(false)
          .onChange((value: number, mode: SliderChangeMode) => {
            if (this.onTranslateChange !== undefined) {
              this.onTranslateChange(value > 1000 ? 1000 : value, mode);
            }
          })
      }
      .padding({ top: 15 })
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .clip(false)

      Row() {
        ForEach(this.translateList, (item: translateListType, index) => {
          Column() {
            Text() {
              SymbolSpan($r(`sys.symbol.${item.icon}`))
                .fontColor(this.currentTranslateMode === index ?
                  [item.selectColor, item.selectColor, item.selectColor] :
                  [item.color, item.color, item.color])
                .fontWeight(FontWeight.Normal)
                .fontSize(24)
            }
            .padding(9)
            .borderRadius('50%')
            .backgroundColor(this.currentTranslateMode === index ? '#e6ffffff' : '#26ffffff')

            Text(item.title)
              .margin({ top: 4 })
              .fontColor('#fff')
              .fontSize(10)
          }
          .margin({ left: 37, right: 37 })
          .onClick(() => {
            this.currentTranslateMode = index;
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
  }
}
