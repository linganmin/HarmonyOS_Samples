/*
 * Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
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

import { curves, display } from '@kit.ArkUI';
import { TitleBar } from '../../../../common/TitleBar'
import FloatingWindowComponent from './FloatingWindowComponent';
import Logger from '../../../../util/Logger';

const TAG = '[FloatingWindowPage]';

@Entry
@Component
struct FloatingWindowSample {
  private diameter: number = 120; // Relative offset of touch point
  @State positionX: number = 50; // Component Position X
  @State positionY: number = 500; // Component Position Y
  @State displayHalfWidth: number = 0; // Half the screen width
  @State displayHalfHeight: number = 0; // Half the screen height
  @State moveStartX: number = 0; // X direction starting point
  @State moveStartY: number = 0; // Y direction starting point
  @State moveEndX: number = 0; // X direction end point
  @State moveEndY: number = 0; // Y direction end point
  @State moveSumLengthX: number = 0; // Total moving distance in X direction
  @State moveSumLengthY: number = 0; // Total moving distance in Y direction
  @State moveStartTime: number = 0; // Touch start time
  @State moveEndTime: number = 0; // Touch end time

  aboutToAppear() {
    display.getAllDisplays((err, data) => {
      // Get half of the screen width and height as the reference value
      this.displayHalfWidth = data[0].width / 2;
      this.displayHalfHeight = data[0].height / 2;
      // Convert the obtained px to vp
      Logger.info(TAG, `aboutToAppear getAllDisplays data 1 width:${this.displayHalfWidth}, height:${this.displayHalfHeight}`);
      this.displayHalfWidth = this.getUIContext().px2vp(this.displayHalfWidth);
      this.displayHalfHeight = this.getUIContext().px2vp(this.displayHalfHeight);
      Logger.info(TAG, `aboutToAppear getAllDisplays data 2 width:${this.displayHalfWidth}, height:${this.displayHalfHeight}`);
    })
  }

  build() {
    Row() {
      Column() {
        TitleBar({ title: $r('app.string.Floating_window') })
        Row() {
          Row() {
            FloatingWindowComponent()
          }
          .id('floatingWindowComponent')
          .width(80)
          .height(80)
          .position({ x: this.positionX, y: this.positionY })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.moveStartX = event.touches[0].windowX; // Get the initial value of the X coordinate when pressed
              this.moveStartY = event.touches[0].windowY; // Get the initial value of the Y coordinate when pressed
              this.moveStartTime = Date.now(); // Press to start time
              this.moveSumLengthX = 0; // Initialize the X direction movement distance when pressed
              this.moveSumLengthY = 0; // Initialize the Y direction movement distance when pressed
            }
            if (event.type === TouchType.Move) {
              this.moveEndX = event.touches[0].windowX; // Current position of X direction movement
              this.moveEndY = event.touches[0].windowY; // Current position of Y direction movement
              this.moveSumLengthX += Math.abs(this.moveEndX - this.moveStartX); // Each movement calculates the distance relative to the previous X position
              this.moveSumLengthY += Math.abs(this.moveEndY - this.moveStartY); // Each movement calculates the distance relative to the previous Y position
              this.moveStartX = this.moveEndX;
              this.moveStartY = this.moveEndY;
              Logger.info(TAG, `move ing, moveSumLengthX:${this.moveSumLengthX}, moveSumLengthY:${this.moveSumLengthY}`);

              // Hand-following process, using responsiveSpringMotion curve
              this.getUIContext().animateTo({ curve: curves.responsiveSpringMotion() }, () => {
                // Subtract the radius to move the center of the ball to the finger position
                this.positionX = event.touches[0].windowX - this.diameter / 2;
                this.positionY = event.touches[0].windowY - this.diameter / 2 - 120;
                Logger.info(TAG, `move end, animateTo x:${this.positionX}, y:${this.positionY}`);
              })
            } else if (event.type === TouchType.Up) {
              this.moveEndTime = Date.now();
              let moveDiffTime = this.moveEndTime - this.moveStartTime; // Distance traveled in the last second
              // distance
              let s = Math.sqrt((this.moveSumLengthX * this.moveSumLengthX) + (this.moveSumLengthY * this.moveSumLengthY));
              // time
              let t = moveDiffTime;
              // speed
              let v = s / t;
              Logger.info(TAG, `moveEnd, moveSumLengthX:${this.moveSumLengthX}, moveSumLengthY:${this.moveSumLengthY}, moveDiffTime:${moveDiffTime}`);
              Logger.info(TAG, `moveEnd, s:${s}, t:${t}, v:${v}`);

              // When leaving the hand, use the springMotion curve and assign the moving speed to the leaving speed
              this.getUIContext().animateTo({ curve: curves.springMotion(), tempo: v }, () => {
                if (this.positionX >= this.displayHalfWidth) {
                  // If you scroll to the right, it will be positioned to the right side of the screen minus its own width 80, and then minus 10 to leave a gap
                  this.positionX = this.displayHalfWidth * 2 - 90;
                } else {
                  this.positionX = 10;
                }
                if (this.positionY >= this.displayHalfHeight * 2 - 300) {
                  this.positionY = this.displayHalfHeight * 2 - 300;
                } else if (this.positionY <= 0) {
                  this.positionY = 10;
                }
                Logger.info(TAG, `touchUp, animateTo x:${this.displayHalfWidth}, y:100`);
              })
            }
          })
        }
        .width('100%')
        .height('92%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background_shallow_grey'))
    }
    .width('100%')
    .height('100%')
  }
}