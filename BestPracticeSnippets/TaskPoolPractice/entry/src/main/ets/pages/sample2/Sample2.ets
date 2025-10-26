// [Start con_1]
// Sample2.ets
import { http } from '@kit.NetworkKit';
import { taskpool } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Concurrent
function concurrentFunc() {
  let httpRequest = http.createHttp();
  httpRequest.on('headersReceive', (header: Object) => {
    hilog.info(0xFF00, 'sampleTag', 'header: ' + JSON.stringify(header));
  });

  httpRequest.on('dataEnd', () => {
    hilog.info(0xFF00, 'sampleTag', 'No more data in response, data receive end');
  });
}

// [End con_1]

@Entry
@Component
struct Sample2 {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column({ space: 12 }) {
        Blank()
        Button('Wrong Sample')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start con_2]
            // Sample2.ets
            taskpool.execute(concurrentFunc)
              .then(() => {
                hilog.info(0x000, 'testTag', 'execute success');
              })
              .catch((err: BusinessError) => {
                hilog.error(0x000, 'testTag', `execute failed, code=${err.code}, message=${err.message}`);
              })
            // [End con_2]
          })

        Button('Correct Sample')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start task_1]
            // Sample2.ets
            let task: taskpool.LongTask = new taskpool.LongTask(concurrentFunc);
            taskpool.execute(task)
              .then(() => {
                hilog.info(0xFF00, 'sampleTag', 'receive http msg success.');
                taskpool.terminateTask(task);
              })
              .catch((err: BusinessError) => {
                hilog.error(0x000, 'testTag', `execute failed, code=${err.code}, message=${err.message}`);
              })
            // [End task_1]
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