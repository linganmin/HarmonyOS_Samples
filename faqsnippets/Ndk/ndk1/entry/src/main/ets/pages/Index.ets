/**
 * FAQ: Native如何调ArkTS的方法
 */
// [Start native_call_arkts_ets]
// Introduce native capabilities through import.
import nativeModule from 'libentry.so'


@Entry
@Component
struct InvokeArkTSMethod {
  @State message: string = 'Test Node-API nativeCallArkTS result: ';


  build() {
    Row() {
      Column() {
        // Call the nativeCallArkTS method, corresponding to the Native NativeCallArkTS, and call the ArkTS function in Native.
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message += nativeModule.nativeCallArkTS((a: number) => {
              return a * 2;
            });
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End native_call_arkts_ets]