// [Start Comment_dialog]
@CustomDialog
struct CommentDialog {
  listData: string[] = ['comments1', 'comments2', 'comments3', 'comments4', 'comments5', 'comments6', 'comments7', 'comments8'];
  controller?: CustomDialogController;


  build() {
    Column() {
      Text('comments')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)


      List() {
        ForEach(this.listData, (item: string) => {
          ListItem() {
            Text(item)
              .height(80)
              .fontSize(20)
          }
        }, (item: string) => item)
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)


      TextInput({ placeholder: 'Please input content' })
        .height(40)
        .width('100%')
    }
    .padding(12)
  }
}


@Entry
@Component
struct CustomDialogDemo {
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CommentDialog(),
    alignment: DialogAlignment.Bottom,
    cornerRadius: 0,
    width: '100%',
    height: '80%'
  })


  build() {
    Column() {
      Button('click me')
        .onClick(() => {
          if (this.dialogController !== null) {
            this.dialogController.open();
          }
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}
// [End Comment_dialog]