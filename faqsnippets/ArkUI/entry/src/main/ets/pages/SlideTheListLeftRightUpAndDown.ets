/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何实现列表既可以左右滑、又可以上下滑动
*/

// [Start slide_the_list_left_right_up_and_down_one]
import { CommonDataSource } from '../viewmodel/CommonDataSource';


@Observed
class ListItemData {
  text: string = '';
  id: string = '';
}


@Observed
class ListData {
  id: string = '';
  fundName: string = '';
  textDataSource: CommonDataSource<ListItemData> = new CommonDataSource<ListItemData>();
}


@Entry
@Component
struct ScrollListDemoPage {
  // Horizontal scrolling distance of list data
  @State remainOffset: number = 0;
  // Maintain a list controller array to store ListScrollers for all horizontal lists
  @State listScrollerArr: ListScroller[] = [];
  // The starting index of the list is used to refresh the list area displayed on the current screen
  @State startIndex: number = 0;
  // End index of list
  @State endIndex: number = 0;
  // List Data - Displayed Content
  @State listData: ListItemData[] = [];
  // Head title list, titles for each column
  private titleList: string[] = [];
  // List data source
  private dataSource = new CommonDataSource<ListData>();
  // Vertical scrolling of list data
  verticalScroller: Scroller = new Scroller();
  // Horizontal scrolling of list data
  horizontalScroller: Scroller = new Scroller();
  // Scroll the left name column
  leftScroller: Scroller = new Scroller();
  // Head title column scrolling
  topScroller: Scroller = new Scroller();
  // Head Title List Data Source
  headerList = new CommonDataSource<string>();
  // Actual processed data
  showList: ListData[] = [];


  aboutToAppear(): void {
    this.loadData();
  }


  loadData() {
    for (let i = 0; i < 30; i++) {
      this.titleList.push('title' + i);
      let itemData: ListItemData = {
        text: 'content' + i,
        id: i + ''
      };
      this.listData.push(itemData);
    }
    this.headerList.setData(this.titleList);


    for (let i = 0; i < 20; i++) {
      // Every time the next page of data is obtained, it is necessary to synchronously add a controller to the list
      this.listScrollerArr.push(new ListScroller());
      let listItemData: ListData = new ListData();
      listItemData.fundName = 'Equity fund' + i;
      listItemData.id = 'Equity fund' + i;
      listItemData.textDataSource = new CommonDataSource<ListItemData>();
      listItemData.textDataSource.setData(this.listData);
      this.showList.push(listItemData);
    }
    this.dataSource.setData(this.showList);
  }


  build() {
    Column() {
      // Headline Title
      this.titleBuilder()
      // Divider
      Divider()
        .strokeWidth('100%')
        .color(0xeeeeee)


      Row() {
        // Left column
        this.leftBuilder()
        // Right column
        this.rightScroll()
      }
    }
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }


  @Builder
  titleBuilder() {
    Row() {
      Column() {
        Text('name')
      }
      .width(140)
      .height(48)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16 })


      // Top Title List
      List({ scroller: this.topScroller }) {
        LazyForEach(this.headerList, (item: string) => {
          ListItem() {
            Text(item)
              .height(48)
              .width(120)
              .textAlign(TextAlign.Start)
              .padding({ left: 16 })
              .backgroundColor(0xFFFFFF)
          }
        }, (item: string) => item)
      }
      .listDirection(Axis.Horizontal)
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .width('calc(100% - 140vp)')
      .layoutWeight(1)
      .onScrollFrameBegin((offset: number) => {
        for (let i = this.startIndex; i <= this.endIndex; i++) {
          this.listScrollerArr[i].scrollTo({
            xOffset: this.topScroller.currentOffset().xOffset + offset,
            yOffset: 0,
            animation: false
          });
        }
        return { offsetRemain: offset };
      })
    }
    .height(48)
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }


  @Builder
  leftBuilder() {
    List({ scroller: this.leftScroller }) {
      LazyForEach(this.dataSource, (item: ListData) => {
        ListItem() {
          Column() {
            Text(item.fundName)
              .height('100%')
              .backgroundColor(0xFFFFFF)
              .layoutWeight(1)
              .margin({ left: 16 })
            Divider()
              .strokeWidth('100%')
              .color(0xeeeeee)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
        }
        .height(60)
      }, (item: ListData) => JSON.stringify(item))
    }
    .listDirection(Axis.Vertical)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .height('calc(100% - 48vp)')
    .width(140)
    .onScrollFrameBegin((offset: number) => {
      this.verticalScroller.scrollTo({
        xOffset: 0,
        yOffset: this.leftScroller.currentOffset().yOffset + offset,
        animation: false
      });
      return { offsetRemain: offset };
    })
  }


  @Builder
  rightScroll() {
    Scroll(this.horizontalScroller) {
      List({ initialIndex: 0, scroller: this.verticalScroller }) {
        LazyForEach(this.dataSource, (item: ListData, index: number) => {
          ListItem() {
            Column() {
              List({ scroller: this.listScrollerArr[index] }) {
                LazyForEach(item.textDataSource, (item: ListItemData) => {
                  ListItem() {
                    Text(item.text)
                      .height('100%')
                      .width('100%')
                      .textAlign(TextAlign.Start)
                      .padding({ left: 16 })
                      .backgroundColor(0xFFFFFF)
                      .fontColor('#ffe72929')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width(120)
                }, (item: ListItemData, index: number) => JSON.stringify(item) + index + '')
              }
              .cachedCount(4)
              .height('100%')
              .width('100%')
              .layoutWeight(1)
              .listDirection(Axis.Horizontal)
              .scrollBar(BarState.Off)
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.PARENT_FIRST
              })
              .edgeEffect(EdgeEffect.None)
              .onDidScroll(() => {
                this.remainOffset = this.listScrollerArr[index]!.currentOffset().xOffset;
              })
              .onScrollFrameBegin((offset: number) => {
                this.topScroller.scrollTo({
                  xOffset: this.listScrollerArr[index]!.currentOffset().xOffset + offset,
                  yOffset: 0,
                  animation: false
                });
                for (let i = this.startIndex; i <= this.endIndex; i++) {
                  if (i !== index) {
                    this.listScrollerArr[i].scrollTo({
                      xOffset: this.listScrollerArr[index]!.currentOffset().xOffset + offset,
                      yOffset: 0,
                      animation: false
                    });
                  }
                }
                return { offsetRemain: offset };
              })


              Divider()
                .strokeWidth('100%')
                .color(0xeeeeee)
            }
            .height(60)
          }
        }, (item: ListData) => JSON.stringify(item))
      }
      .height('100%')
      .cachedCount(2)
      .flingSpeedLimit(1600)
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
      .onScrollFrameBegin((offset: number) => {
        this.leftScroller.scrollTo({
          xOffset: 0,
          yOffset: this.verticalScroller.currentOffset().yOffset + offset,
          animation: false
        });
        return { offsetRemain: offset };
      })
      .onScrollIndex((start: number, end: number) => {
        this.startIndex = start;
        this.endIndex = end;
        // Scroll only the items within the current display range
        for (let i = start; i <= end; i++) {
          this.listScrollerArr[i].scrollTo({ xOffset: this.remainOffset, yOffset: 0, animation: false });
        }
      })
    }
    .position({ x: 140, y: 0 })
    .onDidScroll(() => {
      this.topScroller.scrollTo({ xOffset: this.remainOffset, yOffset: 0, animation: false });
    })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .scrollable(ScrollDirection.Horizontal)
    .backgroundColor(0xDCDCDC)
    .height('calc(100% - 48vp)')
    .width('calc(100% - 140vp)')
  }
}
// [End slide_the_list_left_right_up_and_down_one]

