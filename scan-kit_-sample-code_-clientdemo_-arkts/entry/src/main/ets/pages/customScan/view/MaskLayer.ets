import { curves } from "@kit.ArkUI"

@Extend(Column)
function maskStyle() {
  .width('100%')
  .height('100%')
  .backgroundColor('rgba(0,0,0,0.5)')
  .animation({
    duration: 350, // Animation duration.
    curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), // Animation curve.
    delay: 0,
    iterations: 1,
    playMode: PlayMode.Alternate,
  })
}

@Component
export struct MaskLayer {
  build() {
    Column().maskStyle()
  }
}