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
import { image } from '@kit.ImageKit';
import { ColorHsv, ColorRgb, ColorUtils } from '../utils/ColorUtils';
import { findMaxPixel, image2PixelMap, modifySVValue, traverseAllPixel } from '../utils/ImageUtils';
import { AppInfo } from '../viewmodel/AppInfoModel';
import CommonConstants from '../constants/CommonContants';
import MockDataModel from '../viewmodel/MockDataModel';
import { IconItem } from './IconItem';

@Entry
@Component
struct Index {
  private mockData = new MockDataModel();
  private arrayAppInfo: Array<AppInfo> = this.mockData.getArrayAppInfo();

  aboutToAppear() {
    this.arrayAppInfo.forEach(async (item: AppInfo) => {
      const pixelMap: image.PixelMap = await image2PixelMap(item.icon);
      const allPixels: number[] = await traverseAllPixel(pixelMap);
      const maxPixel: number = findMaxPixel(allPixels);
      let rgb: ColorRgb = ColorUtils.numberToRgb(maxPixel);
      const hsv: ColorHsv = ColorUtils.rgb2hsv(rgb);
      if (maxPixel !== -1) {
        modifySVValue(hsv);
      }
      rgb = ColorUtils.hsv2rgb(hsv);
      item.backgroundColor = ColorUtils.rgbToNumber(rgb);
    }, (item: AppInfo) => item.icon)
  }

  build() {
    List({ space: CommonConstants.LIST_SPACE }) {
      ForEach(this.arrayAppInfo, (item: AppInfo) => {
        ListItem() {
          IconItem({ item: item })
            .margin({ left: $r('app.integer.list_item_margin'), right: $r('app.integer.list_item_margin') })
        }
      }, (item: AppInfo) => JSON.stringify(item))
    }
    .width($r('app.string.percent_100'))
    .height($r('app.string.percent_100'))
    .padding({ top: $r('app.integer.list_padding_top') })
  }
}