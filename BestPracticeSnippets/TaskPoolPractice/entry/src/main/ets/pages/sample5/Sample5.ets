// [Start pool_1]
// Sample5.ets
import { taskpool } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Concurrent
function imageProcessing(dataSlice: ArrayBuffer): ArrayBuffer {
  // Step 1: Specific image processing operations and other time-consuming operations.
  return dataSlice;
}

function histogramStatistic(pixelBuffer: ArrayBuffer): void {
  // Step 2: Divide into three segments for concurrent scheduling.
  let number: number = pixelBuffer.byteLength / 3;
  let buffer1: ArrayBuffer = pixelBuffer.slice(0, number);
  let buffer2: ArrayBuffer = pixelBuffer.slice(number, number * 2);
  let buffer3: ArrayBuffer = pixelBuffer.slice(number * 2);

  let group: taskpool.TaskGroup = new taskpool.TaskGroup();
  try {
    group.addTask(imageProcessing, buffer1);
    group.addTask(imageProcessing, buffer2);
    group.addTask(imageProcessing, buffer3);
  } catch (error) {
    let err = error as BusinessError;
    hilog.warn(0x000, 'testTag', `addTask failed, code=${err.code}, message=${err.message}`);
  }

  taskpool.execute(group, taskpool.Priority.HIGH)
    .then((ret: Object) => {
      // Step 3: Summarize the result array.
    })
    .catch((err: BusinessError) => {
      hilog.error(0x000, 'testTag', `execute failed, code=${err.code}, message=${err.message}`);
    })

}

// [End pool_1]

@Entry
@Component
struct Sample4 {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column({ space: 12 }) {
        Blank()
        Button('TaskGroup Sample')
          .height(40)
          .width('100%')
          .onClick(() => {
            // [Start buffer_1]
            // Sample5.ets
            let buffer: ArrayBuffer = new ArrayBuffer(24);
            histogramStatistic(buffer);
            // [End buffer_1]
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