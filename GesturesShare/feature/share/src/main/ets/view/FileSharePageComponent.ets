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

// [Start FileSharePage]
import { common } from '@kit.AbilityKit';
import { filePreview } from '@kit.PreviewKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FileData, FILE_SOURCES, ShareType } from '../model/FileData';
import { ShareModel } from '../model/ShareModel';
import { FileUtil, BreakpointConstants, BreakpointType } from '@ohos/common';

@Component
export struct FileSharePageComponent {
  // [StartExclude FileSharePage]
  @StorageLink('GesturesShare_pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('GesturesShare_isShareLink') isShareLink: boolean = false;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private shareModel: ShareModel | undefined = undefined;
  // [EndExclude FileSharePage]
  // Pending shared data index.
  @State fileShare: number[] = [];
  // All file data collection.
  @State dataList: FileData[] = FILE_SOURCES;

  build() {
    NavDestination() {
      List({ space: 16 }) {
        ForEach(this.dataList, (item: FileData, index: number) => {
          ListItem() {
            Stack() {
              // [StartExclude FileSharePage]
              Column() {
                Image(item.thumbnail)
                  .width('100%')
                  .aspectRatio(1)
                  .borderRadius(10)
                  .onClick(() => {
                    if (!canIUse('SystemCapability.FileManagement.FilePreview.Core')) {
                      return;
                    }
                    let uiContext = this.getUIContext().getHostContext();
                    let displayInfo: filePreview.DisplayInfo = {
                      x: 100,
                      y: 100,
                      width: 800,
                      height: 800
                    };
                    let fileInfo: filePreview.PreviewInfo = {
                      title: item.name,
                      uri: item.url,
                      mimeType: FileUtil.getMimeTypeFromPath((item.url))
                    };
                    filePreview.openPreview(uiContext, fileInfo, displayInfo, (err) => {
                      if (err && err.code) {
                        hilog.error(0x0000, 'GesturesShare', `Failed to open preview. ${err.code} ${err.message}`);
                        return;
                      }
                      hilog.info(0x0000, 'GesturesShare', 'Success in opening preview');
                    });
                  })
              }
              // [EndExclude FileSharePage]
              Column() {
                Checkbox({ name: index + '', group: 'checkboxGroup'})
                  // [StartExclude FileSharePage]
                  .select(false)
                  .selectedColor('#0A59F7')
                  .unselectedColor(Color.White)
                  .shape(CheckBoxShape.CIRCLE)
                  .margin({
                    right: 10
                  })
                  // [EndExclude FileSharePage]
                  .onChange((value: boolean) => {
                    if (value) {
                      this.fileShare.push(index);
                    } else {
                      this.fileShare.splice(this.fileShare.indexOf(index), 1);
                    }
                    this.shareModel = ShareModel.getInstance(this.context);
                    this.shareModel.setFileShare(this.fileShare);
                    this.shareModel.setVideoDataList(this.dataList);
                  })
                // [StartExclude FileSharePage]
              }
              .layoutWeight(1)
            }
            .alignContent(Alignment.BottomEnd)
          }
        }, (item: FileData, index: number) => index + JSON.stringify(item))
      }
      .lanes(new BreakpointType({
        sm: 2,
        md: 4,
        lg: 6
      }).getValue(this.currentBreakpoint), 8)
      .margin({
        left: new BreakpointType({
          sm: 16,
          md: 24,
          lg: 32
        }).getValue(this.currentBreakpoint),
        right: new BreakpointType({
          sm: 16,
          md: 24,
          lg: 32
        }).getValue(this.currentBreakpoint)
      })
      // [EndExclude FileSharePage]
    }
    // [StartExclude FileSharePage]
    .title($r('app.string.gestures_share_file'))
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
    .onBackPressed(() => {
      this.fileShare = [];
      this.shareModel = ShareModel.getInstance(this.context);
      this.shareModel.setFileShare(this.fileShare);
      this.shareModel.setVideoDataList(this.dataList);
      return false;
    })
    // [EndExclude FileSharePage]
    .onShown(() => {
      // [StartExclude FileSharePage]
      if (this.isShareLink) {
        this.pageInfos.pushPathByName('LinkSharePage', null, true);
        return;
      }
      if (!canIUse('SystemCapability.Collaboration.SystemShare')) {
        return;
      }
      // [EndExclude FileSharePage]
      this.shareModel = ShareModel.getInstance(this.context);
      this.shareModel.immersiveListening(ShareType.FILE_SHARE);
    })
    .onHidden(() => {
      this.shareModel = ShareModel.getInstance(this.context);
      this.shareModel.immersiveDisableListening();
    })
  }
}
// [End FileSharePage]

@Builder
export function FileSharePageComponentBuilder() {
  FileSharePageComponent()
}