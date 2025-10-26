/**
 * 最佳实践：JSCrash问题案例分析
 */

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
        .onClick(()=>{
          hidebug.getPss();
          // [Start TestJSError]
          throw new Error("TEST JS ERROR")
          // [End TestJSError]
        })

    }
    .height('100%')
    .width('100%')
  }
}