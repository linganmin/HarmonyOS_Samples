/**
 * FAQ:多so相互依赖场景下如何解耦
 */
// [Start demo_so]
// index.ets
import testNapi from 'libdemoso.so';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private path: string = '';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.path = this.getUIContext().getHostContext()!.bundleCodeDir;   // get path
            hilog.info(0x0000, 'testTag', 'Test NAPI 5 + 3 = %{public}d', testNapi.add(5, 3, this.path + '/libs/arm64/liba.so'));  // Call the native side function
            hilog.info(0x0000, 'testTag', 'Test NAPI 5 - 3 = %{public}d', testNapi.sub(5, 3, this.path + '/libs/arm64/libb.so'));
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End demo_so]