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

import { CommonConstants } from '../constants/CommonConstants';
import LocationUtil from '../utils/LocationUtil';
import { abilityAccessCtrl } from '@kit.AbilityKit';
import PermissionManager from '../utils/PermissionManager';
import { geoLocationManager } from '@kit.LocationKit';
import Logger from '../utils/Logger';

const TAG = 'LocationView';

@Component
export struct LocationView {
  private context = this.getUIContext().getHostContext()!;
  @State selectedAddress: string | Resource = '';
  @State isSelectionVisible: boolean = false;
  @State addresses: string[] = [];

  async getCurrentAddresses() {
    if (!this.isLocationEnabled()) {
      await PermissionManager.requestGlobalSwitch(abilityAccessCtrl.SwitchType.LOCATION, this.context);
    }
    await PermissionManager.requestPermissions(CommonConstants.PERMISSIONS, this.context);
    this.addresses = await LocationUtil.getCurrentAddresses();
  }

  isLocationEnabled(): boolean {
    try {
      return geoLocationManager.isLocationEnabled();
    } catch (e) {
      Logger.error(TAG, `Failed to isLocationEnabled: ${e.message}`);
      return false;
    }
  }

  @Builder
  createButton() {
    Row() {
      SymbolGlyph($r('sys.symbol.local_fill'))
        .fontSize(14)
        .fontColor(this.selectedAddress ? [Color.Blue] : [Color.Gray])
        .margin({
          right: 3
        })
      Text(this.selectedAddress || $r('app.string.add_local'))
        .fontSize(12)
        .fontColor('#616161')
        .constraintSize({
          maxWidth: '85%'
        })
        .maxLines(1)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
      if (this.selectedAddress) {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontColor([Color.Black])
          .fontSize(14)
          .onClick(() => {
            this.selectedAddress = '';
          })
      }
    }
    .backgroundColor('#f2f2f2')
    .padding({
      left: 10,
      right: 10
    })
    .height(28)
    .borderRadius(14)
    .margin({
      bottom: 5,
      left: 16
    })
    .onClick(async () => {
      await this.getCurrentAddresses();
      this.isSelectionVisible = true;
    })
  }

  @Builder
  selection() {
    Row() {
      List({ space: 8 }) {
        ForEach(this.addresses, (address: string) => {
          ListItem() {
            Text(address)
              .backgroundColor(Color.White)
              .fontColor('#191919')
              .fontSize(12)
              .borderRadius(28)
              .height(28)
              .padding({
                right: 8,
                left: 8
              })
          }
          .onClick(() => {
            this.selectedAddress = address;
            this.isSelectionVisible = false;
          })
        }, (item: string) => item)
      }
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Center)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .margin({
        right: 5
      })
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontColor([Color.Black])
        .fontSize(14)
        .onClick(() => {
          this.isSelectionVisible = false;
        })
    }
    .borderWidth({
      top: 1,
      bottom: 1
    })
    .borderColor('#DBDCDE')
    .padding({
      right: 16,
      left: 16
    })
    .height(45)
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    Column() {
      this.createButton()
      if (this.isSelectionVisible) {
        this.selection()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}