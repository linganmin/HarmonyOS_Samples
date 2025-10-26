/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import { image } from '@kit.ImageKit';
import { emitter } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @Provide('pageInfo') pageStack: NavPathStack = new NavPathStack();
  @State isShowSaveDom: boolean = false;
  @State pixelMap: PixelMap | undefined = undefined;
  imageSource: image.ImageSource | undefined = undefined;

  aboutToDisappear() {
    emitter.off('back');
  };

  build() {
    Navigation(this.pageStack) {
      Column({ space: 12 }) {
        Button($r('app.string.reading_images_from_the_gallery'), { buttonStyle: ButtonStyleMode.NORMAL })
          .width('100%')
          .height(40)
          .fontColor('#0A59F7')
          .onClick(() => {
            this.pageStack.replacePathByName('ReadView', '');
          });
        Button($r('app.string.save_image_to_gallery'), { buttonStyle: ButtonStyleMode.NORMAL })
          .width('100%')
          .height(40)
          .fontColor('#0A59F7')
          .onClick(() => {
            this.pageStack.replacePathByName('WriteView', '');
          });
      }
      .padding(16)
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
    }
    .title($r('app.string.image_reading_and_saving'))
    .height('100%')
    .width('100%')
  }
}