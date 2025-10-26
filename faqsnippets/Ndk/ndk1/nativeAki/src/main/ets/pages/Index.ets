/**
 * FAQ:如何通过AKI三方库实现ArkTS与C/C++之间的跨语言调用
 */
// [Start aki_jsbind_ets]
import aki from 'libentry.so' // *. so compiled from the project

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            console.info(aki.SayHello("hello world")); // 调用.so文件中的代码接口
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End aki_jsbind_ets]