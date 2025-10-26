/**
 * FAQ:使用Text嵌套Span或者使用熟悉字符串渲染文本，部分文本颜色显示异常
 */

// [Start render_text_1]
@Entry
@Component
struct Index {
  build() {
    Column() {
      Text() {
        Span('r')
          .fontColor(Color.Blue)
        Span('f')
          .fontColor(Color.Red)
      }
      .fontSize(50)
    }
    .width('100%')
    .height('100%')
  }
}

// [End render_text_1]