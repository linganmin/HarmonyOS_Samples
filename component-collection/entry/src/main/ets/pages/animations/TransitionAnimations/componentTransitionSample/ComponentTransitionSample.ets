/*
 * Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { TitleBar } from '../../../../common/TitleBar';

AppStorage.set('state', true);

@Entry
@Component
struct ComponentTransitionSample {
  @StorageLink('state') flag: boolean = true;
  @State show: Resource = $r('app.string.component_transition_hide');

  build() {
    Column() {
      TitleBar({ title: $r('app.string.component_transition') })
      Scroll() {
        Column() {
          Row() {
            if (this.flag) {
              // The appearance and disappearance of the Image are configured with different transition effects
              // When it appears, the specified x-direction scale is 0 and the y-direction scale is 1, which changes to default x- and y-direction scales are both 1
              // When it disappears, the default rotation angle changes from 0 to 180° clockwise around the z axis.
              Image($r('app.media.img_love'))
                .width(200)
                .height(200)
                .margin(50)
                .transition({ type: TransitionType.Insert, scale: { x: 0, y: 1.0 }, opacity: 0.7 })
                .transition({ type: TransitionType.Delete, rotate: { z: 1, angle: 180 }, opacity: 0.5 })
            }
          }
          .justifyContent(FlexAlign.Center)
          .borderRadius(24)
          .backgroundColor(Color.White)
          .height(300)
          .width('100%')
          .margin({ left: 12, right: 12 })

          Row() {
            Button(this.show)
              .width('90%')
              .margin({ top: 16 })
              .onClick(() => {
                // Click the Button to control the display and disappearance of the Image
                if (this.flag) {
                  this.show = $r('app.string.component_transition_show');
                } else {
                  this.show = $r('app.string.component_transition_hide');
                }
                // When using TransitionOptions to specify transition, you must use animate to produce animation
                this.getUIContext().animateTo({ duration: 1000 }, () => {
                  this.flag = !this.flag;
                })
              })
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }
        .constraintSize({ minHeight: '100%' })
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.background_shallow_grey'))
  }
}