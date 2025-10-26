// DocsCode 1
import testNapi from 'libentry.so';

@Entry
@Component
struct Index {
  @State message: string = 'Get Screen Brightness';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            testNapi.napiLoadModule("@system.brightness");
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// DocsCode 1