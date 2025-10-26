/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { MidListDataSource } from '../model/MidListDataSource';
import { ProductDetailSource } from '../model/ProductDetailSource';
import { SwiperDataSource } from '../model/SwiperDataSource';
import displaySync from '@ohos.graphics.displaySync';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../common/CommonConstants';
import { ProductDetailModel, ProductIntroductionModel } from '../model/BasicDataSource';
// [Start Case1]
@Entry
@Component
struct TransitionScene {
  @State currentIndex: number = 0;
  private readonly LIST_SPACE: number = 10;
  private readonly FRAME_60: number = 60;
  private readonly FRAME_120: number = 120;
  private readonly SWIPER_CACHE: number = 2;
  private readonly HORIZONTAL_LIST_CACHE: number = 2;
  private swiperDataSource: SwiperDataSource = new SwiperDataSource();
  private midListDataSource: MidListDataSource = new MidListDataSource();
  private productDetailSource: ProductDetailSource = new ProductDetailSource();
  private displaySync: displaySync.DisplaySync | undefined = undefined;
  private frame: number = 1;

  aboutToAppear(): void {
    this.swiperDataSource.getProductData();
    this.midListDataSource.getProductData();

    // Creating a DisplaySync Object
    this.displaySync = displaySync.create();

    // Set the expected frame rate
    let range: ExpectedFrameRateRange = {
      expected: this.FRAME_120,
      min: this.FRAME_60,
      max: this.FRAME_120
    };
    this.displaySync.setExpectedFrameRateRange(range);

    // Add Frame Callback
    this.displaySync.on('frame', () => {
      if (this.frame === 1) {
        hiTraceMeter.startTrace('firstFrame', 1);
        this.productDetailSource.getProductData(0, 2);
        this.frame += 1;
        hiTraceMeter.finishTrace('firstFrame', 1);
      } else if (this.frame === 2) {
        hiTraceMeter.startTrace('secondFrame', 2);
        this.productDetailSource.getProductData(2, 10);
        hiTraceMeter.finishTrace('secondFrame', 2);
        this.frame += 1;
        this.displaySync?.stop();
      }
    });

    // Enable frame callback listening
    this.displaySync.start();
  }

  aboutToDisappear(): void {
    this.displaySync?.stop();
  }

  build() {
    Column() {
      Search({ placeholder: $r('app.string.search_title') })
      this.typeSwiper();
      this.typeList();
      this.typeWaterFlow();
    }
    .padding({
      left: 16,
      right: 16
    })
  }
  // [End Case1]

  @Builder
  typeSwiper(): void {
    Row() {
      Swiper() {
        LazyForEach(this.swiperDataSource, (item: ProductIntroductionModel) => {
          SwiperItem({
            icon: item.icon,
            title: item.title
          })
        }, (item: ProductIntroductionModel) => item.id)
      }
      .itemSpace(3)
      .displayCount(5)
      .cachedCount(this.SWIPER_CACHE)
      .autoPlay(true)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .margin({ top: 16 })
    .width(CommonConstants.FULL_PERCENT)
    .height(106)
    .borderRadius(16)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#190A59F7', 0.0], ['#00FFFFFF', 0.3], [Color.White, 0.7]]
    })
  }

  @Builder
  typeList(): void {
    Row() {
      List({ space: this.LIST_SPACE }) {
        LazyForEach(this.midListDataSource, (item: ProductIntroductionModel, index: number) => {
          ListItem() {
            this.midListItem(item, index);
          }
        }, (item: ProductIntroductionModel) => item.id)
      }
      .listDirection(Axis.Horizontal)
      .cachedCount(this.HORIZONTAL_LIST_CACHE)
      .scrollBar(BarState.Off)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(56)
    .margin({ top: 12 })
  }

  @Builder
  midListItem(item: ProductIntroductionModel, index: number): void {
    Row() {
      SymbolGlyph(item.icon)
        .fontSize(16)
        .fontColor(this.currentIndex === index ? [Color.White] : [Color.Black])
        .margin({ left: 16 })
      Text(item.title)
        .fontSize(14)
        .fontWeight(500)
        .lineHeight(19)
        .margin({ left: 8 })
        .fontColor(this.currentIndex === index ? Color.White : Color.Black)
    }
    .width(84)
    .height(36)
    .borderRadius(21)
    .backgroundColor(this.currentIndex === index ? $r('sys.color.comp_background_emphasize') :
    $r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      this.currentIndex = index;
    })
  }

  @Builder
  typeWaterFlow(): void {
    WaterFlow() {
      LazyForEach(this.productDetailSource, (item: ProductDetailModel, index: number) => {
        FlowItem() {
          BotFlowItem({ item: item })
        }
        .onAppear(() => {
          if (index + 4 === this.productDetailSource.totalCount()) {
            this.productDetailSource.getProductData();
          }
        })
      }, (item: ProductDetailModel) => item.id)
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(CommonConstants.COLUMNS_GAP)
    .rowsGap(CommonConstants.ROWS_GAP)
    .cachedCount(2)
    .margin({ top: 8 })
    .layoutWeight(1)
  }
}

@Builder
function transitionSceneBuilder(name: string): void {
  if (name === CommonConstants.NAV_DESTINATION_ITEM_0) {
    NavDestination() {
      TransitionScene();
    }
    .title(title())
    .backgroundColor('#F1F3F5')
  }
}

@Builder
function title(): void {
  Row() {
    Text($r('app.string.transition'))
      .fontSize(20)
      .fontWeight(700)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .lineHeight(27)
      .width(152)

    Row() {
      Stack() {
        Circle()
          .fill($r('sys.color.comp_background_tertiary'))
          .width(40)
          .aspectRatio(1)
        SymbolGlyph($r('sys.symbol.line_viewfinder'))
          .fontSize(20)
      }
      .margin({ right: 8 })

      Stack() {
        Circle()
          .fill($r('sys.color.comp_background_tertiary'))
          .width(40)
          .aspectRatio(1)
        SymbolGlyph($r('sys.symbol.person_fill'))
          .fontSize(20)
      }
    }
    .margin({ right: 8 })
    .width(136)
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.End)
  }
  .width(CommonConstants.FULL_PERCENT)
  .height(CommonConstants.FULL_PERCENT)
  .padding({ left: 8 })
}

@Reusable
@Component
export struct BotFlowItem {
  @State item: ProductDetailModel = new ProductDetailModel('', '', $r('app.media.product01'), '', '');

  aboutToReuse(params: Record<string, Object>): void {
    this.item = params.item as ProductDetailModel;
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.new_product'))
          .fontSize(10)
          .fontWeight(500)
          .lineHeight(13)
          .fontColor(Color.White)
      }
      .width(28)
      .height(16)
      .borderRadius(4)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#CF0A2C')

      Text(this.item.title)
        .fontSize(12)
        .fontWeight(500)
        .lineHeight(18)
        .margin({ top: 2 })

      Text(this.item.des)
        .fontSize(10)
        .fontWeight(400)
        .lineHeight(18)
        .margin({ top: 2 })

      Text(this.item.price)
        .fontSize(12)
        .fontWeight(700)
        .lineHeight(18)
        .margin({ top: 6 })

      Image(this.item.icon)
        .width(117)
        .height(117)
        .alignSelf(ItemAlign.Center)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: 12,
      top: 10
    })
    .width(CommonConstants.FULL_PERCENT)
    .height(236)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}

@Reusable
@Component
export struct SwiperItem {
  @State icon: Resource = $r('app.media.product01');
  @State title: ResourceStr = '';

  aboutToReuse(params: Record<string, Object>): void {
    this.icon = params.icon as Resource;
    this.title = params.title as ResourceStr;
  }

  build() {
    Column() {
      Stack() {
        Circle()
          .fill('#0A59F7')
          .width(37)
          .height(37)
        SymbolGlyph(this.icon)
          .fontSize(24)
          .fontColor([Color.White])
      }

      Text(this.title)
        .fontSize(12)
        .fontWeight(40)
        .lineHeight(16)
        .margin({ top: 5.33 })
    }
    .padding({ top: 14 })
    .width(66)
    .height(66)
  }
}

export const wrappedBuilderTransitionScene: WrappedBuilder<[string]> =
  wrapBuilder(transitionSceneBuilder);