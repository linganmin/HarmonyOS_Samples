import { common } from '@kit.AbilityKit';
import { MyDataSource } from '../common/MyDataSource';

@Component
struct TestCode {
  list: number[] = []
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private swiperController: SwiperController = new SwiperController();
  data: MyDataSource<number> = new MyDataSource()

  // [Start swiper_core_code]
  aboutToAppear(): void {
    for (let i = 0; i < 1000; i++) {
      this.list.push(i);
      this.data.addData(i, i);
    }
  }

  build() {
    Column() {
      Swiper(this.swiperController) {
        ForEach(this.list, (item: number, index: number) => {
          SwiperItem({ myIndex: index })
            .width('100%')
            .height("100%")
        }, (item: string) => item)
      }
      // ...
    }
    .width('100%')
    .margin({ top: 5 })
  }
  // [End swiper_core_code]
}
interface ConstantTest {
  imgURL: string[]
}
const Constant: ConstantTest = {
  imgURL: ['1']
}

// [Start swiper_core_swiper_item]
@Component
struct SwiperItem {
  private data: number[] = [];
  private myIndex: number = 0;
  // Construct data
  private imgURL: string[] = Constant.imgURL;

  aboutToAppear(): void {
    for (let i = 0; i < 50; i++) {
      this.data.push(i);
    }
  }

  build() {
    Column() {
      List({ space: 20 }) {
        ForEach(this.data, (index: number) => {
          ListItem() {
            Image(this.imgURL[this.myIndex * 50 + index])
              .objectFit(ImageFit.Contain)
              .width("100%")
              .height("100%")
          }
          .aspectRatio(1)
          .border({ width: 2, color: Color.Green })
        }, (index: number) => index.toString());
      }
      // ...
    }
    // ...
  }
}
// [End swiper_core_swiper_item]

class NumberDataSource extends  MyDataSource<number> {

}

// [Start swiper_core_test_two]
@Component
struct TestCodeTwo {
  private dataSrc: NumberDataSource = new NumberDataSource();

  aboutToAppear(): void {
    for (let i = 0; i < 20; i++) {
      this.dataSrc.addData(i, i);
    }
  }

  build() {
    Column({ space: 5 }) {
      Swiper() {
        LazyForEach(this.dataSrc, (item: number, index: number) => {
          SwiperItem({
            myIndex: index
          });
        }, (item: number) => item.toString());
      }
      .cachedCount(1)
      .autoPlay(true)
      .interval(1000)
      .duration(100)
      // ...
    }.width('100%')
    .margin({ top: 5 })
  }
}
// [End swiper_core_test_two]