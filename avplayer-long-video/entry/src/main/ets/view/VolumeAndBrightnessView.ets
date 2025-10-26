import { AVVolumePanel } from "@kit.AudioKit"

@Component
export struct VolumeAndBrightnessView {
  @Prop visible: boolean; // Whether to show slider/image
  @Prop volume: number; // Set original video volume number
  @Prop screenBrightness: number; // Screen luminance

  build() {
    Row() {
      Column() {
        AVVolumePanel({
          volumeLevel: this.volume,
          volumeParameter: {
            position: {
              x: 150,
              y: 300
            }
          }
        })
      }
      .width('50%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      // [Start SetScreenBrightnessSlider]
      Column() {
        Stack() {
          Slider({
            value: this.screenBrightness,
            min: 0,
            max: 1,
            step: 0.05,
            style: SliderStyle.NONE,
            direction: Axis.Vertical,
            reverse: true
          })
            .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
            .height(160)
            .selectedColor(Color.White)
            .trackColor(Color.Black)
            .trackThickness(40)

          Image($r('app.media.sun_max_fill'))
            .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
            .margin({ top: 120 })
            .width(20)
            .height(20)
        }
        .margin({
          top: 0,
          right: 0
        })
      }
      .width('50%')
      .alignItems(HorizontalAlign.End)
      .justifyContent(FlexAlign.Center)
      .padding({
        right: 30,
        bottom: 20
      })

      // [End SetScreenBrightnessSlider]
    }
    .height('100%')
    .width('100%')
  }
}