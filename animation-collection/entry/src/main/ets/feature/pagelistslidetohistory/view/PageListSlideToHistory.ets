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

import { util } from '@kit.ArkTS';
import { BasicDataSource, FriendMoment } from '../model/BasicDataSource';
import { OneMoment } from './OneMoment';
import { Constants } from '../common/Constants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const context = AppStorage.get("context") as UIContext;

@Component
export struct PageListSlideToHistory {
  @State cachedCountNumber: number = 3;
  @State firstIndex: number = 0;
  listScroller: ListScroller = new ListScroller();
  historyOffset: number = 0;
  isHistoricalRecord: boolean = false;
  isJump: boolean = true;
  readonly DEFAULT_OFFSET: number = 1000;
  readonly ANIMATION_DURATION: number = 500;
  readonly SWITCH_BUTTON: number = 3;

  aboutToAppear(): void {
    getFriendMomentFromRawfile();
    getFriendMomentFromRawfile();
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Text($r('app.string.near_message'))
            .fontSize($r('app.integer.list_history_title_fontSize'))
            .fontColor($r('app.color.title_font_color'))
            .fontWeight(FontWeight.Bold)
            .margin({ left: $r('app.integer.list_history_title_margin_left') })
            .lineHeight($r('app.integer.list_history_title_line_height'))
            .layoutWeight(Constants.LAYOUT_WEIGHT)
        }
        .alignItems(VerticalAlign.Center)
        .height($r('app.integer.list_history_title_height'))
        .width(Constants.LAYOUT_MAX)
        .padding({
          left: $r('app.integer.list_history_title_padding_left'),
          right: $r('app.integer.list_history_title_padding_right'),
          top: $r('app.integer.list_history_title_padding_top'),
          bottom: $r('app.integer.list_history_title_padding_bottom')
        })

        List({ space: Constants.LIST_SPACE, scroller: this.listScroller }) {
          LazyForEach(momentData, (moment: FriendMoment, index: number) => {
            ListItem() {
              Column() {
                if (index === Constants.COMM_INIT && this.isHistoricalRecord && this.isJump) {
                  Text($r('app.string.jump_to_history'))
                    .fontColor($r("app.color.ohos_id_color_emphasize"))
                    .fontSize($r('app.integer.jump_font_size'))
                    .margin({ top: $r('app.integer.jump_margin'), bottom: $r('app.integer.jump_margin') })
                    .onClick(() => {
                      if (this.firstIndex < this.SWITCH_BUTTON) {
                        this.listScroller.scrollTo({
                          xOffset: 0,
                          yOffset: this.historyOffset === Constants.COMM_INIT ? this.DEFAULT_OFFSET :
                          this.historyOffset,
                          animation: { duration: this.ANIMATION_DURATION, curve: Curve.LinearOutSlowIn }
                        });
                        this.isHistoricalRecord = false;
                        this.isJump = true;
                      }
                    })
                }
                OneMoment({ moment: moment })
              }
            }
          }, (moment: FriendMoment) => moment.id)
        }
        .cachedCount(this.cachedCountNumber)
        .width(Constants.LAYOUT_MAX)
        .height(Constants.LAYOUT_MAX)
        .listDirection(Axis.Vertical)
        .divider({
          strokeWidth: $r('app.integer.friends_page_divider_width'),
          color: $r('app.color.friends_page_divider_color'),
          startMargin: $r('app.integer.list_history_list_divider_margin'),
          endMargin: $r('app.integer.list_history_list_divider_margin')
        })
        .onScrollIndex((first: number) => {
          this.firstIndex = first;
        })
      }
      .height(Constants.LAYOUT_MAX)
      .width(Constants.LAYOUT_MAX)

      Row() {
        Image($r('app.media.ic_public_backtotop'))
          .width($r('app.integer.back_top_img_size'))
          .height($r('app.integer.back_top_img_size'))
          .opacity($r('app.float.jump_button_opacity'))
      }
      .onClick(() => {
        if (this.firstIndex >= this.SWITCH_BUTTON) {
          this.historyOffset = this.listScroller.currentOffset().yOffset;
          this.listScroller.scrollTo({
            xOffset: Constants.COMM_INIT,
            yOffset: Constants.COMM_INIT,
            animation: { duration: this.ANIMATION_DURATION, curve: Curve.LinearOutSlowIn }
          });
          this.isHistoricalRecord = true;
        }
      })
      .visibility(this.firstIndex >= this.SWITCH_BUTTON ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.Center)
      .width($r('app.integer.back_top_img_background_size'))
      .height($r('app.integer.back_top_img_background_size'))
      .backgroundColor($r("app.color.ohos_id_color_emphasize"))
      .borderRadius($r('app.integer.back_top_bag_radius'))
      .margin({ right: $r('app.integer.back_top_margin') })
    }
  }
}

class FriendMomentsData extends BasicDataSource<FriendMoment> {
  momentList: Array<FriendMoment> = [];

  public totalCount(): number {
    return this.momentList.length;
  }

  public getData(index: number): FriendMoment {
    if (index === this.momentList.length - 1) {
      getFriendMomentFromRawfile();
    }
    return this.momentList[index];
  }

  public addData(index: number, data: FriendMoment): void {
    this.momentList.splice(index, Constants.COMM_INIT, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: FriendMoment): void {
    this.momentList.push(data);
    this.notifyDataAdd(this.momentList.length - 1);
  }
}

const momentData: FriendMomentsData = new FriendMomentsData();

async function getFriendMomentFromRawfile(): Promise<void> {
  try {
    const resourceManager = context.getHostContext()!.resourceManager;
    const res = await resourceManager.getRawFileContent('mockFriendMomentOneModelData.json');

    interface MyJsonModel {
      friendMoments: FriendMoment[];
    }

    const textDecoder = util.TextDecoder.create();
    const friendMomentArray = (JSON.parse(textDecoder.decodeToString(res)) as MyJsonModel).friendMoments;

    friendMomentArray.forEach(item => {
      item.id = Math.floor(momentData.totalCount() / 10) + item.id;
      item.text = resourceManager.getStringSync($r('app.string.jump_text_one').id, parseInt(item.id) + 1) + item.text;
      momentData.pushData(item);
    });
  } catch (err) {
    let error = err as BusinessError;
    hilog.error(0x0000, 'PageListSlideToHistory',
      `getFriendMomentFromRawfile failed. error code=${error.code}, message=${error.message}`);
  }
}

@Builder
export function getPageListSlideToHistory(name: string): void {
  if (name === 'PageListSlideToHistory') {
    NavDestination() {
      PageListSlideToHistory()
    }
  }
}

export const wrappedBuilderPageListSlideToHistory: WrappedBuilder<[string, number]> =
  wrapBuilder(getPageListSlideToHistory);

