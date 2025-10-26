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

import Constants from '../common/Constants';
import { NavDestinationItem } from '../viewmodel/NavDestinationItem';
import { GlobalBuilderContext } from '../common/GlobalBuilderContext';

@Entry
@Component
struct Index {
  private NavDestinationData: NavDestinationItem[] = Constants.NAV_DESTINATION_DATA;
  private stringName: string = 'VerificationCode';
  private stringName1: string = 'SliderVerification';
  pageInfos: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string) {
    if ((GlobalBuilderContext.getContext().getObject(name)) !== undefined) {
      (GlobalBuilderContext.getContext().getObject(name) as WrappedBuilder<[string, number]>)
        .builder(name, Constants.ZERO);
    }
  }

  @Builder
  itemHead(text: Resource) {
    Text(text)
      .fontSize($r('app.float.font_size'))
      .fontWeight(FontWeight.Medium)
      .width(Constants.ONE_HUNDRED_PERCENT)
      .padding({ bottom: $r('app.float.padding_bottom') })
      .fontColor($r('sys.color.mask_secondary'))
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate('listData', this.NavDestinationData);
  }

  build() {
    Column() {
      Navigation(this.pageInfos) {
        List() {
          this.itemHead($r('app.string.verification_code'))
          ForEach(this.NavDestinationData, (item: NavDestinationItem, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  Column() {
                    Text(item.detail)
                      .fontSize($r('app.float.font_size'))
                      .fontWeight(FontWeight.Medium)
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()
                  Row()
                    .width($r('app.float.row_width'))
                    .height($r('app.float.row_width'))
                    .margin({ right: $r('app.float.row_margin') })
                    .border({
                      width: {
                        top: $r('app.float.border_width'),
                        right: $r('app.float.border_width')
                      },
                      color: $r('app.color.border_color')
                    })
                    .rotate({ angle: Constants.ANGLE })
                }
                .borderRadius({
                  topLeft: index === Constants.ZERO ? $r('app.float.padding') : $r('app.float.zero'),
                  topRight: index === Constants.ZERO ? $r('app.float.padding') : $r('app.float.zero'),
                  bottomLeft: index === Constants.TWO ? $r('app.float.padding') : $r('app.float.zero'),
                  bottomRight: index === Constants.TWO ? $r('app.float.padding') : $r('app.float.zero')
                })
                .width(Constants.ONE_HUNDRED_PERCENT)
                .height($r('app.float.list_item_height'))
                .alignItems(VerticalAlign.Center)
                .padding({
                  left: $r('app.float.padding'),
                  top: $r('app.float.padding'),
                  bottom: $r('app.float.padding')
                })
                .backgroundColor(Color.White)
                .onClick(() => {
                  this.pageInfos.pushPathByName(item.name, Constants.ZERO);
                })

                Row()
                  .height($r('app.float.row_height_one'))
                  .width(Constants.NINETY_PERCENT)
                  .backgroundColor($r('app.color.line_color'))
              }
              .width(Constants.ONE_HUNDRED_PERCENT)
              .backgroundColor(Color.White)
              .borderRadius({
                topLeft: index === Constants.ZERO ? $r('app.float.padding') : $r('app.float.zero'),
                topRight: index === Constants.ZERO ? $r('app.float.padding') : $r('app.float.zero'),
                bottomLeft: index === Constants.TWO ? $r('app.float.padding') : $r('app.float.zero'),
                bottomRight: index === Constants.TWO ? $r('app.float.padding') : $r('app.float.zero')
              })
            }
          }, (item: NavDestinationItem) => JSON.stringify(item))

          ListItem() {
            Row() {
              Column() {
                Text($r('app.string.select_verification_code'))
                  .fontSize($r('app.float.font_size'))
                  .fontWeight(FontWeight.Medium)
              }
              .alignItems(HorizontalAlign.Start)

              Blank()
              Row()
                .width($r('app.float.row_width'))
                .height($r('app.float.row_width'))
                .margin({ right: $r('app.float.row_margin') })
                .border({
                  width: {
                    top: $r('app.float.border_width'),
                    right: $r('app.float.border_width')
                  },
                  color: $r('app.color.border_color')
                })
                .rotate({ angle: Constants.ANGLE })
            }
            .borderRadius($r('app.float.padding'))
            .width(Constants.ONE_HUNDRED_PERCENT)
            .height($r('app.float.list_item_height'))
            .alignItems(VerticalAlign.Center)
            .padding({
              left: $r('app.float.padding'),
              top: $r('app.float.padding'),
              bottom: $r('app.float.padding')
            })
            .backgroundColor(Color.White)
            .onClick(() => {
              this.pageInfos.pushPathByName(this.stringName, Constants.ZERO);
            })
          }
          .margin({ top: $r('app.float.item_list') })

          ListItem() {
            Row() {
              Column() {
                Text($r('app.string.slider_verification_code'))
                  .fontSize($r('app.float.font_size'))
                  .fontWeight(FontWeight.Medium)
              }
              .alignItems(HorizontalAlign.Start)

              Blank()
              Row()
                .width($r('app.float.row_width'))
                .height($r('app.float.row_width'))
                .margin({ right: $r('app.float.row_margin') })
                .border({
                  width: { top: $r('app.float.border_width'), right: $r('app.float.border_width') },
                  color: $r('app.color.border_color')
                })
                .rotate({ angle: Constants.ANGLE })
            }
            .borderRadius($r('app.float.padding'))
            .width(Constants.ONE_HUNDRED_PERCENT)
            .height($r('app.float.list_item_height'))
            .alignItems(VerticalAlign.Center)
            .padding({
              left: $r('app.float.padding'),
              top: $r('app.float.padding'),
              bottom: $r('app.float.padding')
            })
            .backgroundColor(Color.White)
            .onClick(() => {
              this.pageInfos.pushPathByName(this.stringName1, Constants.ZERO);
            })
          }
          .margin({ top: $r('app.float.item_list') })
        }
        .height(Constants.ONE_HUNDRED_PERCENT)
        .width(Constants.ONE_HUNDRED_PERCENT)
        .padding({
          left: $r('app.float.change'),
          right: $r('app.float.change'),
          top: $r('app.float.list_padding_top')
        })
      }
      .mode(NavigationMode.Stack)
      .navDestination(this.PagesMap)
    }
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .height(Constants.ONE_HUNDRED_PERCENT)
    .width(Constants.ONE_HUNDRED_PERCENT)
    .backgroundColor($r('app.color.index_background'))
  }
}