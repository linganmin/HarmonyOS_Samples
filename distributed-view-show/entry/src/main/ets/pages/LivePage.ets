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

import { router, mediaquery } from '@kit.ArkUI';
import { LiveInfoDataModel } from '../model/LiveDataModel';
import { LiveData } from '../model/LiveData';
import { CommentPage } from './CommentPage';
import Constants from '../common/Constants';
import Logger from '../utils/Logger';

class LiveInfoResponse {
  code?: number;
  data?: Array<Info>;
}

class Info {
  uri?: string;
  name?: string;
  peopleNum?: string;
  commentList?: Array<commentInfo>;
}

class commentInfo {
  name: string = '';
  comment: string = '';
}

@Entry
@Component
struct LivePage {
  @StorageLink('activeLive') activeLive: number = 0;
  @State active: number = this.activeLive;
  @State liveInfoList: Array<LiveInfoDataModel> = LiveData;
  @State liveList: LiveInfoDataModel[] = [];
  @State mData: LiveInfoResponse = {
    code: 0,
    data: [{
      uri: '',
      name: '',
      peopleNum: '',
      commentList: [{ name: '', comment: '' }]
    }]
  };
  @State isPhone: boolean = false;
  videoController: VideoController = new VideoController();
  listenerIsPhone = this.getUIContext().getMediaQuery().matchMediaSync('(orientation:landscape)');

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    this.isPhone = !mediaQueryResult.matches;
  }

  async aboutToAppear() {
    this.listenerIsPhone.on('change', (result: mediaquery.MediaQueryResult) => {
      this.onPortrait(result)
    });
    Logger.info(this.activeLive.toString(), this.active.toString());
  }

  onPageShow(): void {
    this.videoController.start();
  }

  build() {
    Swiper() {
      ForEach(this.liveInfoList, (item: LiveInfoDataModel, index) => {
        Stack() {
          if (this.active === index) {
            Video({ src: item.uri, controller: this.videoController })
              .autoPlay(true)
              .loop(true)
              .controls(false)
              .objectFit(ImageFit.Cover)
              .width(Constants.FULL_PERCENT)
              .height(Constants.FULL_PERCENT)
          }

          Row() {
            Column() {
              Image($r('app.media.back_button'))
                .width($r('app.integer.comm_btn_width2'))
                .height($r('app.integer.comm_btn_width2'))
                .onClick(() => {
                  this.getUIContext().getRouter().back();
                })
            }
            .margin({
              left: $r('app.integer.normal_component_list_margin_3'),
              right: $r('app.integer.normal_component_list_margin_4')
            })

            Row() {
              Row() {
                Image($r('app.media.live_author'))
                  .width($r('app.integer.comm_btn_width3'))
                  .height($r('app.integer.comm_btn_width3'))

                Column() {
                  Text(item.name)
                    .fontSize($r('app.integer.comm_font_size12'))
                    .lineHeight($r('app.integer.normal_text_line_height'))
                    .fontFamily(Constants.HARMONY_HEI_TI_FONT_FAMILY)
                    .fontWeight(Constants.FONT_WEIGHT_LG)
                    .fontColor($r('app.color.start_window_background'))
                    .textOverflow({ overflow: TextOverflow.MARQUEE })
                    .width($r('app.integer.comm_btn_width4'))
                  Row() {
                    Text(item.peopleNum)
                      .id(String(item.peopleNum))
                      .fontSize($r('app.integer.comm_font_size10'))
                      .lineHeight($r('app.integer.normal_text_line_height_1'))
                      .fontFamily(Constants.HARMONY_HEI_TI_FONT_FAMILY)
                      .fontWeight(Constants.FONT_WEIGHT_SM)
                      .fontColor($r('app.color.start_window_background'))
                    Text($r('app.string.watch'))
                      .fontSize($r('app.integer.comm_font_size10'))
                      .lineHeight($r('app.integer.normal_text_line_height_1'))
                      .fontFamily(Constants.HARMONY_HEI_TI_FONT_FAMILY)
                      .fontWeight(Constants.FONT_WEIGHT_SM)
                      .fontColor($r('app.color.start_window_background'))
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ left: $r('app.integer.normal_component_list_padding5') })
              }
              .width($r('app.integer.comm_btn_width1'))

              Blank()
              Row() {
                Button($r('app.string.follow'))
                  .padding({
                    left: 0,
                    right: 0
                  })
                  .fontSize(12)
                  .height($r('app.integer.comm_btn_height5'))
                  .width($r('app.integer.comm_btn_width5'))
              }
            }
            .padding({
              left: $r('app.integer.normal_component_list_padding5'),
              right: $r('app.integer.normal_component_list_padding5')
            })
            .width(this.isPhone ? $r('app.integer.comm_width') : Constants.THIRTY_PERCENT)
            .height($r('app.integer.comm_btn_width2'))
            .backgroundColor($r('app.color.normal_background_color'))
            .borderRadius(this.isPhone ? $r('app.integer.normal_component_border_radius4') :
            $r('app.integer.normal_component_border_radius5'))

            Blank()

            Column() {
              Image($r('app.media.share_button'))
                .width($r('app.integer.comm_btn_width2'))
                .height($r('app.integer.comm_btn_width2'))
            }
            .margin({ right: $r('app.integer.normal_component_list_margin_1') })

            Column() {
              Image($r('app.media.close_button'))
                .id('close')
                .width($r('app.integer.comm_btn_width2'))
                .height($r('app.integer.comm_btn_width2'))
                .onClick(() => {
                  this.getUIContext().getRouter().back();
                })
            }
            .margin({ right: $r('app.integer.normal_component_list_margin_3') })
          }
          .width(Constants.FULL_PERCENT)
          .padding({
            top: $r('app.integer.normal_component_list_padding2'),
            bottom: $r('app.integer.normal_component_list_padding2')
          })
          .position({ y: Constants.POSITION_Y_EXTEND })

          Column() {
            if (this.active === index) {
              CommentPage({ activeItem: $active });
            }
          }
          .padding({
            left: $r('app.integer.normal_component_list_padding4'),
            right: $r('app.integer.normal_component_list_padding4')
          })
          .position({ y: this.isPhone ? Constants.POSITION_Y : Constants.HALF_PERCENT })
        }
        .backgroundColor($r('app.color.normal_background_color_1'))
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
      }, (item: ResourceStr) => JSON.stringify(item))
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .loop(false)
    .indicator(false)
    .vertical(true)
    .index(this.active)
    .onChange((index: number) => {
      this.active = index;
      this.activeLive = index;
    })
  }
}