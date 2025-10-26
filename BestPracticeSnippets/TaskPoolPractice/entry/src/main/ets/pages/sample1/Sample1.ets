// [Start bar]
// Sample1.ets
import { Bar } from './wrong/a';
import { BusinessError } from '@ohos.base';
import { taskpool } from '@kit.ArkTS';
import { Foo } from './correct/b';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [End bar]

// [Start wrong]
// Sample1.ets
@Concurrent
function wrongConcurrentFunc() {
  try {
    let bar: Bar = new Bar;
  } catch (e) {
    let error: BusinessError = e;
    hilog.error(0xFF00, 'sampleTag', 'error occur: ' + error.message);
  }
}

// [End wrong]

// [Start sample_fun]
// Sample1.ets
@Concurrent
function correctConcurrentFunc() {
  let foo: Foo = new Foo;
}

// [End sample_fun]

@Entry
@Component
struct Sample1 {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column({ space: 12 }) {
        Blank()
        Button('Wrong Sample')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start task_pool]
            // Sample1.ets
            taskpool.execute(wrongConcurrentFunc)
              .then(() => {
                hilog.info(0x000, 'testTag', 'execute success');
              })
              .catch((err: BusinessError) => {
                hilog.error(0x000, 'testTag', `execute failed, code=${err.code}, message=${err.message}`);
              })
            // [End task_pool]
          })

        Button('Correct Sample')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start correct_fun]
            // Sample1.ets
            taskpool.execute(correctConcurrentFunc)
              .then(() => {
                hilog.info(0x000, 'testTag', 'execute success');
              })
              .catch((err: BusinessError) => {
                hilog.error(0x000, 'testTag', `execute failed, code=${err.code}, message=${err.message}`);
              })
            // [End correct_fun]
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