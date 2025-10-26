import { MyDataSource } from '../segment/segment1';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private data: MyDataSource = new MyDataSource();

  build() {
    RelativeContainer() {
      // [Start cached_count_list]
      List() {
        // ...
      }.cachedCount(3)
      // [End cached_count_list]

      // [Start Lazy_for_each]
      LazyForEach(this.data, (lazyForEachItem: string) => {
        ListItem() {
          Row() {
            Text(lazyForEachItem).fontSize(50)
          }.margin({ left: 10, right: 10 })
        }.onAppear(() => {
          // Record the number of times the component is created through onAppear
          console.info('appear:' + lazyForEachItem);
        })
      }, (item: string) => {
        // Print the key value in the keyGenerator function
        console.info('key:' + item);
        return item;
      })
      // [End Lazy_for_each]
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