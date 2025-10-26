/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

import { mediaquery } from '@kit.ArkUI';
import { Callback } from '@kit.BasicServicesKit';
import { LiveInfoDataModel } from '../model/LiveDataModel';
import { LiveData } from '../mock/LiveData';
import { Live } from '../net/Utils';
import { CommentPage } from './CommentPage';
import { hilog } from '@kit.PerformanceAnalysisKit';

class LiveInfoResponse {
  code: number = 0;
  data: Array<Info> = [];
}

class Info {
  uri: string = '';
  name: string = '';
  peopleNum: string = '';
}

@Component
export struct LivePage {
  @State active: number = 0;
  @State liveInfoList: Array<LiveInfoDataModel> = [];
  @State mData: LiveInfoResponse = {
    code: 0,
    data: [{ uri: '', name: '', peopleNum: '' }]
  };
  @State isPhone: boolean = false;
  portraitFunc: Callback<mediaquery.MediaQueryResult> = (mediaQueryResult: mediaquery.MediaQueryResult): void => {
    this.onPortrait(mediaQueryResult);
  };
  listenerIsPhone = this.getUIContext().getMediaQuery().matchMediaSync('(orientation:landscape)');

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    this.isPhone = !mediaQueryResult.matches;
  }

  async aboutToAppear() {
    LiveData.forEach((item) => {
      this.liveInfoList.push(new LiveInfoDataModel(item));
    })
    this.listenerIsPhone.on('change', this.portraitFunc);

    try {
      let a = await Live();
      if (!a) {
        return;
      }
      this.mData = JSON.parse(a.result.toString());
      this.liveInfoList = this.mData.data;
    } catch (err) {
      hilog.error(0x0000, 'LivePage', `Http resquest is fail. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    Scroll() {
      Column() {
        Swiper() {
          ForEach(this.liveInfoList, (item: LiveInfoDataModel, index) => {
            Stack() {
              if (this.active === index) {
                Video({ src: item.uri })
                  .autoPlay(true)
                  .loop(false)
                  .controls(false)
                  .objectFit(ImageFit.Contain)
                  .width('100%')
                  .height('100%')
              }

              Row() {
                Row() {
                  Row() {
                    Image($r('app.media.live_author'))
                      .width(38)
                      .height(38)

                    Column() {
                      Text(item.name)
                        .fontSize(16)
                        .fontColor('#ffffff')
                      Row() {
                        Text(item.peopleNum)
                          .id(item.peopleNum as string)
                          .fontSize(12)
                          .fontColor('#ffffff')
                        Text($r('app.string.watch'))
                          .fontSize(12)
                          .fontColor('#ffffff')
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .padding({ left: '2%' })
                  }

                  Button($r('app.string.follow'))
                    .backgroundColor(Color.Red)
                    .height(35)
                    .width(70)
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({
                  left: this.isPhone ? '2%' : '1%',
                  right: this.isPhone ? '2%' : '1%'
                })
                .width(this.isPhone ? '57.2%' : '30%')
                .aspectRatio(this.isPhone ? 5.15 : 7)
                .backgroundColor('rgba(0,0,0,0.40)')
                .borderRadius(this.isPhone ? 26 : 36)

                Column() {
                  Image($r('app.media.live_share'))
                    .width(42)
                    .height(42)
                }
                .margin({
                  left: this.isPhone ? '12%' : '49%'
                })

                Column() {
                  Image($r('app.media.live_close'))
                    .id('close')
                    .width(42)
                    .height(42)
                    .onClick(() => {
                      this.getUIContext().getRouter().back();
                    })
                }
                .margin({
                  left: '4%'
                })
              }
              .position({
                x: '2%',
                y: '5.1%'
              })

              Column() {
                CommentPage()
              }
              .position({
                x: '2%',
                y: this.isPhone ? '72%' : '62%'
              })
            }
            .backgroundColor('#D8D8D8')
            .width('100%')
            .height('100%')
          }, (item: LiveInfoDataModel) => JSON.stringify(item))
        }
        .width('100%')
        .height('100%')
        .loop(false)
        .indicator(false)
        .vertical(true)
        .onChange((index: number) => {
          this.active = index;
        })
      }
    }
  }
}
