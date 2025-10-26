import { MyDataSource } from '../common/MyDataSource';

class PixelMapDataSource extends MyDataSource<number[]> {}

@Component
struct SwiperItem {
  @Provide myIndex: number = 0
  @Provide dataSource: PixelMapDataSource = new PixelMapDataSource();
  build() {

  }
}

// [Start swiper_no_pre_load_data]
@Entry
@Component
struct NoPreLoadData {
  private dataSrc: PixelMapDataSource = new PixelMapDataSource();


  aboutToAppear(): void {
    for (let i = 0; i < 20; i++) {
      this.dataSrc.addData(i, []);
    }
  }


  build() {
    Column({ space: 5 }) {
      Swiper() {
        LazyForEach(this.dataSrc, (item: PixelMap[], index: number) => {
          SwiperItem({
            myIndex: index,
            dataSource: this.dataSrc
          });
        }, (item: number, index: number) => index.toString());
      }
      // ...
    }
    .width('100%')
    .margin({ top: 5 })
  }
}
// [End swiper_no_pre_load_data]