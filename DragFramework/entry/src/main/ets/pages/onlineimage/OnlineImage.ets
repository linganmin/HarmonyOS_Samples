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

import { unifiedDataChannel, uniformDataStruct, uniformTypeDescriptor } from '@kit.ArkData';
import { TextModifier, SubHeader, LengthUnit } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../../common/Constants';
import { BreakpointType } from '../../common/Utils';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

@Builder
export function PageOnlineImageBuilder() {
  OnlineImageDrag();
}

@Entry
@Component
struct OnlineImageDrag {
  @State targetImage: string = '';
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;
  private primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  // private context = getContext(this) as common.UIAbilityContext;
  private context?: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private filesDir = this.context!.filesDir;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
            // [Start OnlineImageDraggable]
            Image('https://www-file.huawei.com/-/media/corp2020/home/banner/12/pura-x-1.jpg')
            // [StartExclude OnlineImageDraggable]
              .width('100%')
              .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
              .borderRadius(16)
              // [EndExclude OnlineImageDraggable]
              .draggable(true)
              // [StartExclude OnlineImageDraggable]
              .onDragEnd((event: DragEvent) => {
                let ret = event.getResult();
                if (ret === 0) {
                  hilog.info(0x0000, TAG, `%{public}s`, `enter ret === 0`);
                } else {
                  hilog.info(0x0000, TAG, `%{public}s`, `enter ret !== 0`);
                }
              })
            // [EndExclude OnlineImageDraggable]
            // [End OnlineImageDraggable]
          }

          SubHeader({
            primaryTitle: $r('app.string.image_text_title'),
            primaryTitleModifier: this.primaryModifier,
            contentMargin: {
              start: {
                value: 0,
                unit: LengthUnit.VP
              }
            }
          })
          // [Start OnlineImageGetImageUri]
          // [Start OnlineImageDownload]
          Column() {
            Image(this.targetImage)
            // [StartExclude OnlineImageDownload]
            // [StartExclude OnlineImageGetImageUri]
              .width('100%')
              .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
              .borderRadius(16)
            // [EndExclude OnlineImageGetImageUri]
            // [EndExclude OnlineImageDownload]
          }
          // [StartExclude OnlineImageGetImageUri]
          // [StartExclude OnlineImageDownload]
          .constraintSize({ maxWidth: '100%' })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .allowDrop([uniformTypeDescriptor.UniformDataType.IMAGE])
          // [EndExclude OnlineImageGetImageUri]
          // [EndExclude OnlineImageDownload]
          .onDrop((event?: DragEvent) => {
            try {
              let dragData = event?.getData() as unifiedDataChannel.UnifiedData;
              if (dragData) {
                let records: Array<unifiedDataChannel.UnifiedRecord> = dragData.getRecords();
                for (let i = 0; i < records.length; i++) {
                  let types = records[i].getTypes();
                  if (types.includes(uniformTypeDescriptor.UniformDataType.FILE_URI)) {
                    // [StartExclude OnlineImageDownload]
                    const fileUriUds =
                      records[i].getEntry(uniformTypeDescriptor.UniformDataType.FILE_URI) as uniformDataStruct.FileUri;
                    let typeDescriptor = uniformTypeDescriptor.getTypeDescriptor(fileUriUds.fileType);
                    // [EndExclude OnlineImageDownload]
                    if (typeDescriptor.belongsTo(uniformTypeDescriptor.UniformDataType.IMAGE)) {
                      // [StartExclude OnlineImageDownload]
                      this.targetImage = fileUriUds.oriUri;
                      // [EndExclude OnlineImageDownload]
                      // [StartExclude OnlineImageGetImageUri]
                      request.downloadFile(this.context, {
                        url: fileUriUds.oriUri,
                        filePath: this.filesDir + '/test.png'
                      }).then(() => {
                        const file = fileIo.openSync(this.filesDir + '/test.png', fileIo.OpenMode.READ_WRITE);
                        const arrayBuffer = new ArrayBuffer(1024);
                        const readLen = fileIo.readSync(file.fd, arrayBuffer);
                        buffer.from(arrayBuffer, 0, readLen);
                        fileIo.closeSync(file);
                      }).catch((error: BusinessError) => {
                        hilog.error(0x0000, TAG, `%{public}s`, error.code, error.message);
                      })
                      // [EndExclude OnlineImageGetImageUri]
                    }
                  }
                }
              }
            }
            // [StartExclude OnlineImageGetImageUri]
            // [StartExclude OnlineImageDownload]
            catch (error) {
              const err = error as BusinessError;
              hilog.error(0x0000, TAG, `%{public}s`, err.code, err.message);
            }
            // [EndExclude OnlineImageDownload]
            // [EndExclude OnlineImageGetImageUri]
          });

          // [End OnlineImageGetImageUri]
          // [End OnlineImageDownload]
        }
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 16,
        })
        .backgroundColor($r('sys.color.background_secondary'))
      }
    }
    .title(getStringSync(this.context!, $r('app.string.online_image_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}