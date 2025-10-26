/**
 * FAQ:ArkTS侧与Native侧分别如何动态加载SO库
 */
// [Start import_so]
import { hilog } from '@kit.PerformanceAnalysisKit';
// import testNapi from 'libentry.so';

@Entry
@Component
struct LoadSoLibrary {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(async() => {
            let testNapi = await import("libentry.so")            // Load so library
            hilog.info(0x0000, 'testTag', 'Test NAPI 2 + 3 = %{public}d', testNapi.default.add(2, 3));   // Call library functions by default
            // hilog.info(0x0000, 'testTag', 'Test NAPI 2 + 3 = %{public}d', testNapi.add(2, 3));
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End import_so]