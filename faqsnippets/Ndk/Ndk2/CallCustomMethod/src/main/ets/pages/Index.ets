import testNapi from 'libcallcustommethod.so';

@Entry
@Component
struct Index {
  @State message: string = 'Call Custom Method';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            console.info(`Test value is ${testNapi.loadModule()}`);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
