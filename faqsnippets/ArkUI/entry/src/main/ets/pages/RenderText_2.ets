/**
 * FAQ:使用Text嵌套Span或者使用熟悉字符串渲染文本，部分文本颜色显示异常
 */

// [Start render_text_2]
import { LengthMetrics } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  textController: TextController = new TextController();

  async onPageShow() {
    let style1: MutableStyledString = new MutableStyledString('');
    style1.appendStyledString(new StyledString('sr', [{
      start: 0,
      length: 2,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({ fontColor: Color.Blue, fontSize: LengthMetrics.px(150) })
    }]));
    style1.appendStyledString(new StyledString('fff', [{
      start: 0,
      length: 5,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({ fontColor: Color.Orange, fontSize: LengthMetrics.px(150) })
    }]));
    this.textController.setStyledString(style1);
  }

  build() {
    Row() {
      Column() {
        Text(undefined, { controller: this.textController })
          .fontSize(30)
      }
      .width('100%')
    }
    .height('100%')
  }
}

// [End render_text_2]

@Component
struct TextComponent {
  build() {
    Column() {
      // [Start font_feature]
      Text()
      // ...
        .fontFeature("\"liga\" 0")
      // [End font_feature]
    }
  }
}