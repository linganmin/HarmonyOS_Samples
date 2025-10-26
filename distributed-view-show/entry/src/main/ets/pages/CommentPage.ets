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

import { mediaquery } from '@kit.ArkUI';
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { common, Want } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { CommentDataModel, LiveInfoDataModel } from '../model/LiveDataModel'
import { LiveData } from '../model/LiveData';
import Constants from '../common/Constants';
import Logger from '../utils/Logger';

function getRemoteDeviceId(targetDevice: string): string | undefined {
  let dmClass = distributedDeviceManager.createDeviceManager('com.example.codelab');
  if (typeof dmClass === 'object' && dmClass !== null) {
    try {
      let list = dmClass.getAvailableDeviceListSync();
      if (typeof (list) === 'undefined' || typeof (list.length) === 'undefined') {
        Logger.error('getRemoteDeviceId err: list is null');
        return;
      }
      if (list.length === 0) {
        Logger.error('getRemoteDeviceId err: list is null');
        return;
      }
      for (const device of list) {
        if (targetDevice !== '' && device.networkId === targetDevice) {
          Logger.info(device.networkId as string);
          return device.networkId;
        }
      }
      return list[0].networkId;
    } catch (error) {
      Logger.error('getRemoteDeviceId err: list is null. Cause: ' + JSON.stringify(error));
      return;
    }

  } else {
    Logger.error('getRemoteDeviceId err: dmClass is null');
    return;
  }
}

@Component
export struct CommentPage {
  @State comments: Array<LiveInfoDataModel> = LiveData;
  @State text: string = '';
  @State isPhone: boolean = false;
  @State @Watch("onLiveListUpdated") liveList: Array<CommentDataModel> = [];
  @Link @Watch("onActiveUpdated") activeItem: number;
  @StorageProp('targetDevice') targetDevice: string = '';
  scroller: Scroller = new Scroller();
  listenerIsPhone = this.getUIContext().getMediaQuery().matchMediaSync('(orientation:landscape)');
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    this.isPhone = !mediaQueryResult.matches;
  }

  onActiveUpdated(): void {
    this.updateCommentList();
  }

  onLiveListUpdated(): void {
    let i = 0
    let intervalID = setInterval(() => {
      i++
      this.scroller.scrollPage({ next: true })
      if (i === this.liveList?.length) {
        clearInterval(intervalID);
      }
    }, 100);
  }

  updateCommentList() {
    let i = 0
    let intervalID = setInterval(() => {
      this.liveList.push(this.comments[0].commentList![i++])
      if (i === this.comments[0].commentList?.length) {
        clearInterval(intervalID);
      }
    }, 1000);
  }

  aboutToAppear() {
    // Bind the current JS instance
    this.listenerIsPhone.on('change', (result: mediaquery.MediaQueryResult) => {
      this.onPortrait(result)
    });
    Logger.info(deviceInfo.deviceType);
    this.updateCommentList();
  }

  build() {
    Column() {
      Column() {
        List({ space: Constants.SPACE_SIX, initialIndex: 0, scroller: this.scroller }) {
          ForEach(this.liveList, (item: CommentDataModel) => {
            ListItem() {
              Text() {
                Span(item.name)
                  .fontSize($r('app.integer.comm_font_size12'))
                  .fontColor($r('app.color.start_window_background'))
                Span(':')
                  .fontSize($r('app.integer.comm_font_size12'))
                  .fontColor($r('app.color.start_window_background'))
                Span(item.comment)
                  .fontSize($r('app.integer.comm_font_size12'))
                  .fontColor($r('app.color.start_window_background'))
              }
              .padding({
                left: $r('app.integer.normal_component_list_padding1'),
                top: $r('app.integer.normal_component_list_padding'),
                right: $r('app.integer.normal_component_list_padding1'),
                bottom: $r('app.integer.normal_component_list_padding')
              })
              .borderRadius($r('app.integer.normal_component_border_radius1'))
              .backgroundColor($r('app.color.normal_background_color'))
            }
          }, (item: CommentDataModel) => JSON.stringify(item))
        }
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
      }
      .alignItems(HorizontalAlign.Start)
      .width(Constants.SIXTY_PERCENT)
      .height($r('app.integer.comm_height2'))
      .margin({ bottom: $r('app.integer.normal_component_list_margin_2') })

      Row() {
        TextInput({ placeholder: $r('app.string.talk_something'), text: this.text })// TextInput输入框
          .backgroundColor($r('app.color.normal_background_color'))
          .placeholderColor($r('app.color.placeholderColor_background'))
          .padding({ left: $r('app.integer.normal_component_list_padding3') })
          .fontSize($r('app.integer.comm_font_size20'))
          .fontColor($r('app.color.start_window_background'))
          .width(deviceInfo.deviceType !== 'phone' ? Constants.EIGHTY_PERCENT : Constants.FULL_PERCENT)
          .height($r('app.integer.comm_btn_height3'))
          .borderRadius($r('app.integer.normal_component_border_radius3'))
          .onChange((value: string) => {
            this.text = value;
          })
          .onSubmit(() => {
            this.liveList.push({ name: $r("app.string.first_five_name"), comment: this.text });
            this.text = '';
          })

        Blank()

        Button($r('app.string.iPhone_input'), { type: ButtonType.Normal, stateEffect: true })
          .borderRadius($r('app.integer.normal_component_border_radius3'))
          .backgroundColor($r('app.color.normal_blue_color'))
          .width($r('app.integer.comm_btn_width1'))
          .height($r('app.integer.comm_btn_height4'))
          .visibility(deviceInfo.deviceType !== 'phone' ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            let want: Want = {
              deviceId: getRemoteDeviceId(this.targetDevice),
              bundleName: 'com.example.codelab',
              abilityName: 'InputAbility',
            };
            const RESULT_CODE: number = Constants.REQUEST_CODE;
            this.context.startAbilityForResult(want).then((data) => {
              if (data?.resultCode === RESULT_CODE) {
                let comment = data.want?.parameters?.comment;
                if (comment !== null) {
                  this.liveList.push({ name: $r("app.string.first_five_name"), comment: comment!.toString() });
                }
              }
            }).catch((error: Error) => {
              Logger.error(JSON.stringify(error));
            });
          })
      }
      .width(Constants.FULL_PERCENT)
      .padding({
        top: $r('app.integer.normal_component_list_padding2'),
        bottom: $r('app.integer.normal_component_list_padding2')
      })
      .justifyContent(FlexAlign.Start)
      .margin({ top: $r('app.integer.normal_component_list_margin_1') })
    }
    .alignItems(HorizontalAlign.Start)
    .width(Constants.FULL_PERCENT)
    .height($r('app.integer.comm_height1'))
  }
}