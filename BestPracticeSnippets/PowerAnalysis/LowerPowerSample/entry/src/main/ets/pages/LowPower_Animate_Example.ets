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

/**
 * 最佳实践：动效场景优化指南
 */
 
import animator, { AnimatorResult } from '@ohos.animator';

 @Component
export struct MyAttrAnimationExample_nonAutoSkip {
  @State widthSize: number = 250
  @State heightSize: number = 100
  @State rotateAngle: number = 0
  @State flag: boolean = true

  build() {
      Column() {
        Button('change size')
          .onClick(() => {
            if (this.flag) {
              this.widthSize = 150
              this.heightSize = 60
            } else {
              this.widthSize = 250
              this.heightSize = 100
            }
            this.flag = !this.flag
          })
          .margin(30)
          .width(this.widthSize)
          .height(this.heightSize)
          // [Start Anim_power_case_1]
          .animation({
            duration: 2000,
            curve: Curve.EaseOut,
            iterations: 5,
            playMode: PlayMode.Normal,
            // set expectedFrameRateRange
            expectedFrameRateRange: {
              min: 20,
              max: 60,
              expected: 30
            }
          })
          // [End Anim_power_case_1]
      }.width('100%').margin({ top: 20 })
    }
}

// [Start Anim_power_case_2]
@Component
export struct MyAttrAnimationExample_AutoSkip {
  @State widthSize: number = 250
  @State heightSize: number = 100
  @State rotateAngle: number = 0
  @State flag: boolean = true
  @State duration:number = 2000

  build() {
      Column() {
        Button('change size')
          .onClick(() => {
            if (this.flag) {
              this.widthSize = 150
              this.heightSize = 60
            } else {
              this.widthSize = 250
              this.heightSize = 100
            }
            this.flag = !this.flag
          })
          .margin(30)
          .width(this.widthSize)
          .height(this.heightSize)
          .animation({
            duration: this.duration,
            curve: Curve.EaseOut,
            iterations: 5,
            playMode: PlayMode.Normal,
            expectedFrameRateRange: {
              min: 20,
              max: 60,
              expected: 30
            }
          })
      }.width('100%').margin({ top: 20 })
      .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
        if (isExpanding && currentRatio >= 1.0) {
          console.info('Component' +
            ' is fully visible. currentRatio:' + currentRatio)
          // 可见之后，将变量恢复成初始状态，保证下次点击重新播放
          this.duration = 2000
          this.flag = true
        }
        if (!isExpanding && currentRatio <= 0.0) {
          console.info('Component is completely invisible.')
          // 不可见时，修改大小并设置duration为0
          this.duration = 0
          this.widthSize = 250
          this.heightSize = 100
          // 不可设置与原始目的地相同
          // this.widthSize = 150
          // this.heightSize = 60
        }
      })
    }
}
// [End Anim_power_case_2]

// [Start Anim_power_case_3]
@Component
export struct MyAnimateToExample_Visible {
  @State widthSize: number = 250;
  @State heightSize: number = 100;
  @State rotateAngle: number = 0;
  private flag: boolean = true;
  @State isVisble:boolean = false; // 初始状态置为false

  build() {
    Column() {
      Button('change size')
        .width(this.widthSize)
        .height(this.heightSize)
        .margin(30)
        .onClick(() => {
          if (this.flag && this.isVisble) {
            // 建议使用this.getUIContext()?.animateTo()
            this.getUIContext()?.animateTo({
              duration: 2000,
              curve: Curve.EaseOut,
              iterations: 5,
              playMode: PlayMode.Normal,
              onFinish: () => {
                console.info('Animation naturally play end');
              }
            }, () => {
              this.widthSize = 150;
              this.heightSize = 60;
            })
          } else {
            // 需要停止该动画时，设置一个duration为0animateTo覆盖掉原本的animate，观感上原有下发的动效已停止。不可设置duration大于0的动效。
            this.getUIContext()?.animateTo({
              duration: 0,
              onFinish: () => {
                console.info('use duration 0 animateTo to end');
              }
            }, () => {
              this.widthSize = 250;
              this.heightSize = 100;
            })
          }
          this.flag = !this.flag;
        })
        .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
          if (isExpanding && currentRatio >= 1.0) {
            console.info('Component' +
              ' is fully visible. currentRatio:' + currentRatio)
            this.isVisble = true
          }
          if (!isExpanding && currentRatio <= 0.0) {
            console.info('Component is completely invisible.')
            this.getUIContext()?.animateTo({
              duration: 0,
              onFinish: () => {
                console.info('use duration 0 animateTo to end');
              }
            }, () => {
              this.widthSize = 250;
              this.heightSize = 100;
              this.isVisble = false
            })
          }})
    }.width('100%').margin({ top: 5 })
  }
}
// [End Anim_power_case_3]


// [Start Anim_power_case_4]
let expectedFrameRate: ExpectedFrameRateRange = {
  min: 0,
  max: 120,
  expected: 30
}

@Component
export struct MyAnimatorTest {
  private TAG: string = '[AnimatorTest]'
  private backAnimator: AnimatorResult | undefined = undefined
  private flag: boolean = false
  @State wid: number = 100
  @State hei: number = 100

  create() {
    this.backAnimator = this.getUIContext()?.createAnimator({
      // 建议使用 this.getUIContext().createAnimator()接口
      duration: 5000,
      easing: "ease",
      delay: 0,
      fill: "forwards",
      direction: "normal",
      iterations: 1,
      begin: 100, //动画插值起点
      end: 200, //动画插值终点
    })
    this.backAnimator.setExpectedFrameRateRange(expectedFrameRate)
    this.backAnimator.onFinish = () => {
      this.flag = true
      console.info(this.TAG, 'backAnimator onFinish')
    }
    this.backAnimator.onRepeat = () => {
      console.info(this.TAG, 'backAnimator repeat')
    }
    this.backAnimator.onCancel = () => {
      console.info(this.TAG, 'backAnimator cancel')
    }
    this.backAnimator.onFrame = (value: number) => {
      this.wid = value
      this.hei = value
    }
  }

  aboutToDisappear() {
    // 由于backAnimator在onframe中引用了this, this中保存了backAnimator，
    // 在自定义组件消失时应该将保存在组件中的backAnimator置空，避免内存泄漏
    this.backAnimator?.finish();
    this.backAnimator = undefined;
  }

  build() {
    Column() {
      Column() {
        Column()
          .width(this.wid)
          .height(this.hei)
          .backgroundColor(Color.Red)
          .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
            if (!isExpanding && currentRatio <= 0.0) {
              console.info('Component is completely invisible.')
              this.backAnimator?.pause()
            }
          })
      }
      .width('100%')
      .height(300)

      Column() {
        Row() {
          Button('create')
            .fontSize(30)
            .fontColor(Color.Black)
            .onClick(() => {
              this.create()
            })
        }
        .padding(10)

        Row() {
          Button('play')
            .fontSize(30)
            .fontColor(Color.Black)
            .onClick(() => {
              this.flag = false
              if (this.backAnimator) {
                this.backAnimator.play()
              }
            })
        }
        .padding(10)
      }
    }
  }
}
// [End Anim_power_case_4]