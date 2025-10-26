// FAQ:剪贴板粘贴框遮挡智能填充选择框
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      // [Start menu_hidden]
      Row() {
        Text('consignee：').textAlign(TextAlign.End).width('25%')
        TextInput().width('75%').contentType(ContentType.PERSON_FULL_NAME).selectionMenuHidden(true)
      }
      // [End menu_hidden]
    }
    .height('100%')
    .width('100%')
  }
}