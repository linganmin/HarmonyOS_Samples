/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

// [Start gestures_conflict_scene7]
@Entry
@Component
struct GesturesConflictScene7 {
  scroller: Scroller = new Scroller();
  scroller2: Scroller = new Scroller();
  private arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  private childRecognizer: GestureRecognizer = new GestureRecognizer();
  private currentRecognizer: GestureRecognizer = new GestureRecognizer();

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll(this.scroller) { // External rolling container
        Column() {
          Text('Scroll Area')
            .width('100%')
            .height(150)
            .backgroundColor(0xFFFFFF)
            .borderRadius(15)
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .margin({ top: 10 })
          Scroll(this.scroller2) { // internal rolling container
            Column() {
              Text('Scroll Area2')
                .width('100%')
                .height(150)
                .backgroundColor(0xFFFFFF)
                .borderRadius(15)
                .fontSize(16)
                .textAlign(TextAlign.Center)
                .margin({ top: 10 })
              Column() {
                ForEach(this.arr, (item: number) => {
                  Text(item.toString())
                    .width('100%')
                    .height(200)
                    .backgroundColor(0xFFFFFF)
                    .borderRadius(15)
                    .fontSize(20)
                    .textAlign(TextAlign.Center)
                    .margin({ top: 10 })
                }, (item: string) => item)
              }
              .width('100%')
            }
          }
          .id('innerScroll')
          .scrollBar(BarState.Off) // The scroll bar is always displayed
          .width('100%')
          .height(800)
        }.width('100%')
      }
      .id('outerScroll')
      .height(600)
      .scrollBar(BarState.Off) // The scroll bar is always displayed
      .shouldBuiltInRecognizerParallelWith((current: GestureRecognizer, others: Array<GestureRecognizer>) => {
        for (let i = 0; i < others.length; i++) {
          let target = others[i].getEventTargetInfo();
          if (target) {
            if (target.getId() === 'innerScroll' && others[i].isBuiltIn() &&
              others[i].getType() === GestureControl.GestureType.PAN_GESTURE) { // Find the recognizer that will form the parallel gesture
              this.currentRecognizer = current; // Save the recognizer of the current component
              this.childRecognizer = others[i]; // Save the recognizer that will form the parallel gesture
              return others[i]; // Return the recognizer that will form the parallel gesture
            }
          }
        }
        return undefined;
      })
      .onGestureRecognizerJudgeBegin((event: BaseGestureEvent, current: GestureRecognizer,
        others: Array<GestureRecognizer>) => { // When the recognizer is about to succeed, set the recognizer enabling status according to the current component status
        if (current) {
          let target = current.getEventTargetInfo();
          if (target) {
            if (target.getId() === 'outerScroll' && current.isBuiltIn() &&
              current.getType() === GestureControl.GestureType.PAN_GESTURE) {
              if (others) {
                for (let i = 0; i < others.length; i++) {
                  let target = others[i].getEventTargetInfo() as ScrollableTargetInfo;
                    if (target instanceof ScrollableTargetInfo && target.getId() == 'innerScroll') { // Find the corresponding parallel recognizer on the response chain
                    let panEvent = event as PanGestureEvent;
                    if (target.isEnd()) { // isEnd returns whether the current rolling container component is at the bottom of the dynamic control status of the recognizer based on the current component status and movement direction
                      if (panEvent && panEvent.offsetY < 0) {
                        this.childRecognizer.setEnabled(false) // When it's the end, pull up
                        this.currentRecognizer.setEnabled(true)
                      } else {
                        this.childRecognizer.setEnabled(true)
                        this.currentRecognizer.setEnabled(false)
                      }
                    } else if (target.isBegin()) {
                      if (panEvent.offsetY > 0) { // Pull down at the beginning
                        this.childRecognizer.setEnabled(false)
                        this.currentRecognizer.setEnabled(true)
                      } else {
                        this.childRecognizer.setEnabled(true)
                        this.currentRecognizer.setEnabled(false)
                      }
                    } else {
                      this.childRecognizer.setEnabled(true)
                      this.currentRecognizer.setEnabled(false)
                    }
                  }
                }
              }
            }
          }
        }
        return GestureJudgeResult.CONTINUE;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xF1F3F5)
    .padding(12)
  }
}

// [End gestures_conflict_scene7]