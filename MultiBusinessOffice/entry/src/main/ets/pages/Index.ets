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

import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { common, StartOptions, Want } from '@kit.AbilityKit';
import { bundleManager } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../constants/CommonConstants';

class DirectoryItem {
  title: ResourceStr = '';
  uri: string | Resource = '';
  id: string = '';
}

@Entry
@Component
struct Index {
  @StorageLink('breakPoint') breakPoint: string = '';
  @StorageLink('deviceType') deviceType: string = '';
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  private title: string | Resource = CommonConstants.ENTRANCES[0];
  private bundleName: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private directory: DirectoryItem[] = [
    {
      title: CommonConstants.TITLE_LIST[0],
      uri: $r('app.media.notes'),
      id: 'NotesPage'
    },
    {
      title: CommonConstants.TITLE_LIST[1],
      uri: $r('app.media.calendar'),
      id: 'CalendarPage'
    }
  ];

  aboutToAppear(): void {
    let deviceTypeInfo: string = deviceInfo.deviceType;
    AppStorage.setOrCreate('deviceType', deviceTypeInfo);

    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    try {
      bundleManager.getBundleInfoForSelf(bundleFlags).then((data) => {
        this.bundleName = data.name;
        hilog.info(0x0000, 'testTag', 'getBundleInfoForSelf successfully. Data: %{public}s', JSON.stringify(data));
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', 'getBundleInfoForSelf failed. Cause: %{public}s', err.message);
      });
    } catch (err) {
      let message = (err as BusinessError).message;
      hilog.error(0x0000, 'testTag', 'getBundleInfoForSelf failed: %{public}s', message);
    }
  }

  build() {
    // [Start listen_list_change]
    Column() {
      // [StartExclude listen_list_change]
      Text(this.title)
        .fontSize($r('app.float.symbol_font_size'))
        .lineHeight($r('app.float.line_height_or_top'))
        .fontWeight(FontWeight.Medium)
        .margin({
          top: this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.margin_top_title') :
          $r('app.float.title_margin_top')
        })

      Text(CommonConstants.ENTRANCES[1])
        .fontSize($r('app.float.common_font_size'))
        .lineHeight($r('app.float.line_height_common'))
        .fontWeight(FontWeight.Medium)
        .margin({
          top: $r('app.float.margin_common'),
          bottom: $r('app.float.margin_top')
        })
      // [EndExclude listen_list_change]
      List() {
        ForEach(this.directory, (item: DirectoryItem, index: number) => {
          ListItem() {
            Column() {
              // [StartExclude listen_list_change]
              Image(item.uri)
                .width($r('app.float.image_size_entry'))
                .height($r('app.float.image_size_entry'))
                .margin({
                  top: this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.margin_entry_sm_top') :
                  $r('app.float.margin_entry_top'),
                  bottom: this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.margin_top') :
                  $r('app.float.margin_bottom')
                })

              Text(item.title)
                .fontColor($r('app.color.font_color_gray'))
                .fontSize($r('app.float.common_font_size'))
                .lineHeight($r('app.float.line_height_common'))
                .fontWeight(FontWeight.Medium)
                .margin({
                  bottom: this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.margin_entry_title') :
                  $r('app.float.margin_entry_title_top')
                })
              // [EndExclude listen_list_change]
            }
            // [StartExclude listen_list_change]
            .width(this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.index_list_item_width_sm') :
            $r('app.float.index_list_item_width'))
            .height(this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.index_list_item_height_sm') :
            $r('app.float.index_list_item_height'))
            .borderRadius($r('app.float.border_radius_entry'))
            .backgroundColor($r('app.color.index_button_background_color'))
            // [EndExclude listen_list_change]
            .onClick(() => {
              if (index === CommonConstants.COMMON_ZERO) {
                let want: Want = {
                  bundleName: this.bundleName,
                  abilityName: 'SecondAbility'
                };
                let option: StartOptions = { displayId: CommonConstants.COMMON_ZERO };
                this.context.startAbility(want, option);
              } else {
                let want: Want = {
                  bundleName: this.bundleName,
                  abilityName: 'ThirdAbility'
                };
                let option: StartOptions = { displayId: CommonConstants.COMMON_ZERO };
                this.context.startAbility(want, option);
              }
            })
          }
          // [StartExclude listen_list_change]
          .width(this.breakPoint === CommonConstants.BREAK_POINT_SM ? CommonConstants.FULL_PERCENT :
          $r('app.float.index_list_item_width'))
          .height(this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.index_list_item_height_sm') :
          $r('app.float.index_list_item_height'))
          .margin({
            top: $r('app.float.margin_common_top'),
            right: this.breakPoint === CommonConstants.BREAK_POINT_SM ? CommonConstants.COMMON_ZERO :
            $r('app.float.list_item_margin_right')
            // [EndExclude listen_list_change]
          })
        }, (item: DirectoryItem) => JSON.stringify(item))
      }
      // [StartExclude listen_list_change]
      .padding({
        left: this.breakPoint === CommonConstants.BREAK_POINT_SM ? CommonConstants.COMMON_ZERO :
        $r('app.float.list_item_margin_right')
      })
      // [EndExclude listen_list_change]
      .listDirection(this.breakPoint === CommonConstants.BREAK_POINT_SM ? Axis.Vertical : Axis.Horizontal)
    }
    // [End listen_list_change]
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundImage($r('app.media.bg'))
    .backgroundImageSize({
      height: CommonConstants.FULL_PERCENT,
      width: CommonConstants.FULL_PERCENT
    })
  }
}