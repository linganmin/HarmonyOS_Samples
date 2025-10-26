/**
 * FAQ: 在Native侧如何集成三方SO库
 */
// [Start dlopen_so_ets]
import { hilog } from '@kit.PerformanceAnalysisKit';
import testNapi from 'libentry.so';

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
            let path = this.getUIContext().getHostContext()!.bundleCodeDir; // Get project path
            hilog.info(0x0000, 'testTag', 'Test NAPI 2 + 3 = %{public}d', testNapi.subSobyDlOpenSo(2, 3, path + '/libs/arm64/libnativeSub.so')); // Transfer parameter path information to the native side
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End dlopen_so_ets]