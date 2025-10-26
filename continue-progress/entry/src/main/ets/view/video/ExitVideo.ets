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

import { common, Want } from '@kit.AbilityKit';
import { connection } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';
import avPlayManage from '../../viewmodel/video/AvPlayManager';
import { GlobalContext } from '../../utils/GlobalContext';

@Component
export struct ExitVideo {
  @StorageLink('pageInfos') pageInfo: NavPathStack = new NavPathStack();
  @StorageLink('videoName') videoName: Resource = $r('app.string.video_res_1');
  @StorageLink('show') show: boolean = false;
  @StorageLink('videoSelect') videoSelect: number = 0;
  @Link avPlayManage: avPlayManage;
  private videoList: Resource[] = [$r('app.string.video_res_1'), $r('app.string.video_res_2')];

  async isInternet(): Promise<boolean> {
    if (connection.getAllNetsSync().length <= 0) {
      this.toast();
      return false;
    }
    return true;
  }

  async toast() {
    this.getUIContext().getPromptAction().showToast({
      message: $r('app.string.video_warn'),
      duration: 2000,
    });
  }

  @Builder
  listBuilder() {
    Column() {
      List() {
        ForEach(this.videoList, (item: Resource, index) => {
          ListItem() {
            Column() {
              Row() {
                Text(item)
                  .fontSize(16)
                  .fontWeight(500)
                  .textAlign(TextAlign.Center)

                Blank()

                if (this.videoSelect === index) {
                  Text($r('app.string.playing'))
                    .fontSize(14)
                    .opacity($r('app.float.size_zero_six'))
                    .fontWeight(400)
                    .textAlign(TextAlign.Center)
                    .fontColor('rgb(10, 89, 247)')
                } else {
                  Text($r('app.string.click_change'))
                    .fontSize(14)
                    .opacity($r('app.float.size_zero_six'))
                    .fontColor('rgba(0,0,0,0.6)')
                    .fontWeight(400)
                    .textAlign(TextAlign.Center)
                }
              }
              .width('90%')
            }
            .width('100%')
          }
          .borderRadius(16)
          .backgroundColor(Color.White)
          .width('100%')
          .height(58)
          .margin({
            bottom: 10
          })
          .onClick(async () => {
            if (index === 2) {
              try {
                if (!await this.isInternet()) {
                  return;
                }
              } catch (err) {
                this.toast();
                return;
              }
            }
            this.videoSelect = index;
            AppStorage.setOrCreate('videoName', this.videoList[this.videoSelect]);
            AppStorage.setOrCreate('videoIndex', this.videoSelect);
            AppStorage.setOrCreate('speedName', $r('app.string.video_speed_1_0X'));
            AppStorage.setOrCreate('speedIndex', 0);
            AppStorage.setOrCreate('currentTime', 0);
            this.show = false;
            let str: string = await (GlobalContext.getContext().getObject('context') as (common.UIAbilityContext))
              .resourceManager.getStringValue(this.videoList[this.videoSelect]);
            this.avPlayManage.videoChoose(str);
          })
        }, (index: number) => JSON.stringify(index))
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('200vp')
    }
    .padding({
      left: 16,
      right: 16,
      bottom: 28
    })
    .onClick(() => {
      this.show = false;
    })
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.SpaceBetween
    }) {
      // Exit
      Row() {
        Image($r("app.media.ic_back"))
          .id('Exit')
          .width(40)
          .height(40)
          .onClick(() => {
            this.pageInfo.pop();
          })

        Text($r('app.string.video_title'))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('app.float.size_24'))
          .margin({ left: 8 })
      }

      Image($r('app.media.list'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.show = true;
        })
        .bindSheet($$this.show, this.listBuilder, {
          height: SheetSize.FIT_CONTENT,
          backgroundColor: '#F1F3F5',
          title: { title: this.videoList[this.videoSelect] },
          detents: [SheetSize.FIT_CONTENT, SheetSize.FIT_CONTENT, 200],
        })
    }
    .margin({ top: $r('app.float.size_20'), left: 16, right: 16 })
  }
}