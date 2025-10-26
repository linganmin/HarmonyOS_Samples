/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  Demo_HMS_ServiceCollaboration_GetCollaborationDeviceInfos,
  Demo_HMS_ServiceCollaboration_StartCollaboration,
} from 'libentry.so';
import { image } from '@kit.ImageKit';
import { CustomDialogExample } from './CustomDialogExample';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';

const REMOTE_CANCEL_BACK: number = 1001202001;

@Entry
@Component
struct Index {
  @State picture: PixelMap | undefined = undefined;
  @State deviceInfos: ServiceCollaboration_CollaborationDeviceInfo[] = [];
  @State selectAbility: number = 1;
  @State deviceName: string = '';
  @State idResult: number = 0;
  @State eventCode: number = 0;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      selectAbility: this.selectAbility,
      deviceName: this.deviceName,
      idResult: this.idResult
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    showInSubWindow: false,
    isModal: true,
    customStyle: false,
  })

  aboutToAppear() {
    this.getDeviceInfos()
  }

  getDeviceInfos() {
    let deviceInfoArray = Demo_HMS_ServiceCollaboration_GetCollaborationDeviceInfos();
    let convertedDeviceInfos: ServiceCollaboration_CollaborationDeviceInfo[] = deviceInfoArray.map(deviceInfo => ({
      deviceType: deviceInfo.deviceType,
      deviceNetworkId: deviceInfo.deviceNetworkId,
      deviceName: deviceInfo.deviceName,
      filterNum: deviceInfo.filterNum,
      serviceCollaborationFilterType: deviceInfo.serviceCollaborationFilterType
    }) as ServiceCollaboration_CollaborationDeviceInfo);
    this.deviceInfos = convertedDeviceInfos.length > 0 ? convertedDeviceInfos : [];
    return this.deviceInfos;
  }

  @Builder
  MyToolBarMenu() {
    Menu() {
      this.DeviceItemBuilder(this.getDeviceInfos())
    }
  }

  build() {
    Column({ space: 20 }) {
      Button($r('app.string.serviceCollaButton'))
        .type(deviceInfo.deviceType == '2in1' ? ButtonType.Normal : ButtonType.Capsule)
        .borderRadius(8)
        .bindMenu(this.MyToolBarMenu)

      if (this.picture) {
        Column() {
          if (this.picture) {
            Image(this.picture)
              .borderStyle(BorderStyle.Dotted)
              .borderWidth(1)
              .objectFit(ImageFit.Contain)
              .height('80%')
          }
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  DeviceItemBuilder(deviceInfos: ServiceCollaboration_CollaborationDeviceInfo[]) {
    if (deviceInfos.length == 0) {
      MenuItem({ content: $r('app.string.Other_device') })
        .enabled(false);
    } else {
      Menu() {
        ForEach(deviceInfos, (item: ServiceCollaboration_CollaborationDeviceInfo) => {
          MenuItemGroup({ header: this.MenuItemGroupHeader($r('app.string.use', item.deviceName)) }) {
            if (item.serviceCollaborationFilterType.includes(ServiceCollaborationFilterType.TAKE_PHOTO)) {
              this.MiddleMenuItem(item, 1, $r('sys.symbol.camera'), $r('app.string.Take_photo'))
            }
            if (item.serviceCollaborationFilterType.includes(ServiceCollaborationFilterType.IMAGE_PICKER)) {
              this.MiddleMenuItem(item, 3, $r('sys.symbol.picture'), $r('app.string.Picker_photo'))
            }
            if (item.serviceCollaborationFilterType.includes(ServiceCollaborationFilterType.SCAN_DOCUMENT)) {
              this.MiddleMenuItem(item, 2, $r('sys.symbol.line_viewfinder'), $r('app.string.Scan'))
            }
          }.constraintSize({ minWidth: 64 });
        }, (item: ServiceCollaboration_CollaborationDeviceInfo) => item.deviceNetworkId)
      }
    }
  }

  @Builder
  MenuItemGroupHeader(tip: string | Resource) {
    Row() {
      Text(tip)
        .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
        .fontColor('ohos_id_color_text_secondary')
        .fontWeight(FontWeight.Medium)
        .opacity(0.8)
        .minFontScale(0.5)
        .maxFontScale(3.2)
        .wordBreak(WordBreak.BREAK_ALL)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(2)
    }.margin({ top: 4 }).justifyContent(FlexAlign.Start).constraintSize({ minHeight: 40 });
  }

  @Builder
  MiddleMenuItem(
    item: ServiceCollaboration_CollaborationDeviceInfo, ability: number, startIcon: Resource,
    content: string | Resource) {
    MenuItem({ symbolStartIcon: new SymbolGlyphModifier(startIcon), content })
      .onChange((selected: Boolean) => {
        if (selected) {
          this.selectAbility = ability;
          this.deviceName = item.deviceName;
          if (this.dialogController != null) {
            this.dialogController.open();
          }
          let idResult =
            Demo_HMS_ServiceCollaboration_StartCollaboration(ability, item.deviceNetworkId,
              (result: DataInfo) => {
                this.dialogController?.close();
                this.onDataReceived(result);
              }, (eventInfo: EventInfo) => {
                this.onEventReceived(eventInfo);
              });
          this.idResult = idResult;
        }
      })
      .margin({ bottom: item.deviceType == 17 ? 2 : 0 })
  }

  onDataReceived = (result: DataInfo): void => {
    let imageSource = image.createImageSource(result.data);
    imageSource && imageSource.createPixelMap().then((pixelMap) => {
      this.picture = pixelMap;
    })
  }
  onEventReceived = (eventInfo: EventInfo): void => {
    this.eventCode = eventInfo.code;
    if (this.eventCode === REMOTE_CANCEL_BACK) {
      this.dialogController?.close();
    }
  }
}

interface ServiceCollaboration_CollaborationDeviceInfo {
  deviceType: number;
  deviceNetworkId: string;
  deviceName: string;
  filterNum: number;
  serviceCollaborationFilterType: ServiceCollaborationFilterType[];
}

enum ServiceCollaborationFilterType {
  TAKE_PHOTO = 'TAKE_PHOTO',
  SCAN_DOCUMENT = 'SCAN_DOCUMENT',
  IMAGE_PICKER = 'IMAGE_PICKER'
}

interface DataInfo {
  data: ArrayBuffer,
  size: number,
  code: number,
}

interface EventInfo {
  code: number;
}
