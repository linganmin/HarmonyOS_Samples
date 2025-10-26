import { ErrorEvent, taskpool } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

// [Start sample_6]
// Sample4.ets
@Observed
class Foo {
  id: number = 0;
  name: string = "foo"
}

@Concurrent
function correctConcurrentFunc1(foo: Foo) {
  console.info("the id is: " + foo.id);
}
// [End sample_6]


// [Start sample_4]
// Sample4.ets
@Concurrent
function correctConcurrentFunc() {
  let count: number = 0;
  let id = setInterval(() => {
    count++;
    if (count == 10) {
      hilog.info(0xFF00, 'sampleTag', "the value has reached the threshold");
      clearInterval(id);
    }
  }, 1000);
}
// [End sample_4]



// [Start sample_8]
// Sample4.ets
@Concurrent
function correctConcurrentFunc2() {
  let error: Error = new Error("TaskPoolThread error");
  throw error;
}
// [End sample_8]

@Entry
@Component
struct Sample4 {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column({ space: 12 }) {
        Blank()
        Button('CorrectSample timer')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start sample_5]
            // Sample4.ets
            let task: taskpool.Task = new taskpool.Task(correctConcurrentFunc);
            taskpool.execute(task)
              .then(() => {
                hilog.info(0xFF00, 'sampleTag', 'receive http msg success.');
              })
              .catch((err: BusinessError) => {
                hilog.error(0x000, 'testTag', `execute failed, code=${err.code}, message=${err.message}`);
              })
            // [End sample_5]
          })

        Button('Correct Sample MainThread Catch')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start sample_7]
            // Sample4.ets
            try {
              let foo = new Foo();
              taskpool.execute(correctConcurrentFunc1, foo)
                .then(() => {
                  hilog.info(0xFF00, 'sampleTag', 'receive http msg success.');
                })
                .catch((err: BusinessError) => {
                  hilog.error(0x000, 'testTag', `execute failed, code=${err.code}, message=${err.message}`);
                })
            } catch (e) {
              let error: ErrorEvent = e;
              hilog.error(0xFF00, 'sampleTag', "error info: " + error.message);
            }
            // [End sample_7]
          })

        Button('Correct Sample TaskPoolThread Catch')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start sample_9]
            // Sample4.ets
            taskpool.execute(correctConcurrentFunc2).catch((error: BusinessError) => {
              hilog.error(0xFF00, 'sampleTag', "error info: " + error.message);
            })
            // [End sample_9]
            // Sample4.ets
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