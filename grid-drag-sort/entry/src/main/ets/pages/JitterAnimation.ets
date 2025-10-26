/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { i18n } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct JitterAnimation {
  @StorageProp('currentBreakpoint') curBp: string = 'sm';
  @State isFoldAble: boolean = false;
  @State foldStatus: number = 2;
  @State numbers: number[] = [1, 2, 3, 4, 5];
  @State isShowDelete: boolean = false;
  @State isEdit: boolean = false;
  @State rotateZ: number = 0;
  @State dragItem: number = -1;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State isEnglish: boolean = false;
  private dragRefOffSetX: number = 0;
  private dragRefOffSetY: number = 0;
  private FIX_VP_X: number = 92;
  private FIX_VP_Y: number = 84;
  private leftArr: number[] = [];
  private rightArr: number[] = [];
  private downArr: number[] = [];

  aboutToAppear(): void {
    try {
      this.isFoldAble = display.isFoldable();
      let foldStatus: display.FoldStatus = display.getFoldStatus();
      if (foldStatus === 2) {
        this.FIX_VP_X = 81;
      } else if (foldStatus === 1) {
        this.FIX_VP_X = 110;
      }
      if (this.isFoldAble) {
        this.foldStatus = foldStatus;
        let callback: Callback<number> = () => {
          let data: display.FoldStatus = display.getFoldStatus();
          this.foldStatus = data;
          if (this.foldStatus === 2) {
            this.FIX_VP_X = 81;
          } else if (this.foldStatus === 1) {
            this.FIX_VP_X = 110;
          }
        }
        display.on('change', callback);
      }
      let systemLanguage = i18n.System.getSystemLanguage();
      if (systemLanguage === 'en-Latn-US') {
        this.isEnglish = true;
      }
      for (let i = 0; i < this.numbers.length; i++) {
        if (this.numbers[i] % 4 === 1) {
          this.leftArr.push(i);
        } else if (this.numbers[i] % 4 === 0) {
          this.rightArr.push(i);
        }
      }
      let n = this.numbers.length % 4;
      let m = Math.floor(this.numbers.length / 4);
      let downNum = (m - 1) * 4 + n;
      for (let j = 0; j < downNum; j++) {
        this.downArr.push(j);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'JitterAnimation',
        `getFoldStatus failed. code=${err.code}, message=${err.message}`);
    }
  }

  itemMove(index: number, newIndex: number): void {
    if (!this.isDraggable(newIndex)) {
      return;
    }
    let tmp = this.numbers.splice(index, 1);
    this.numbers.splice(newIndex, 0, tmp[0]);
  }

  left(index: number): void {
    if (!this.isDraggable(index - 1)) {
      return;
    }
    this.offsetX += this.FIX_VP_X;
    this.dragRefOffSetX -= this.FIX_VP_X;
    this.itemMove(index, index - 1);
  }

  right(index: number): void {
    if (!this.isDraggable(index + 1)) {
      return;
    }
    this.offsetX -= this.FIX_VP_X;
    this.dragRefOffSetX += this.FIX_VP_X;
    this.itemMove(index, index + 1);
  }

  down(index: number): void {
    if (!this.isDraggable(index + 5)) {
      return;
    }
    this.offsetY -= this.FIX_VP_Y;
    this.dragRefOffSetY += this.FIX_VP_Y;
    this.itemMove(index, index + 4);
  }

  up(index: number): void {
    if (this.curBp === 'md') {
      if (!this.isDraggable(index - 5)) {
        return;
      }
      this.offsetY += this.FIX_VP_Y;
      this.dragRefOffSetY -= this.FIX_VP_Y;
      this.itemMove(index, index - 5);
    } else {
      if (!this.isDraggable(index - 4)) {
        return;
      }
      this.offsetY += this.FIX_VP_Y;
      this.dragRefOffSetY -= this.FIX_VP_Y;
      this.itemMove(index, index - 4);
    }
  }

  isDraggable(index: number): boolean {
    return index >= 0;
  }

  // [Start stopJump_start]
  private stopJump() {
    this.getUIContext().animateTo({
      delay: 0,
      tempo: 5,
      duration: 0,
      curve: Curve.Smooth,
      playMode: PlayMode.Normal,
      iterations: 1
    }, () => {
      this.rotateZ = 0;
    })
  }
  // [End stopJump_start]

  // [Start jumpWithSpeed_start]
  private jumpWithSpeed(speed: number) {
    if (this.isEdit) {
      this.rotateZ = -1;
      this.getUIContext().animateTo({
        delay: 0,
        tempo: speed,
        duration: 1000,
        curve: Curve.Smooth,
        playMode: PlayMode.Normal,
        iterations: -1
      }, () => {
        this.rotateZ = 1;
      })
    } else {
      this.stopJump();
    }
  }
  // [End jumpWithSpeed_start]

  changeIndex(index1: number, index2: number) {
    this.numbers.splice(index2, 0, this.numbers.splice(index1, 1)[0]);
  }

  @Builder
  NavDestinationTitle() {
    Column() {
      Text($r('app.string.details_page'))
        .fontSize(20)
        .lineHeight(42)
        .fontWeight(700)
        .width('100%')
        .padding({ left: 12 })
        .fontColor(Color.White)
        .opacity(0.9)
    }
    .width('100%')
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row({ space: 12 }) {
            Button() {
              Text($r('app.string.equipment'))
                .fontColor(Color.White)
                .width('100%')
                .height('100%')
                .textAlign(TextAlign.Center)
            }
            .backgroundColor('#6e95ba')
            .height(36)
            .width(this.isEnglish ? 120 : 60)

            Button() {
              Text($r('app.string.space'))
                .fontColor(Color.White)
                .width('100%')
                .height('100%')
                .textAlign(TextAlign.Center)
            }
            .backgroundColor('#0A59F7')
            .height(36)
            .width(this.isEnglish ? 80 : 60)

            Button() {
              Text($r('app.string.mine'))
                .fontColor(Color.White)
                .width('100%')
                .height('100%')
                .textAlign(TextAlign.Center)
            }
            .backgroundColor('#6e95ba')
            .height(36)
            .width(this.isEnglish ? 80 : 60)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ top: -4, bottom: 4 })

          // [Start GridItem3_start]
          Grid() {
            ForEach(this.numbers, (item: number) => {
              GridItem() {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Column() {
                    Image($r(`app.media.space${item}`))
                      .width(44)
                      .height(44)
                      .draggable(false)
                    Image($r('app.media.space_bottom'))
                      .width(16)
                      .height(16)
                      .draggable(false)
                  }
                  .width('100%')
                  .height(73)
                  .justifyContent(FlexAlign.Center)
                  .borderRadius(10)
                  .backgroundColor('#F1F3F5')
                  .animation({ curve: Curve.Sharp, duration: 300 })
                  .onClick(() => {
                    return;
                  })

                  if (this.isEdit) {
                    Image($r('app.media.close'))
                      .width(20)
                      .height(20)
                      .objectFit(ImageFit.Contain)
                      .draggable(false)
                      .position({
                        x: this.isFoldAble && this.foldStatus === 2 ? 60 :
                          this.isFoldAble && this.foldStatus === 1 ? 86 : 70,
                        y: -8
                      })
                      .onClick(() => {
                        this.getUIContext().animateTo({ duration: 300 }, () => {
                          this.numbers = this.numbers.filter((element) => element !== item);
                        })
                      })
                  }
                }
              }
              .rotate({
                z: this.rotateZ,
                angle: 1,
                centerX: '50%',
                centerY: '50%'
              })
              .width('100%')
              .zIndex(this.dragItem === item ? 1 : 0)
              .translate(this.dragItem === item ? { x: this.offsetX, y: this.offsetY } : { x: 0, y: 0 })
              // [StartExclude GridItem3_start]
              // [Start gesture3_start]
              .gesture(
                GestureGroup(GestureMode.Sequence,
                  LongPressGesture({ repeat: true })
                    .onAction(() => {
                      if (!this.isEdit) {
                        this.isEdit = true;
                        this.jumpWithSpeed(5);
                      }
                    }),
                  PanGesture({ fingers: 1, direction: null, distance: 0 })
                    .onActionStart(() => {
                      this.dragItem = item;
                      this.dragRefOffSetX = 0;
                      this.dragRefOffSetY = 0;
                    })
                    .onActionUpdate((event: GestureEvent) => {
                      this.offsetX = event.offsetX - this.dragRefOffSetX;
                      this.offsetY = event.offsetY - this.dragRefOffSetY;
                      this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
                        let index = this.numbers.indexOf(this.dragItem);
                        if (this.curBp === 'md') {
                          if (this.offsetX >= this.FIX_VP_X / 2 && (this.offsetY <= 50 && this.offsetY >= -50) &&
                            ![4].includes(index)) {
                            this.right(index);
                            this.stopJump();
                            this.jumpWithSpeed(5);
                          } else if (this.offsetX <= -this.FIX_VP_X / 2 &&
                            (this.offsetY <= 50 && this.offsetY >= -50)) {
                            this.left(index);
                            this.stopJump();
                            this.jumpWithSpeed(5);
                          }
                        } else {
                          if (this.offsetY >= this.FIX_VP_Y / 2 && (this.offsetX <= 44 && this.offsetX >= -44) &&
                          [...this.downArr].includes(index)) {
                            this.down(index);
                            this.stopJump();
                            this.jumpWithSpeed(5);
                          } else if (this.offsetY <= -this.FIX_VP_Y / 2 &&
                            (this.offsetX <= 44 && this.offsetX >= -44)) {
                            this.up(index);
                            this.stopJump();
                            this.jumpWithSpeed(5);
                          } else if (this.offsetX >= this.FIX_VP_X / 2 && (this.offsetY <= 50 && this.offsetY >= -50) &&
                            ![...this.rightArr].includes(index)) {
                            this.right(index);
                            this.stopJump();
                            this.jumpWithSpeed(5);
                          } else if (this.offsetX <= -this.FIX_VP_Y / 2 &&
                            (this.offsetY <= 50 && this.offsetY >= -50) &&
                            ![...this.leftArr].includes(index)) {
                            this.left(index);
                            this.stopJump();
                            this.jumpWithSpeed(5);
                          }
                        }
                      })
                    })
                    .onActionEnd(() => {
                      this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
                        this.dragItem = -1;
                      })
                    })
                )
              )
              // [End gesture3_start]
              // [EndExclude GridItem3_start]
            }, (item: number) => item.toString())
          }
          .width('100%')
          .height('100%')
          .editMode(true)
          .clip(false)
          .scrollBar(BarState.Off)
          .columnsTemplate(this.curBp === 'md' ? '1fr 1fr 1fr 1fr 1fr' : '1fr 1fr 1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .margin({ top: 5 })
          // [End GridItem3_start]
        }
        .width(this.curBp === 'md' ? '80%' : '100%')
        .height('100%')
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 16
        })
      }
      .scrollBar(BarState.Off)
      .padding({ bottom: 50 })
      .onClick(() => {
        this.isEdit = false;
        this.stopJump();
      })
    }
    .title(this.NavDestinationTitle())
    .backButtonIcon($r('app.media.back2'))
    .backgroundImage($r('app.media.backgroundImage'))
    .backgroundImageSize({ width: '100%', height: '100%' })
  }
}