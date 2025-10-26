/**
 * 最佳实践：JS Crash问题排查方法
 */

// [Start JSCrashQuestionCheck]
import { hidebug } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          hidebug.getPss();
        })
    }
    .height('100%')
    .width('100%')
  }
}
// [End JSCrashQuestionCheck]