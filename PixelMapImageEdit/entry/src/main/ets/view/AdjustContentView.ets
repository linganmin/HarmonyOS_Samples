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

import { adjustIconList, IconStatus } from '../viewModel/IconListViewModel';
import { CommonConstants } from '../common/constant/CommonConstants';
import { AdjustType } from '../viewModel/OptionViewModel';
import { PixelMapManager } from '../pages/PixelMapManager';

interface translateListType {
  icon: string,
  title: string | Resource,
  color: string,
  selectColor: string
}

@Component
struct SliderCustom {
  pixelMapManager?: PixelMapManager
  @Consume('currentAdjustData') currentAdjustData: number[];
  @Prop min: number;
  @Prop max: number;
  @Consume('currentAdjustIndex') @Watch('onAdjustIndexChange') currentAdjustType: AdjustType;
  private paramValues: number[] = [
    CommonConstants.SLIDER_MAX,
    CommonConstants.SLIDER_MAX,
    CommonConstants.SLIDER_MAX
  ];
  deviceListDialogController: CustomDialogController = new CustomDialogController({
    builder: Dialog(),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });

  onAdjustIndexChange() {
    this.paramValues[this.currentAdjustType] = this.currentAdjustData[this.currentAdjustType];
  }

  build() {
    Column() {
      Row() {
        Slider({
          value: this.currentAdjustData[this.currentAdjustType],
          step: CommonConstants.SLIDER_STEP,
          min: this.min,
          max: this.max
        })
          .trackColor('#1affffff')
          .selectedColor(Color.White)
          .width(CommonConstants.SLIDER_WIDTH)
          .showSteps(true)
          .showTips(true)
          .clip(false)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.sliderChange(value > this.max ? this.max : value, mode);
          })
      }
      .padding({ top: 15 })
      .width(CommonConstants.LAYOUT_FULL_SCREEN)
      .justifyContent(FlexAlign.Center)
    }
  }

  async sliderChange(value: number, mode: SliderChangeMode) {
    if ((mode === SliderChangeMode.End) && (value !== this.currentAdjustData[this.currentAdjustType])) {
      const roundedValue = Math.round(value);
      this.currentAdjustData[this.currentAdjustType] = roundedValue;
      this.paramValues[this.currentAdjustType] = roundedValue;
      this.deviceListDialogController.open();
      await this.pixelMapManager?.adjustImage(this.paramValues);
      this.deviceListDialogController.close();
    }
  }
}

@CustomDialog
export struct Dialog {
  controller?: CustomDialogController;

  build() {
    Column() {
      LoadingProgress()
        .color(Color.White)
        .width(CommonConstants.LOADING_WH)
        .height(CommonConstants.LOADING_WH)
    }
  }
}

@Component
export default struct AdjustContentView {
  pixelMapManager?: PixelMapManager;
  @Provide currentAdjustIndex: number = 0;
  @State adjustList: translateListType[] = [
    {
      icon: 'brightness',
      title: $r('app.string.light'),
      color: '#fff',
      selectColor: '#ff000000'
    },
    {
      icon: 'transparency_lock',
      title: $r('app.string.transparency'),
      color: '#fff',
      selectColor: '#ff000000'
    },
    {
      icon: 'drop_bottomrighthalf_inset_filled',
      title: $r('app.string.saturation'),
      color: '#fff',
      selectColor: '#ff000000'
    }
  ];
  @Consume('currentAdjustData') currentAdjustData: Array<number>;
  AdjustIconList: Array<IconStatus> = adjustIconList;

  build() {
    Column() {
      Row() {
        SliderCustom({
          pixelMapManager: this.pixelMapManager,
          min: CommonConstants.SLIDER_MIN.valueOf(),
          max: CommonConstants.SLIDER_MAX.valueOf()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row() {
        ForEach(this.adjustList, (item: translateListType, index) => {
          Column() {
            Text() {
              SymbolSpan($r(`sys.symbol.${item.icon}`))
                .fontColor(this.currentAdjustIndex === index ?
                  [item.selectColor, item.selectColor, item.selectColor] :
                  [item.color, item.color, item.color])
                .fontWeight(FontWeight.Normal)
                .fontSize(22)
            }
            .padding(9)
            .borderRadius('50%')
            .backgroundColor(this.currentAdjustIndex === index ? '#e6ffffff' : '#26ffffff')

            Text(item.title)
              .margin({ top: 4 })
              .fontColor('#fff')
              .fontSize(10)
          }
          .margin({ left: 37, right: 37 })
          .onClick(() => {
            this.currentAdjustIndex = index;
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.LAYOUT_FULL_SCREEN)
    .height(CommonConstants.LAYOUT_FULL_SCREEN)
  }
}