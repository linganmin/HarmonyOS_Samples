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

import { PixelMapManager } from '../utils/PixelMapManager';

interface filterDataType {
  title: string | Resource,
  key: string,
  color: string
}

@Component
export default struct ApplyFilterView {
  @Consume pixelMapManager?: PixelMapManager;
  scroller: Scroller = new Scroller();
  flushPixelMapChange: () => void = () => {
  };
  @State filterData: Array<filterDataType> = [
    {
      title: $r('app.string.none'),
      key: 'null',
      color: '#fff1efef'
    },
    {
      title: $r('app.string.grayscale'),
      key: 'grayscale',
      color: '#ffeaeaea'
    },
    {
      title: $r('app.string.brightness'),
      key: 'brightness',
      color: '#ffc1bdbd'
    },
    {
      title: $r('app.string.invert'),
      key: 'invert',
      color: '#ff9f9c9c'
    },
    {
      title: $r('app.string.blur'),
      key: 'blur',
      color: '#7a000000'
    },
    {
      title: $r('app.string.customize'),
      key: 'customize',
      color: '#7a000000'
    }
  ];
  @Consume filterCurrMode: number;

  build() {
    Column() {
      Scroll(this.scroller) {
        Row() {
          ForEach(this.filterData, (item: filterDataType, index) => {
            Column() {
              Row() {
                Text(item.title)
                  .margin({
                    left: 8,
                    bottom: 8
                  })
                  .fontSize(12)
                  .fontColor('#fff')
              }
              .width(68)
              .height(68)
              .alignItems(VerticalAlign.Bottom)
              .backgroundImage($rawfile('low.jpg'))
              .borderRadius(8)
              .borderWidth(index === this.filterCurrMode ? 2 : 0)
              .borderColor(Color.White)
            }
            .margin(2)
            .onClick(async () => {
              await this.pixelMapManager?.handleFilter(index);
              this.filterCurrMode = index;
              this.flushPixelMapChange();
            })
          }, (item: string) => item)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .scrollBarColor('#ffeceaea')
      .scrollBarWidth(0)
      .friction(0)
      .edgeEffect(EdgeEffect.None)
    }
    .padding({ left: 16, right: 16 })
  }
}
