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
import { ArkTSAVScreenCapture } from './ArkTSAVScreenCapture';
import { CAVScreenCaptureToFile } from './CAVScreenCaptureToFile';
import { CAVScreenCaptureToStream } from './CAVScreenCaptureToStream';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @Builder

  PagesMap(name: string) {
    if (name == 'ArkTSAVScreenCapture') {
      ArkTSAVScreenCapture();
    } else if (name == 'CAVScreenCaptureToFile') {
      CAVScreenCaptureToFile();
    } else if (name == 'CAVScreenCaptureToStream') {
      CAVScreenCaptureToStream();
    }
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate('isRecordOne', false);
    AppStorage.setOrCreate('isRecordTwo', false);
    AppStorage.setOrCreate('isRecordThree', false);
  }

  build() {
    Navigation(this.pageInfos) {
      Row() {
        Column() {

          Text($r('app.string.Title_desc'))
            .width('100%')
            .height(88)
            .fontSize(30)
            .textAlign(TextAlign.Start)
            .fontWeight(FontWeight.Bold)
            .padding({ top: '8vp' })
            .margin({ top: '56vp' })

          Blank()

          Button($r('app.string.Subtitle1_desc'))
            .width('100%')
            .onClick(() => {
              if (AppStorage.get('isRecordTwo') || AppStorage.get('isRecordThree')) {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.Toast_message') })
              } else {
                this.pageInfos.pushPathByName('ArkTSAVScreenCapture', '');
              }
            })

          Button($r('app.string.Subtitle2_desc'))
            .width('100%')
            .margin({ top: '12vp' })
            .onClick(() => {
              if (AppStorage.get('isRecordOne') || AppStorage.get('isRecordThree')) {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.Toast_message') })
              } else {
                this.pageInfos.pushPathByName('CAVScreenCaptureToFile', '');
              }
            })

          Button($r('app.string.Subtitle3_desc'))
            .width('100%')
            .margin({ top: '12vp' })
            .onClick(() => {
              if (AppStorage.get('isRecordOne') || AppStorage.get('isRecordTwo')) {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.Toast_message')
                })
              } else {
                this.pageInfos.pushPathByName('CAVScreenCaptureToStream', '');
              }
            })
        }
        .justifyContent(FlexAlign.End)
        .padding({ left: '16vp', right: '16vp', bottom: '16vp' })
        .width('100%')
        .height('100%')
      }
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.PagesMap)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
