/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

// [Start render_group]
import { IconItem } from './IconItem'

class IconItemSource {
  image: string | Resource = ''
  text: string | Resource = ''

  constructor(image: string | Resource = '', text: string | Resource = '') {
    this.image = image;
    this.text = text;
  }
}

@Component
export struct RenderGroup {
  @State renderGroupFlag: boolean = false;
  private iconItemSourceList: IconItemSource[] = [];

  aboutToAppear() {
    for (let index = 0; index < 20; index++) {
      const numStart: number = index * 3;
      this.iconItemSourceList.push(
        new IconItemSource($r('app.media.app_icon'), `item${numStart + 1}`),
        new IconItemSource($r('app.media.app_icon'), `item${numStart + 2}`),
        new IconItemSource($r('app.media.app_icon'), `item${numStart + 3}`),
      );
    }
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text('Example')
            .fontSize(24)
            .lineHeight(24)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 30 })
        }

        // Dynamic switching of renderGroup functionality
        Stack({ alignContent: Alignment.End }) {
          Button(this.renderGroupFlag ? 'renderGroup On' : 'renderGroup Off', {
            type: ButtonType.Normal,
            stateEffect: true
          })
            .fontSize(12)
            .borderRadius(8)
            .width(150)
            .height(30)
            .margin({ right: 30 })
            .onClick(() => {
              this.renderGroupFlag = !this.renderGroupFlag;
              AppStorage.setOrCreate('renderGroupFlag', this.renderGroupFlag)
            })
        }
      }
      .height(56)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      GridRow({
        columns: 6,
        gutter: { x: 0, y: 0 },
        breakpoints: {
          value: ['400vp', '600vp', '800vp'],
          reference: BreakpointsReference.WindowSize
        },
        direction: GridRowDirection.Row
      }) {
        ForEach(this.iconItemSourceList, (item: IconItemSource) => {
          GridCol() {
            IconItem({ image: item.image, text: item.text })
              .transition(
                TransitionEffect.scale({ x: 0.5, y: 0.5 })
                  .animation({ duration: 3000, curve: Curve.FastOutSlowIn, iterations: -1 })
                  .combine(TransitionEffect.rotate({ z: 1, angle: 360 })
                    .animation({ duration: 3000, curve: Curve.Linear, iterations: -1 }))
              )
          }
          .height(70)
          .width('25%')
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
// [End render_group]