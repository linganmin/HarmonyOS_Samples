/**
 * FAQ:如何清除输入框焦点？
 */
@Component
struct ClearFocus {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    // [Start clear_focus]
    this.getUIContext().getFocusController().clearFocus()
    // [End clear_focus]
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
}