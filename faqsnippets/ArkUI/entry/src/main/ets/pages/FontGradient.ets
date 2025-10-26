/**
 * FAQ:如何实现字体渐变效果
 */

// [Start font_gradient]
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Row() {
        Text(this.message)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
      }
      .linearGradient({
        direction: GradientDirection.Right,
        colors: [['#ff0631f5', 0.0], ['#ff922626', 1]]
      })
      .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
    }
    .width('100%')
    .height('100%')
  }
}
// [End font_gradient]