// [Start song_info1]
import { Header } from './header'
import { SongInfoItem } from './song';
import DataSourcePrefetching from '../model/ArticleListData';
import { ObservedArray } from '../utils/ObservedArray';
import { ReusableArticleCardView } from '../components/ReusableArticleCardView';
import Constants from '../constants/Constants';
import { PageViewModel } from './song';
import { BasicPrefetcher } from '@kit.ArkUI';
@Entry
@Component
export struct LazyForEachListPage {
  @State collectedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State likedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State isListReachEnd: boolean = false;
  // Create a DataSourcePrefetching object, which is a data source with task prefetching and cancellation capabilities.
  private readonly dataSource :ESObject= new DataSourcePrefetching(PageViewModel.getItems());
  // Create a BasicPrefetcher object, which is realized by the default dynamic prefetching algorithm.
  private readonly prefetcher = new BasicPrefetcher(this.dataSource);

  build() {
    Column() {
      Header()
      List({ space: Constants.SPACE_16 }) {
        LazyForEach(this.dataSource, (item: SongInfoItem ) => {
          ListItem() {
            ReusableArticleCardView({ articleItem: item })
          }
          .reuseId('article')
        })
      }
      .cachedCount(5)
      .onScrollIndex((start: number, end: number) => {
        // List scrolling triggers visibleareachan, updates the prefetch range in real time, and triggers calling prefetch and cancel interfaces.
        this.prefetcher.visibleAreaChanged(start, end)
      })
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .padding({ left: 10, right: 10 })
      .layoutWeight(1)
    }
    .backgroundColor($r('app.color.text_background'))
  }
}
// [End song_info1]