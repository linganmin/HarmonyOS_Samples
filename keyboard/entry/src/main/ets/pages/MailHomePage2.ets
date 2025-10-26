/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

// [Start Mail_home_page2]
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct MailHomePage2 {
  @State message: string = 'Hello World';
  @State screenHeight: number = 0;
  @State isKeyBoardHidden: boolean = false;

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
        let property = currentWindow.getWindowProperties();
        let avoidArea = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        // Initialize the display area height
        this.screenHeight = this.getUIContext().px2vp(property.windowRect.height - avoidArea.topRect.height - avoidArea.bottomRect.height);
        // Monitor the ejection and retraction of the soft keyboard
        currentWindow.on('avoidAreaChange', async data => {
          if (data.type !== window.AvoidAreaType.TYPE_KEYBOARD) {
            return;
          }
          if (data.area.bottomRect.height <= 0) {
            this.isKeyBoardHidden = true;
          } else {
            this.isKeyBoardHidden = false;
          }
          this.screenHeight = this.getUIContext().px2vp(property.windowRect.height - avoidArea.topRect.height - data.area.bottomRect.height);
        })
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MailHomePage2', `getLastWindow failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    Column() {
      this.NavigationTitle()
      this.EmailContent()
      this.BottomToolbar()
    }
    .width('100%')
    .height(this.screenHeight) // Dynamically sets the viewport height
    .expandSafeArea([SafeAreaType.KEYBOARD])
    .backgroundColor('#F1F3F5')
  }
  // [StartExclude Mail_home_page2]
  @Builder
  BottomToolbar() {
    Row({ space: 24 }) {
      Image($r('app.media.folder'))
        .width($r('app.float.image_height_24'))
        .height($r('app.float.image_height_24'))
      Image($r('app.media.picture'))
        .width($r('app.float.image_height_24'))
        .height($r('app.float.image_height_24'))
      Image($r('app.media.arrow_up_circle'))
        .width($r('app.float.image_height_24'))
        .height($r('app.float.image_height_24'))
      Image($r('app.media.share'))
        .width($r('app.float.image_height_24'))
        .height($r('app.float.image_height_24'))
    }
    .width('100%')
    .height("56vp")
    .padding({ left: $r('app.float.padding_24'), right: $r('app.float.padding_24') })
    .border({
      width: { top: $r('app.float.border_weight_1') },
      color: '#E8EBED'
    })
  }

  @Builder
  NavigationTitle() {
    Row() {
      Row() {
        Image($r('app.media.arrow_left'))
          .width($r('app.float.image_height_24'))
          .height($r('app.float.image_height_24'))
          .margin({ right: $r('app.float.margin_16') })

        Text($r('app.string.new_email'))
          .fontSize($r('app.float.font_size_20'))
          .fontWeight(FontWeight.Bold)
      }

      Image($r('app.media.paperplane'))
        .width("24vp")
        .height("24vp")
    }
    .width('100%')
    .height("56vp")
    .margin({ top: Const.TOP_BAR_HEIGHT })
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: $r('app.float.padding_24'),
      right: $r('app.float.padding_24')
    })
  }

  @Builder
  EmailContent() {
    Column() {
      Row() {
        Text($r('app.string.from'))
          .fontColor($r('app.color.text_font_color'))
          .fontSize($r('app.float.font_size_16'))
        TextInput({ placeholder: Const.EMAIL_ADDRESS })
          .type(InputType.Email)
          .width(Const.FULL_SIZE)
          .backgroundColor($r('app.color.contact_background'))
      }
      .width('100%')
      .height("48vp")
      .border({
        width: { top: "1vp" },
        color: "#E8EBED"
      })

      Row() {
        Text("To")
          .fontColor("#6F7780")
          .fontSize("16vp")
        TextInput({ placeholder: Const.EMAIL_ADDRESS })
          .type(InputType.Email)
          .width(Const.FULL_SIZE)
          .backgroundColor("#F1F3F5")
      }
      .width(Const.FULL_SIZE)
      .height("48vp")
      .border({
        width: { top: "1vp" },
        color: "#E8EBED"
      })

      Row() {
        Text("Subject")
          .fontColor("#6F7780")
          .fontSize("16vp")
        TextInput({ placeholder: 'Subject' })
          .width('100%')
          .backgroundColor("#F1F3F5")
      }
      .width('100%')
      .height("48vp")
      .border({
        width: { top: "1vp" },
        color: "#E8EBED"
      })

      Row() {
        TextArea({ placeholder: 'Entry content' })
          .height('100%')
          .backgroundColor("#F1F3F5")
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .margin({ top: "12vp" })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: $r('app.float.padding_24'), right: $r('app.float.padding_24') })
    .margin({ top: $r('app.float.margin_8') })
  }
  // [EndExclude Mail_home_page2]
}
// [End Mail_home_page2]