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

import TextLink from '../uiComponent/TextLink';

@Component
export struct LinksPage {
  @Builder
  NavDestinationTitle() {
    Row() {
      Text('Smile')
        .fontSize(20)
        .lineHeight(42)
        .fontWeight(700)
        .width(100)
        .padding({ left: 6 })
        .opacity(0.9)
      Row({ space: 12 }) {
        Row() {
          Image($r('app.media.dot_grid'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .borderRadius(36)
        .backgroundColor('rgba(0,0,0,0.05)')
        .justifyContent(FlexAlign.Center)

        Row() {
          Image($r('app.media.ic_meeting_video'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .borderRadius(36)
        .backgroundColor('rgba(0,0,0,0.05)')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('calc(100% - 56vp)')
    .padding({
      top: 4,
      right: 16
    })
    .justifyContent((FlexAlign.SpaceBetween))
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TextLink({
            img: $r('app.media.Public_avatar'),
            text: $r('app.string.text')
          })
          TextLink({
            img: $r('app.media.Public_avatar'),
            text: $r('app.string.telephone_number')
          })
          TextLink({
            img: $r('app.media.Public_avatar'),
            text: $r('app.string.address')
          })
          TextLink({
            img: $r('app.media.Public_avatar'),
            text: $r('app.string.date')
          })
          TextLink({
            img: $r('app.media.Public_avatar'),
            text: $r('app.string.email')
          })
          TextLink({
            img: $r('app.media.Public_avatar'),
            text: $r('app.string.link')
          })
          TextLink({
            img: $r('app.media.Public_avatar'),
            text: $r('app.string.appLinking')
          })
        }
        .padding({
          left: 16,
          right: 16
        })
        .justifyContent(FlexAlign.Start)
        .margin({ top: 12 })

        Column() {
          Row() {
            Row({ space: 12 }) {
              Image($r('app.media.mic_filled'))
                .width(28)
                .height(28)

              Image($r('app.media.emoji'))
                .width(28)
                .height(28)
            }

            TextInput()
              .height(40)
              .width(200)
              .margin({
                left: 12,
                right: 12
              })

            Row() {
              Row({ space: 12 }) {
                Image($r('app.media.plus_circle'))
                  .width(28)
                  .height(28)

                Image($r('app.media.send'))
                  .width(28)
                  .height(28)
              }
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .margin({ bottom: -28 })
        .padding({
          top: 8,
          bottom: 8
        })
        .backgroundColor(Color.White)
        .width('100%')
        .height(80)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .title(this.NavDestinationTitle())
    .backgroundColor('#F1F3F5')
    .height('100%')
    .width('100%')
  }
}