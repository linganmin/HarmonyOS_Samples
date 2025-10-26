/**
 * 最佳实践:高效利用HWC的低功耗设计
 */
// [Start ArkUI]
@Entry
@Component
struct ArkUISample {
  @State message: string = 'Hello World';
  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End ArkUI]