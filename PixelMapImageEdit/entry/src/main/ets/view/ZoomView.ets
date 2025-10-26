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
export default struct ZoomView {
  pixelMapManager?: PixelMapManager;

  @Consume currentZoom: number;
  @State cropList: translateListType[] = [
    {
      icon: 'aspect_ratio',
      title: $r('app.string.none'),
      color: '#fff',
      selectColor: '#ff000000'
    },
    {
      icon: 'rectangle_ratio_1_to_1',
      title: '1:1',
      color: '#fff',
      selectColor: '#ff000000'
    },
    {
      icon: 'rectangle_ratio_4_to_3',
      title: '4:3',
      color: '#fff',
      selectColor: '#ff000000'
    },
    {
      icon: 'rectangle_ratio_16_to_9',
      title: '16:9',
      color: '#fff',
      selectColor: '#ff000000'
    }
  ];

  onZoomChange?: (value: number, mode: SliderChangeMode) => void;

  build() {
    Column() {
      Row() {
        Slider({
          value: this.currentZoom,
          step: 1,
          min: 80,
          max: 120
        })
          .trackColor('#1affffff')
          .selectedColor(Color.White)
          .width(CommonConstants.SLIDER_WIDTH)
          .showSteps(true)
          .showTips(true, (this.currentZoom.toFixed() + '%'))
          .clip(false)
          .onChange((value: number, mode: SliderChangeMode) => {
            if (this.onZoomChange !== undefined) {
              this.onZoomChange(value > 120 ? 120 : value, mode);
            }
          })
      }
      .padding({ top: 15 })
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .justifyContent(FlexAlign.Start)
    .width(CommonConstants.LAYOUT_FULL_SCREEN)
    .height(CommonConstants.LAYOUT_FULL_SCREEN)
  }
}
