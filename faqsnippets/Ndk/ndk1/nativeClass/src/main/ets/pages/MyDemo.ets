/**
 * FAQ: 如何导出C++自定义类，导出后如何在ArkTS侧进行类方法调用
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
// [Start native_class_ets]
import testNapi from 'libentry.so';
// [StartExclude native_class_ets]
const fun = ()=>{
  // [EndExclude native_class_ets]
  // ...
  new testNapi.MyDemo('abc');
  hilog.info(0x0000, 'testTag', 'Test NAPI 2 + 3 = %{public}d', testNapi.add(2, 3));
  hilog.info(0x0000, 'testTag', 'Test NAPI 2 - 3 = %{public}d', testNapi.sub(2, 3));
  // ...
  // [End native_class_ets]
}
