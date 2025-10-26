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

import { OTHER_TITLE, StockInForm } from '../models/DataModel';
import { BreakpointType } from '../utils/BreakpointType';

@Component
export struct WordBackgroundComm {
  public text: ResourceStr = '';
  public textFontColor: ResourceColor = '';
  public textBackgroundColor: ResourceColor = '';

  build() {
    Row() {
      Text(this.text)
        .fontSize(10)
        .fontColor(this.textFontColor)
    }
    .width(12)
    .height(12)
    .borderRadius(2)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.textBackgroundColor)
    .margin({
      right: 4
    })
  }
}

@Component
export struct UniversalIcon {
  public icon?: Resource;
  public iconBackgroundColor: ResourceColor = '';
  public fontSize?: ResourceColor = $r('sys.float.Title_L');

  build() {
    Button({ type: ButtonType.Circle }) {
      SymbolGlyph(this.icon)
        .fontColor([$r('sys.color.icon_primary')])
        .fontSize(this.fontSize)
    }
    .height(46)
    .aspectRatio(1)
    .backgroundColor(this.iconBackgroundColor)
  }
}

@Component
export struct UniversalImage {
  public icon?: Resource;
  public iconBackgroundColor: ResourceColor = '';

  build() {
    Button({ type: ButtonType.Circle }) {
      Image(this.icon)
        .width($r('sys.float.Title_M'))
        .height($r('sys.float.Title_M'))
    }
    .height(40)
    .aspectRatio(1)
    .backgroundColor(this.iconBackgroundColor)
  }
}

@Component
export struct StockDetails {
  public title: ResourceStr = '';
  public price: string = '';
  public amount: number = 0;
  public index: number = 0;
  public isShowNumber: boolean = true;

  build() {
    Row() {
      Text(this.title) {
        Span(this.title)
        if (this.isShowNumber) {
          Span(this.index.toString())
        }
      }
      .textType()
      .fontColor('#666666')

      Text(this.price)
        .textType()
        .fontColor(this.index % 2 === 0 ? '#FA4337' : '#1DB775')
      Text(this.amount.toString())
        .textType()
        .fontColor('#666666')
        .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Component
export struct TitleIcon {
  public icon?: Resource;
  public title?: Resource;

  build() {
    Column() {
      SymbolGlyph(this.icon)
        .fontColor([$r('sys.color.icon_primary')])
        .fontSize(24)
      Text(this.title)
        .fontSize(10)
        .lineHeight(13)
        .fontColor('#999999')
        .margin({
          top: 4
        })
    }
    .width(40)
    .height(42)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct TitleImage {
  public icon?: Resource;
  public title?: Resource;

  build() {
    Column() {
      Image(this.icon)
        .width(24)
        .height(24)
      Text(this.title)
        .fontSize(10)
        .lineHeight(13)
        .fontColor('#999999')
        .margin({
          top: 4
        })
    }
    .width(40)
    .height(42)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct StockInFormList {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = 1;
  public item?: StockInForm;
  public index: number = 0;
  @Consume('isExpand') isExpand: boolean;

  build() {
    Row() {
      Column({ space: 3 }) {
        Row() {
          Text(this.item?.title1).textStocksTitle()
          Text(this.item?.value1).fontColor(this.item?.color1).textStocksValue()
        }
        .textStocksTitleValue()

        Row() {
          Text(this.item?.title2).textStocksTitle()
          Text(this.item?.value2).fontColor(this.item?.color2).textStocksValue()
        }
        .textStocksTitleValue()

        Row() {
          Text(this.item?.title3).textStocksTitle()
          Text(this.item?.value3).fontColor(this.item?.color3).textStocksValue()
        }
        .textStocksTitleValue()
      }
      .padding({
        right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
        left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
      })

      Divider()
        .vertical(true)
        .height('85%')
        .color('#979797')
        .visibility(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM ?
          ((this.index + 1) % 2 === 0 ? Visibility.Hidden : Visibility.Visible) :
          this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_MD ?
            ((this.index + 1) % 3 === 0 || this.index === 3 ? Visibility.Hidden : Visibility.Visible) :
            ((this.index + 1) % 4 === 0 ? Visibility.Hidden : Visibility.Visible))
    }
    .width('100%')
    .height(51)
    .margin({
      bottom: 6
    })
    .visibility(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM ?
      ((this.index + 1) > 2 ? (!this.isExpand ? Visibility.None : Visibility.Visible) : Visibility.Visible) :
      this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_MD ?
        ((this.index + 1) > 3 ? (!this.isExpand ? Visibility.None : Visibility.Visible) : Visibility.Visible) :
        ((this.index + 1) > 4 ? (!this.isExpand ? Visibility.None : Visibility.Visible) : Visibility.Visible))
  }
}

@Component
export struct CommSlide {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = 1;
  @Prop tabIndexSelected: number = 0;
  public commSlideData: ResourceStr[] = OTHER_TITLE;

  build() {
    // [Start tab_sliding_area]
    List({
      space: new BreakpointType(46, 90, 150).getValue(this.currentWidthBreakpoint)
    }) {
      ForEach(this.commSlideData, (item: string, index: number) => {
        ListItem() {
          Column() {
            Text(item)
            // [StartExclude tab_sliding_area]
              .fontSize(16)
              .fontWeight(this.tabIndexSelected === index ? 700 : 400)
              .fontColor(this.tabIndexSelected === index ? '#000000' : '#999999')
              .height(21)
              .focusable(true)
              .groupDefaultFocus(index === 0 ? true : false)
            // [EndExclude tab_sliding_area]
          }
        }
        .margin({
          top: 9,
          right: this.commSlideData.length === index + 1 ?
            new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint) : 0,
          left: index === 0 ? new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint) : 0,
        })
        .border({
          width: {
            bottom: this.tabIndexSelected === index ? 2 : 0
          },
          color: {
            bottom: this.tabIndexSelected === index ? '#FA4337' : ''
          },
          style: {
            bottom: BorderStyle.Solid
          }
        })
        .onClick(() => {
          this.tabIndexSelected = index;
        })
      }, (item: string, index: number) => (index + item).toString())
    }
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    // [End tab_sliding_area]
  }
}

@Extend(Text)
function textType() {
  .fontWeight(FontWeight.Regular)
  .fontSize(10)
  .lineHeight(14)
}

@Extend(Text)
function textStocksTitle() {
  .fontSize(11)
  .fontColor('#999999')
}

@Extend(Text)
function textStocksValue() {
  .fontSize(11)
  .fontWeight(FontWeight.Medium)
}

@Extend(Row)
function textStocksTitleValue() {
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween)
}