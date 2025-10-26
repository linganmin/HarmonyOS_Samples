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

import { Size } from '@kit.ArkUI';

const SIZE_ATTR_ARR: readonly Size[] =
  [{ width: 270, height: 240 }, { width: 290, height: 220 }, { width: 310, height: 200 }]; // Card size type
const SIZE_DIFF_ARR: Size = { width: -20, height: 20 }; // The difference in size between the front and back cards
const OPACITY_ATTR_ARR: readonly number[] = [1.0, 0.6, 0.3, 0]; // Transparency boundary
const OPACITY_DIFF_ARR: readonly number[] = [0.4, 0.3, 0.3]; // The difference between transparency boundaries
const DATA_LENGTH = 6; // Data length
const ON_SHOW_PAGE = 3; // Display the number of cards
const OFFSET_DISTANCE_4_FADE_THREHOLD = 200; // The dragging distance to complete the fade-in and fade-in effect of a unidirectional sliding card: vp units
const OFFSET_DISTANCE_4_SWICH_THREHOLD = 150; // The distance threshold for triggering the switch by sliding the card: vp unit
const SWITCH_PAGE_VELOCITY_THREHOLD = 2000; // The speed threshold for triggering the switch by sliding the card

enum PageIndex {
  FIRSTPAGE = 0,
  SCENDPAGE = 1,
  THRIDPAGE = 2,
  FOURTHPAGE = 3
}

let timerId: number = 0;

@Component
struct SwiperExample {
  currentIndexArray: Array<number> = []; // Record the index value of the currently displayed card in the array
  // The parameter values of each card, including width and height dimensions, visible status, Z-order, and transparency. Offset, image size
  @State sizeArray: Array<Size> = [];
  @State visibleArray: Array<Visibility> = [];
  @State zIndexArray: Array<number> = [];
  @State opacityArray: Array<number> = [];
  @State offsetXArray: Array<number> = [];
  @State scaleArray: Array<ScaleOptions> = [];
  @Prop @Watch('onAnimationEnable') isEnableAnimate: boolean = false;
  isAppear: boolean = false;
  isStart: boolean = false;
  private data: string[] = []; // Card data array
  // Sliding gesture parameter
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right });

  aboutToAppear(): void {
    for (let i = 0; i < DATA_LENGTH; i++) {
      this.data.push(`this is ${i}`);
      if (i < ON_SHOW_PAGE) { // The status of the first three cards
        this.sizeArray.push({ width: SIZE_ATTR_ARR[i].width, height: SIZE_ATTR_ARR[i].height }); // The first three cards come in three sizes
        this.visibleArray.push(Visibility.Visible); // The first three cards are all visible
        this.zIndexArray.push(ON_SHOW_PAGE - i); // The smaller the index, the larger the Z-order, and the superimposition
        this.opacityArray.push(OPACITY_ATTR_ARR[i]); // The transparency of the first three cards
        this.currentIndexArray.push(i); // The index of the currently displayed card in the array
      } else {
        this.sizeArray.push({ width: SIZE_ATTR_ARR[2].width, height: SIZE_ATTR_ARR[2].height }); // The sizes of the remaining cards are all uniform
        this.visibleArray.push(Visibility.None); // The remaining cards are all invisible
        this.zIndexArray.push(0); // The remaining cards are all on the smallest sequence
        this.opacityArray.push(OPACITY_ATTR_ARR[3]); // The remaining cards are all completely transparent
      }
      this.scaleArray.push({
        // The graphic size of each card is the same
        x: 1,
        y: 1,
        centerX: '50%',
        centerY: '50%'
      });
      this.opacityArray.push(0);
    }
    this.currentIndexArray.push(3);
  }

  onAnimationEnable(propName: string) {
    if (!this.isEnableAnimate && this.isStart) {
      clearInterval(timerId); // Stop looping playback
      this.isStart = false;
    }
  }

  changeSubPageWhenUpdate(dataIndex: number, PageIndex: number, distanceScl: number, isNeedToChangeSize: boolean,
    isNeedToChangeOpac: boolean) {
    if (dataIndex < 0 || dataIndex >= DATA_LENGTH || PageIndex < 1 || PageIndex >= (ON_SHOW_PAGE + 1)) {
      return;
    }
    if (isNeedToChangeSize) {
      this.sizeArray[dataIndex].width = SIZE_ATTR_ARR[PageIndex].width + SIZE_DIFF_ARR.width * (1.0 - distanceScl);
      this.sizeArray[dataIndex].height = SIZE_ATTR_ARR[PageIndex].height + SIZE_DIFF_ARR.height * (1.0 - distanceScl);
    }
    if (isNeedToChangeOpac) {
      this.opacityArray[dataIndex] = OPACITY_ATTR_ARR[PageIndex] + OPACITY_DIFF_ARR[PageIndex -1] * (1.0 - distanceScl);
    }
  }

  changePageWhenEnd(firPageOffsetX: number, isSwitch: boolean, rightOrleft: boolean) {
    this.offsetXArray[this.currentIndexArray[PageIndex.FIRSTPAGE]] =
      (isSwitch && rightOrleft) ? firPageOffsetX : -firPageOffsetX;
    this.opacityArray[this.currentIndexArray[PageIndex.FIRSTPAGE]] = isSwitch ? 0 : 1;
    this.scaleArray[this.currentIndexArray[PageIndex.FIRSTPAGE]].x =
      this.scaleArray[this.currentIndexArray[PageIndex.FIRSTPAGE]].y = isSwitch ? 0 : 1;
    this.opacityArray[this.currentIndexArray[PageIndex.SCENDPAGE]] = OPACITY_ATTR_ARR[isSwitch ? 0 : 1];
    this.sizeArray[this.currentIndexArray[PageIndex.SCENDPAGE]].width = SIZE_ATTR_ARR[isSwitch ? 0 :1].width;
    this.sizeArray[this.currentIndexArray[PageIndex.SCENDPAGE]].height = SIZE_ATTR_ARR[isSwitch ? 0 :1].height;

    this.opacityArray[this.currentIndexArray[PageIndex.THRIDPAGE]] = OPACITY_ATTR_ARR[isSwitch ? 1 : 2];
    this.sizeArray[this.currentIndexArray[PageIndex.THRIDPAGE]].width = SIZE_ATTR_ARR[isSwitch ? 1 : 2].width;
    this.sizeArray[this.currentIndexArray[PageIndex.THRIDPAGE]].height = SIZE_ATTR_ARR[isSwitch ? 1 : 2].height;

    this.opacityArray[this.currentIndexArray[PageIndex.FOURTHPAGE]] = OPACITY_ATTR_ARR[isSwitch ? 2 : 3];
  }

  changePagePropertyWhenFinished() {
    this.visibleArray[this.currentIndexArray[PageIndex.FIRSTPAGE]] = Visibility.None;
    this.visibleArray[this.currentIndexArray[PageIndex.FOURTHPAGE]] = Visibility.Visible;
    this.changeSubPageWhenUpdate(this.currentIndexArray[PageIndex.FIRSTPAGE], PageIndex.THRIDPAGE, 1.0, true, false);
    this.scaleArray[this.currentIndexArray[PageIndex.FIRSTPAGE]].x =
      this.scaleArray[this.currentIndexArray[PageIndex.FIRSTPAGE]].y = 1;
    this.offsetXArray[this.currentIndexArray[PageIndex.FIRSTPAGE]] = 0;
    for (let i = 0; i < this.currentIndexArray.length; i++) {
      this.zIndexArray[this.currentIndexArray[i]] =
        (this.zIndexArray[this.currentIndexArray[i]] + 1) % this.currentIndexArray.length;
      this.currentIndexArray[i] = (this.currentIndexArray[i] + 1) % this.data.length;
      this.opacityArray[this.currentIndexArray[i]] = OPACITY_ATTR_ARR[i];
    }
  }

  setSwiperAnimation() {
    timerId = setInterval(() => { // Set the timer
      this.getUIContext().animateTo({
        duration: 250,
        curve: Curve.Linear,
        onFinish: () => {
          this.changePagePropertyWhenFinished();
        }
      }, () => {
        this.changePageWhenEnd(OFFSET_DISTANCE_4_FADE_THREHOLD, true, true);
      })
    }, 3000);
    this.isStart = true;
  }

  build() {
    Column() {
      Text(`CurrentOffset.x: ${Math.round(this.offsetXArray[this.currentIndexArray[PageIndex.FIRSTPAGE]] * 100) /
        100.0}`)
        .fontSize((20))
      // [Start SwiperCarouselOverlay]
      Stack({ alignContent: Alignment.Start }) {
        ForEach(this.data, (item: string, index: number) => {
          Column() {
            Text(item)
              .fontSize(30)
              .fontColor(Color.Blue)
          }
          .zIndex(this.zIndexArray[index])
          .visibility(this.visibleArray[index])
          .opacity(this.opacityArray[index])
          .backgroundColor(Color.Pink)
          .width(this.sizeArray[index].width)
          .height(this.sizeArray[index].height)
          .offset({ x: this.offsetXArray[index], y: 0 })
          .scale(this.scaleArray[index])
        }, (item: string, index: number) => `${item}index`)
      }
      .onAppear(() => { // It is called only once after mounting
        this.isAppear = true;
      })
      // [End SwiperCarouselOverlay]
      // [Start gesture]
      .gesture(
        PanGesture(this.panOption)
          .onActionStart((event: GestureEvent) => {
            clearInterval(timerId); // Stop looping playback
            this.isStart = false;
            this.visibleArray[this.currentIndexArray[3]] = Visibility.Visible;
          })
          .onActionUpdate((event: GestureEvent) => {
            if (!event) {
              return;
            }
            let distanceScl: number = 0;
            let index0 = this.currentIndexArray[PageIndex.FIRSTPAGE];
            // The animation effect of the top card
            this.offsetXArray[index0] = event.offsetX;
            if (this.offsetXArray[index0] < 0) { // 左
              distanceScl = this.offsetXArray[index0] > -OFFSET_DISTANCE_4_FADE_THREHOLD ?
                1.0 + this.offsetXArray[index0] / OFFSET_DISTANCE_4_FADE_THREHOLD : 0;
            } else { // right
              distanceScl = this.offsetXArray[index0] < OFFSET_DISTANCE_4_FADE_THREHOLD ?
                1.0 - this.offsetXArray[index0] / OFFSET_DISTANCE_4_FADE_THREHOLD : 0;
            }

            // The animation effect of the second-layer card
            let index1 = this.currentIndexArray[PageIndex.SCENDPAGE];
            this.changeSubPageWhenUpdate(index1, PageIndex.SCENDPAGE, distanceScl, true, true);

            // The animation effect of three layers of cards
            let index2 = this.currentIndexArray[PageIndex.THRIDPAGE];
            this.changeSubPageWhenUpdate(index1, PageIndex.THRIDPAGE, distanceScl, true, true);

            // The animation effect of four layers of cards
            let index3 = this.currentIndexArray[PageIndex.FOURTHPAGE];
            this.changeSubPageWhenUpdate(index1, PageIndex.FOURTHPAGE, distanceScl, false, true);
          })
          .onActionEnd((event: GestureEvent) => { // Lift your finger
            if (!event) {
              return;
            }
            this.getUIContext().animateTo({
              duration: 200,
              curve: Curve.Linear,
              onFinish: () => { // After the animation effect ends, assign status values to each card to ensure that every component is in the correct state
                // Within the range that triggers the switch page
                if (Math.abs(this.offsetXArray[this.currentIndexArray[PageIndex.FIRSTPAGE]]) <
                  OFFSET_DISTANCE_4_SWICH_THREHOLD) {
                  this.visibleArray[this.currentIndexArray[PageIndex.FIRSTPAGE]] = Visibility.Visible;
                  this.visibleArray[this.currentIndexArray[PageIndex.FOURTHPAGE]] = Visibility.None;
                } else { // Update the status outside the range that triggers the switch page
                  this.changePagePropertyWhenFinished();
                }
              }
            }, () => {
              if (this.offsetXArray[this.currentIndexArray[PageIndex.FIRSTPAGE]] > OFFSET_DISTANCE_4_SWICH_THREHOLD ||
                event.velocityX > SWITCH_PAGE_VELOCITY_THREHOLD) { // Fade out of the page to the right
                this.changePageWhenEnd(OFFSET_DISTANCE_4_FADE_THREHOLD, true, true);
              } else if (this.offsetXArray[this.currentIndexArray[PageIndex.FIRSTPAGE]] <
                -OFFSET_DISTANCE_4_SWICH_THREHOLD || event.velocityX < -SWITCH_PAGE_VELOCITY_THREHOLD) { // Fade out of the page to the left
                this.changePageWhenEnd(OFFSET_DISTANCE_4_FADE_THREHOLD, true, false);
              } else {
                this.changePageWhenEnd(0, false, true); // Return
              }
            })
          })
      )
      // [End gesture]
      .backgroundColor(Color.Black)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height(300)
    .margin({ top: 150 })
  }
}

@Component
export struct StackSwitch {
  @State isPageShow: boolean = true;

  onPageShow(): void {
    this.isPageShow = true;
  }

  onPageHide(): void {
    this.isPageShow = false;
  }

  build() {
    NavDestination() {
      Column() {
        SwiperExample({ isEnableAnimate: this.isPageShow })
      }
    }
    .padding({ top: 36 })
  }
}