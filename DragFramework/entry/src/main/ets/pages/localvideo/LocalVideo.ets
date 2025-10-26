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
import { BusinessError, } from '@kit.BasicServicesKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { Constants } from '../../common/Constants';
import { BreakpointType } from '../../common/Utils';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

@Builder
export function PageLocalVideoBuilder() {
  LocalVideoDrag();
}

@Entry
@Component
struct LocalVideoDrag {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;
  @State targetVideoUri: string = '';
  private originalVideoUri: string = '';
  private context?: Context = this.getUIContext().getHostContext();
  private primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            // [Start LocalVideoDraggable]
            // [Start LocalVideoOnDragStart]
            Video({
              src: $rawfile('video.mp4'),
              controller: new VideoController()
            })
              // [StartExclude LocalVideoDraggable]
              // [StartExclude LocalVideoOnDragStart]
              .width('100%')
              .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
              .autoPlay(true)
              .loop(true)
                // [EndExclude LocalVideoDraggable]
              .draggable(true)
                // [StartExclude LocalVideoDraggable]
              .borderRadius(16)
                // [EndExclude LocalVideoOnDragStart]
              .onDragStart((event: DragEvent) => {
                try {
                  let data = this.context!.resourceManager.getRawFdSync('video.mp4');
                  let filePath = this.context?.filesDir + '/video.mp4';
                  let dest = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
                  let bufferSize = data.length as number;
                  let buf = new ArrayBuffer(bufferSize);
                  fileIo.readSync(data.fd, buf, { offset: data.offset, length: bufferSize });
                  fileIo.writeSync(dest.fd, buf, { offset: 0, length: bufferSize });
                  fileIo.close(dest.fd);
                  this.context!.resourceManager.closeRawFd('video.mp4');
                  this.originalVideoUri = fileUri.getUriFromPath(filePath);
                  let unifiedData = new unifiedDataChannel.UnifiedData();
                  let unifiedRecord = new unifiedDataChannel.UnifiedRecord();
                  let video: uniformDataStruct.FileUri = {
                    uniformDataType: 'general.file-uri',
                    oriUri: this.originalVideoUri,
                    fileType: 'general.video'
                  }
                  unifiedRecord.addEntry(uniformTypeDescriptor.UniformDataType.VIDEO, video);
                  unifiedData.addRecord(unifiedRecord);
                  event.setData(unifiedData);
                } catch (error) {
                  const err = error as BusinessError;
                  hilog.error(0x0000, TAG, `%{public}s`, err.code, err.message);
                }
              })
            // [End LocalVideoOnDragStart]
            // [EndExclude LocalVideoDraggable]
            // [End LocalVideoDraggable]
          }
          .width('100%')

          SubHeader({
            primaryTitle: $r('app.string.localvideo_text_title'),
            primaryTitleModifier: this.primaryModifier,
            contentMargin: {
              start: {
                value: 0,
                unit: LengthUnit.VP
              }
            }
          })
          // [Start LocalVideoOnDrop]
          Column() {
            Video({ src: this.targetVideoUri, controller: new VideoController() })
              // [StartExclude LocalVideoOnDrop]
              .width('100%')
              .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
              .borderRadius(16)
              .visibility(this.targetVideoUri === '' ? Visibility.Hidden : Visibility.Visible)
              .autoPlay(true)
              .loop(true)
            // [EndExclude LocalVideoOnDrop]
          }
          // [StartExclude LocalVideoOnDrop]
          .constraintSize({ maxWidth: '100%' })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .allowDrop([uniformTypeDescriptor.UniformDataType.VIDEO])
          // [EndExclude LocalVideoOnDrop]
          .onDrop((event?: DragEvent) => {
            try {
              let progressListener: unifiedDataChannel.DataProgressListener =
                (_progress: unifiedDataChannel.ProgressInfo, dragData: UnifiedData | null) => {
                  if (dragData) {
                    let records: Array<unifiedDataChannel.UnifiedRecord> = dragData.getRecords();
                    for (let i = 0; i < records.length; i++) {
                      let types = records[i].getTypes();
                      if (types.includes(uniformTypeDescriptor.UniformDataType.FILE_URI)) {
                        const fileUriUds =
                          records[i].getEntry(uniformTypeDescriptor.UniformDataType.FILE_URI) as uniformDataStruct.FileUri;
                        let typeDescriptor = uniformTypeDescriptor.getTypeDescriptor(fileUriUds.fileType);
                        if (typeDescriptor.belongsTo(uniformTypeDescriptor.UniformDataType.VIDEO)) {
                          this.targetVideoUri = fileUriUds.oriUri;
                        }
                      }
                    }
                  } else {
                    hilog.info(0x0000, TAG, 'dragData is undefined');
                  }
                };
              const destUri = fileUri.getUriFromPath(this.context!.distributedFilesDir);
              let options: DataSyncOptions = {
                destUri: destUri,
                fileConflictOptions: unifiedDataChannel.FileConflictOptions.OVERWRITE,
                progressIndicator: unifiedDataChannel.ProgressIndicator.DEFAULT,
                dataProgressListener: progressListener,
              };
              (event as DragEvent).startDataLoading(options);
            } catch (error) {
              const err = error as BusinessError;
              hilog.error(0x0000, TAG, `startDataLoading errorCode: ${err.code}, errorMessage: ${err.message}`);
            }
          }, { disableDataPrefetch: true })
          // [End LocalVideoOnDrop]
        }
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        })
        .backgroundColor($r('sys.color.background_secondary'))
      }
    }
    .title(getStringSync(this.context!, $r('app.string.localvideo_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}