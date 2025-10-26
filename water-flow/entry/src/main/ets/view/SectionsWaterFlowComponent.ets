/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants } from '../common/constants/CommonConstants';
import { SectionsWaterFlowDataSource } from '../viewmodel/SectionsWaterFlowDataSource';

@Reusable
struct ReusableFlowItem {
  @State item: number = 0;

  aboutToReuse(params: Record<string, number>) {
    this.item = params.item;
  }

  build() {
    RelativeContainer() {
      Image($rawfile(`sections/${this.item % 4}.jpg`))
        .objectFit(ImageFit.Cover)
        .width(CommonConstants.FULL_WIDTH)
        .layoutWeight(1)
        .borderRadius($r('app.float.sections_item_radius'))
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .id('image1')

      Stack() {
      }
      .linearGradient({
        angle: 0,
        colors: [[$r('app.color.linearGradient_first_color'), 0.0],
          [$r('app.color.linearGradient_last_color'), 1.0]]
      })
      .width(CommonConstants.FULL_WIDTH)
      .height($r('app.float.sections_item_blur_height'))
      .borderRadius($r('app.float.sections_item_radius'))
      .hitTestBehavior(HitTestMode.None)
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start },
        right: { anchor: '__container__', align: HorizontalAlign.End }
      })
      .id('mask1')

      Text('NO. ' + (this.item + 1))
        .fontSize($r('app.float.sections_item_text_size'))
        .fontColor(Color.White)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .margin({
          left: $r('app.float.sections_item_text_margin_left'),
          bottom: $r("app.float.sections_item_text_margin_bottom")
        })
        .id('text1')
    }
    .width(CommonConstants.FULL_WIDTH)
    .borderRadius($r('app.float.sections_item_radius'))
    .backgroundColor(Color.Gray)
  }
}

@Preview
@Component
export struct SectionsPage {
  @State isRefreshing: boolean = false;
  @State currentItem: number = -1;

  @State minSize: number = CommonConstants.FLOW_ITEM_MIN_HEIGHT;
  @State maxSize: number = CommonConstants.FLOW_ITEM_MAX_HEIGHT;
  scroller: Scroller = new Scroller();
  dataSource: SectionsWaterFlowDataSource = new SectionsWaterFlowDataSource();
  private itemHeightArray: number[] = [];
  @State sections: WaterFlowSections = new WaterFlowSections();
  sectionMargin: Margin = {
    top: 8,
    left: 0,
    bottom: 0,
    right: 0
  };
  oneColumnSection: SectionOptions = {
    itemsCount: 3,
    crossCount: 1,
    columnsGap: 5,
    rowsGap: 10,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return CommonConstants.SECTION1_ITEM_SIZE;
    }
  };
  twoColumnSection: SectionOptions = {
    itemsCount: 2,
    crossCount: 2,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return CommonConstants.SECTION2_ITEM_SIZE;
    }
  };
  dataSection: SectionOptions = {
    itemsCount: 20,
    crossCount: 2,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return this.itemHeightArray[index % CommonConstants.REFRESH_COUNT];
    }
  };

  @Builder
  headerRefresh() {
    Column() {
      LoadingProgress()
        .color(Color.Black)
        .opacity(0.6)
        .width($r('app.float.refresh_loading_width'))
        .height($r('app.float.refresh_loading_height'))
    }
    .justifyContent(FlexAlign.Center)
  }

  refresh() {
    this.currentItem = -1;
    setTimeout(() => {
      //Add new data.
      this.dataSource.dataArray = [];
      let value = Math.floor(Math.random() * CommonConstants.REFRESH_COUNT);
      for (let i = 0; i < CommonConstants.REFRESH_COUNT; i++) {
        this.dataSource.dataArray.push(i + value);
        this.dataSource.notifyDataAdd(i);
      }
      //Update sections itemsCount.
      this.oneColumnSection.itemsCount = 3;
      this.oneColumnSection.crossCount = 1;
      this.twoColumnSection.itemsCount = 2;
      this.twoColumnSection.crossCount = 2;
      this.dataSection.itemsCount = 95;
      this.dataSection.crossCount = 2;
      this.sections.update(0, this.oneColumnSection);
      this.sections.update(1, this.twoColumnSection);
      this.sections.update(2, this.dataSection);
      this.isRefreshing = false;
    }, CommonConstants.REFRESH_TIMEOUT);
  }

  loadMore(last: number) {
    setTimeout(() => {
      let totalCount = this.dataSource.totalCount();
      if (last + CommonConstants.LOAD_MORE_COUNT >= totalCount) {
        for (let i = 0; i < CommonConstants.LOAD_MORE_COUNT; i++) {
          this.dataSource.addLastItem();
        }
        //Update sections itemsCount.
        this.dataSection.itemsCount += CommonConstants.LOAD_MORE_COUNT;
        this.sections.update(2, this.dataSection);
      }
    }, CommonConstants.LOAD_MORE_TIMEOUT);
  }

  getSize() {
    let ret = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray() {
    for (let i = 0; i < CommonConstants.REFRESH_COUNT; i++) {
      this.itemHeightArray.push(this.getSize());
    }
  }

  initSections() {
    let sectionOptions: SectionOptions[] = [];
    let count = 0;
    let oneOrTwo = 0;
    let dataCount = this.dataSource.totalCount();
    while (count < dataCount) {
      if (dataCount - count < 96) {
        this.dataSection.itemsCount = dataCount - count;
        sectionOptions.push(this.dataSection);
        break;
      }
      if (oneOrTwo++ % 2 === 0) {
        sectionOptions.push(this.oneColumnSection);
        count += this.oneColumnSection.itemsCount;
      } else {
        sectionOptions.push(this.twoColumnSection);
        count += this.twoColumnSection.itemsCount;
      }
    }
    this.sections.splice(0, 0, sectionOptions);
  }

  removeItem(item: number): void {
    let index = this.dataSource.indexOf(item);
    this.dataSource.deleteItem(index);
    const sections: Array<SectionOptions> = this.sections.values();
    let newSection: SectionOptions;
    let tmpIndex = 0;
    let sectionIndex = 0;
    for(let i = 0; i < sections.length; i++) {
      tmpIndex += sections[i].itemsCount;
      if (index < tmpIndex) {
        sectionIndex = i;
        break;
      }
    }
    newSection = sections[sectionIndex];
    newSection.itemsCount -= 1;
    if (newSection.crossCount && newSection.crossCount > newSection.itemsCount) {
      newSection.crossCount = newSection.itemsCount;
    }
    this.sections.update(sectionIndex, newSection);
  }

  aboutToAppear() {
    this.setItemSizeArray();
    this.initSections();
  }

  build() {
    Column({ space: 0 }) {
      Refresh({ refreshing: $$this.isRefreshing, builder: this.headerRefresh()}) {
        WaterFlow({ scroller: this.scroller, sections: this.sections }) {
          LazyForEach(this.dataSource, (item: number) => {
            FlowItem() {
              Stack() {
                Row(){
                  Button($r('app.string.delete'))
                    .fontColor(Color.Red)
                    .backgroundColor(Color.White)
                    .onClick(() => {
                      this.getUIContext().animateTo({ duration: CommonConstants.DELETE_ANIMATION_TIME }, () => {
                        this.removeItem(item);
                      });
                    })
                }
                .width(CommonConstants.FULL_WIDTH)
                .height(CommonConstants.FULL_HEIGHT)
                .borderRadius($r('app.float.sections_item_radius'))
                .justifyContent(FlexAlign.Center)
                .zIndex(1)
                .visibility(this.currentItem === item ? Visibility.Visible : Visibility.Hidden)
                .backgroundColor($r('app.color.delete_background_color'))
                ReusableFlowItem({ item: item })
              }
            }
            .transition({ type: TransitionType.Delete, opacity: 0 })
            .priorityGesture(LongPressGesture()
              .onAction(() => {
                this.currentItem = item;
              }))
            .width(CommonConstants.FULL_WIDTH)
            .borderRadius($r('app.float.sections_item_radius'))
            .backgroundColor(Color.Gray)
          }, (item: string) => item)
        }
        .cachedCount(CommonConstants.CACHED_COUNT)
        .columnsGap($r('app.float.sections_margin'))
        .rowsGap($r('app.float.sections_margin'))
        //Fix last item not full display.
        .padding({ bottom: $r('app.float.water_flow_margin_bottom') })
        .width(CommonConstants.FULL_WIDTH)
        .height(CommonConstants.FULL_HEIGHT)
        .layoutWeight(1)
        //For better experience, pre load data.
        .onScrollIndex((first: number, last: number) => {
          this.loadMore(last);
        })
      }
      .refreshOffset(CommonConstants.REFRESH_OFFSET)
      .onRefreshing(() => {
        this.refresh();
      })
    }
  }
}