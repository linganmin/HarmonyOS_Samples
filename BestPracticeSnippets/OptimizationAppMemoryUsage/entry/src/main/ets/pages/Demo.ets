// [Start demo_page]
import { LRUCacheUtil } from '../utils/LRUCacheUtil';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    const lruCache: LRUCacheUtil = LRUCacheUtil.getInstance();
    // Add a <key, value> to lrucache
    lruCache.putCache('nation',10);
    // Add another <key, value> to lrucache
    lruCache.putCache('menu',8);
    // Query value through key
    const result0: number = lruCache.getCache('2') as number;
    console.log('result0:' + result0);
    // Delete the specified key and its associated values from the current buffer
    lruCache.remove('2');
    // Check whether the current buffer contains the specified object
    const result2: boolean = lruCache.contains('1');
    console.log('result2:' + result2);
    // Set a new capacity size
    lruCache.updateCapacity(110);
  }


  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        // [Start media_image]
        Column() {
          Image($r('app.media.image'))
            .width("500px")
            .height("500px")
        }
        // [End media_image]
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End demo_page]