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
import { formatVideoTime } from '../common/utils/TimeUtils';
import { MyAVScreenCapture } from '../model/MyAVScreenCapture';
import PlayerParam from '../model/PlayerParam';

@Component
export struct ArkTSAVScreenCapture {
  private myAVScreenCapture: MyAVScreenCapture = MyAVScreenCapture.getInstance();
  @Consume('pageInfos') pageInfos: NavPathStack;
  @StorageLink('fileNameOne') fileName: string = '';
  @StorageProp("isRecordOne") isRecordOne: boolean = false;

  private filesDir = this.getUIContext().getHostContext()?.filesDir;

  @Builder
  navTitleBuilder() {
    Row() {
      Text($r('app.string.Subtitle1_desc'))
        .fontSize($r('app.float.subtitle_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({ left: 10 })
      Button() {
        if (!this.isRecordOne) {
          SymbolGlyph($r('sys.symbol.play_video'))
            .fontSize(24)
        } else {
          Image($r('app.media.dot_video'))
            .height(24)
            .width(24)
        }
      }
      .height(40)
      .width(40)
      .padding(8)
      .backgroundColor(this.isRecordOne
        ? $r('app.color.record_button_background_active_color')
        : $r('app.color.record_button_background_inactive_color'))
      .margin({ right: 15 })
      .onClick(() => {
        if (!this.isRecordOne) {
          this.myAVScreenCapture.startRecording(this.filesDir as string);
          AppStorage.setOrCreate('isRecordOne', true);
        } else {
          this.myAVScreenCapture.stopRecording();
          AppStorage.setOrCreate('isRecordOne', false);
          this.fileName = this.myAVScreenCapture.getFileName();
        }
      })
    }
    .height('100%')
    .width('85%')
    .justifyContent(FlexAlign.SpaceBetween)

  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          // Video area
          Column() {
            if (this.isRecordOne) {
              Text($r('app.string.Recording_text_desc'))
                .width('100%')
                .layoutWeight(1)
                .fontSize(16)
                .textAlign(TextAlign.Center)
            } else if (this.fileName != '') {
              Column() {
                Image($r('app.media.image'))
                  .width(48)
                  .height(48)
                Text($r('app.string.Text_desc'))
                  .width('100%')
                  .fontSize(16)
                  .margin({ top: '17vp' })
                  .textAlign(TextAlign.Center)
                Text(this.fileName)
                  .width('100%')
                  .height(22)
                  .fontSize(12)
                  .margin({ top: '6vp' })
                  .textAlign(TextAlign.Center)
                SymbolGlyph($r('sys.symbol.play_circle_fill'))
                  .fontColor([$r('app.color.player_button_color')])
                  .fontSize(40)
                  .margin({ top: '14vp' })
                  .onClick(() => {
                    let param: PlayerParam = {
                      videoSrc: 'file://' + this.myAVScreenCapture.getPath(),
                      fileName: this.fileName
                    } as PlayerParam;
                    this.pageInfos.pushPathByName('Player', param);
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .layoutWeight(1)
            } else {
              Text($r('app.string.Initial_text_desc'))
                .width('100%')
                .layoutWeight(1)
                .fontSize(16)
                .textAlign(TextAlign.Center)
            }
          }
          .backgroundColor($r('app.color.background_color'))
          .width('100%')
          .layoutWeight(1)

        }
        .width('100%')
      }
      .height('104%')
    }
    .title(this.navTitleBuilder())
  }
}
