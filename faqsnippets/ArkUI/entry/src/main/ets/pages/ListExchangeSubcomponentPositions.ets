@Entry
@Component
struct Index {
  @State listArr: string[] = [];

  @Builder
  textItemBuilder(text: string) {
    Column() {
      Text(text)
        .fontSize(16)
        .backgroundColor(0xDCDCDC)
        .width(80)
        .height(80)
        .textAlign(TextAlign.Center)
    }
  }

  aboutToAppear() {
    for (let i = 0; i < 16; i++) {
      this.listArr.push(i + '');
    }
  }

  // Swap the position of listItem in the listArr array
  changeListItemIndex(index1: number, index2: number) {
    let tempItem = this.listArr[index1];
    this.listArr[index1] = this.listArr[index2];
    this.listArr[index2] = tempItem;
  }

  build() {
    Column() {
      List() {
        ForEach(this.listArr, (item: string) => {
          ListItem() {
            Text(item)
          }
          .width(80)
          .height(80)
          .backgroundColor(Color.White)
          .borderRadius(4)
          .margin({ top: 10 })
        }, (item: string) => item)
      }
      .width('100%')
      .height(500)
      .lanes({ minLength: 80, maxLength: 80 })
      .alignListItem(ListItemAlign.Center)
      .onItemDragStart((event: ItemDragInfo, index: number) => {
        return this.textItemBuilder(this.listArr[index]);
      })
      .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
        if (!isSuccess || insertIndex < 0 || insertIndex >= this.listArr.length) {
          return;
        }
        this.changeListItemIndex(itemIndex, insertIndex);
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
  }
}