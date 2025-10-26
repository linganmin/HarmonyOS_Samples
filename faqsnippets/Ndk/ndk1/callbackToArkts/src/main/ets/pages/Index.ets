//FAQ:ArkTS侧如何接收Native侧的键值对进行修改并返回到Native侧
// [Start call_back_to_arkts_ets]
import testNapi from 'libentry.so';
// [StartExclude call_back_to_arkts_ets]
const DOMAIN = 0x0000;

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  // [EndExclude call_back_to_arkts_ets]
  build() {
    // [StartExclude call_back_to_arkts_ets]
    Row() {
      Column() {
        Text(this.message)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
            // [EndExclude call_back_to_arkts_ets]
          .onClick(() => {
            let data: Record<string, number> = testNapi.callbackToArkTS((value: object) => {
              let obj: Record<string, number> = value as Record<string, number>;
              console.info("pre type:" + obj["type"].toString())
              console.info(JSON.stringify(value))
              obj["type"] += 10;
              return value;
            });
            console.info(JSON.stringify(data))
          })
      }
      // [End call_back_to_arkts_ets]
      .width('100%')
    }
    .height('100%')
  }
}
