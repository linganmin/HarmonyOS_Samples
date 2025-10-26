/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:如何完成挖孔屏的适配
*/

// [Start extract_screen_adaption_page]
import { display, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { batteryInfo } from '@kit.BasicServicesKit';

class TextMargin {
  left: number = 0; // Status bar left offset
  right: number = 0; // Status bar right offset
}

@Entry
@Component
struct Index {
  @State date: Date = new Date();
  @State currentTime: string = ''; // Top status bar time
  @State boundingRect: display.Rect[] = []; // Unavailable area data
  @State screenWidth: number = 0; // Screen width
  @State displayClass: display.Display | null = null;
  @State topTextMargin: TextMargin = { left: 0, right: 0 }; // Top status bar offset
  @StorageLink('context') context: common.UIAbilityContext | undefined =
    AppStorage.get('context'); // Get UIAbilityContext

  aboutToAppear(): void {
    this.displayClass = display.getDefaultDisplaySync();
    display.getDefaultDisplaySync().getCutoutInfo((err, data) => {
      if (err.code !== 0) {
        console.log('getCutoutInfo failed. error is:', JSON.stringify(err));
        return;
      }
      this.boundingRect = data.boundingRects;
      this.topTextMargin = this.getBoundingRectPosition();
    })
    // Get hour
    let hours = this.date.getHours();
    // Get minute
    let minutes = this.date.getMinutes();
    // Add 0 before minute if less than 10
    this.currentTime = hours.toString() + ':' + (minutes < 10 ? '0' + minutes : minutes.toString());
  }

  // Reset window to initial state when leaving the page
  aboutToDisappear() {
    if (this.context !== undefined) {
      window.getLastWindow(this.context, async (err, data) => {
        if (err.code !== 0) {
          console.log('getLastWindow failed. error is:', JSON.stringify(err));
          data.setWindowSystemBarEnable(['status', 'navigation']);
          data.setWindowLayoutFullScreen(false);
        }
      })
    }
  }

    /**
    * Calculate the left and right margins of the unusable areas of the punch hole screen
    * @returns {TextMargin} Objects that include left/right offsets
    */
  getBoundingRectPosition(): TextMargin {
    if (this.boundingRect !== null && this.displayClass !== null && this.boundingRect[0] !== undefined) {
      // Distance from the right of the unavailable area to the right edge of the screen: screen width minus left width and unavailable area width
      let boundingRectRight: number =
        this.displayClass.width - (this.boundingRect[0].left + this.boundingRect[0].width);
      // Distance from the left of the unavailable area to the left edge of the screen: can be obtained directly by getCutoutInfo
      let boundingRectLeft: number = this.boundingRect[0].left;
      // For some devices, if the unavailable area is in the middle, the difference between the left and right distances is less than 10 pixels, treat it as being in the middle
      if (Math.abs(boundingRectLeft - boundingRectRight) <= 10) {
        return { left: 0, right: 0 };
      }
      if (boundingRectLeft > boundingRectRight) {
        // Unavailable area on the right
        return { left: 0, right: this.displayClass.width - boundingRectLeft };
      } else if (boundingRectLeft < boundingRectRight) {
        // Unavailable area on the left
        return { left: this.boundingRect[0].left + this.boundingRect[0].width, right: 0 };
      }
    }
    return { left: 0, right: 0 };
  }

  build() {
    Stack() {
      Image($r('app.media.digging_hole_screen_2048game'))
        .objectFit(ImageFit.Fill)
        .width('100%')
        .height('100%')
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({
            message: 'This function is not yet developed',
            duration: 2000
          })
        })
      Column() {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
          Text(this.currentTime) // Time
            .fontSize(16)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Regular)
            .padding({ left: 12 })
            .margin({
              left: this.getUIContext().px2vp(this.topTextMargin.left),
              top: 14
            }) // The obtained offset is in px and needs to be converted
          Text(batteryInfo.batterySOC.toString() + '%')// Battery level
            .fontSize(16)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Regular)
            .padding({ right: 16 })
            .margin({
              right: this.getUIContext().px2vp(this.topTextMargin.right),
              top: 14
            }) // The obtained offset is in px and needs to be converted
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }
}
// [End extract_screen_adaption_page]