/**
 * FAQ: Native侧获取env具有线程限制，如何在C++子线程触发ArkTS侧回调
 */
// [Start add_ts_callback]
import testNapi from 'libentry.so';

@Entry
@Component
struct Index {
  result: number = 0;
  // [StartExclude add_ts_callback]
  build() {
    Column() {

    }
    // [EndExclude add_ts_callback]
    .onClick(() => {
      testNapi.addTSFCallback(2, 3, (nativeResult: number) => {
        this.result = nativeResult;
      });
    })
    // [End add_ts_callback]
  }
}