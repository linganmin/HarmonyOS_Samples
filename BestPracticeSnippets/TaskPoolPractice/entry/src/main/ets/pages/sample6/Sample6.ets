import { taskpool } from '@kit.ArkTS';
import { BusinessError } from '@ohos.base';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start return_1]
// Sample6.ets
@Concurrent
async function returnModule() {
  let module = await import('./a');
  return module;
}
// [End return_1]

// [Start return_3]
// Sample6.ets
@Concurrent
async function returnPromise() {
  let promise = new Promise<void>((resolve) => {
    setTimeout(() => {
      resolve();
    }, 1000);
  })
  return promise;
}
// [End return_3]

@Entry
@Component
struct Sample4 {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column({ space: 12 }) {
        Blank()
        Button('TaskPool Thread return module')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start return_2]
            // Sample6.ets
            taskpool.execute(returnModule).catch((e: BusinessError) => {
              hilog.error(0xFF00, 'sampleTag', "error info: " + e.message);
            })
            // [End return_2]
          })

        Button('TaskPool Thread return promise')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start return_4]
            // Sample6.ets
            taskpool.execute(returnPromise).catch((e: BusinessError) => {
              hilog.error(0xFF00, 'sampleTag', "error info: " + e.message);
            })
            // [End return_4]
          })
      }
      .height('100%')
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)
    }
    .height('100%')
  }
}