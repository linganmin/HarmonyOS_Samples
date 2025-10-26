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

import { FileConstants } from '../constant/FileConstants';
import { FileItem } from '../model/FileItem';
import { CompressDialog, PreviewDialog } from '../view/DialogView';
import { CompressUtil } from '../utils/CompressUtil';
import { FileUtil } from '../utils/FileUtil';

@Entry
@Component
struct Index {
  @StorageLink('fileList') fileList: FileItem[] = [];
  private previewDialogController: CustomDialogController | null = null;
  private compressDialogController: CustomDialogController | null = null;
  private compressUtil: CompressUtil = new CompressUtil();
  private fileUtil: FileUtil = new FileUtil();

  build() {
    Column() {
      Row() {
        Text(FileConstants.TITLE[0])
          .fontSize($r('app.float.title_font'))
          .lineHeight($r('app.float.title_font_line'))
          .fontWeight(FontWeight.Bold)
      }
      .height($r('app.float.title_row_height'))
      .width(FileConstants.FULL_PERCENT)

      List({ space: FileConstants.LIST_SPACE }) {
        ForEach(this.fileList, (item: FileItem, index: number) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.getFileName() + item.getFileType())
                  .fontSize($r('app.float.file_name_font'))
                  .lineHeight($r('app.float.file_name_font_line'))
                  .fontWeight(FileConstants.FONT_WEIGHT_500)
                  .margin({ bottom: $r('app.float.file_name_margin') })
                Text(this.fileUtil.formatFileSize(item.getFileSize()))
                  .fontSize($r('app.float.file_size_font'))
                  .lineHeight($r('app.float.file_size_font_line'))
                  .fontWeight(FontWeight.Normal)
                  .fontColor($r('app.color.file_size'))
              }
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
              .height(FileConstants.FULL_PERCENT)

              Blank()

              Row() {
                Text(FileConstants.OPERATION_LIST[0])
                  .fontSize($r('app.float.operation_font'))
                  .lineHeight($r('app.float.operation_row_line'))
                  .fontWeight(FileConstants.FONT_WEIGHT_500)
                  .visibility(item.getFileType() !== FileConstants.TXT_FILE_TYPE ? Visibility.None : Visibility.Visible)
                  .fontColor($r('app.color.operation_font'))
                  .onClick(() => {
                    this.previewDialogController = new CustomDialogController({
                      builder: PreviewDialog({ fileContent: item.getFileContent() }),
                      customStyle: true,
                      alignment: DialogAlignment.Center
                    });
                    this.previewDialogController.open();
                  })
                Text(FileConstants.OPERATION_LIST[1])
                  .fontSize($r('app.float.operation_font'))
                  .lineHeight($r('app.float.operation_row_line'))
                  .fontWeight(FileConstants.FONT_WEIGHT_500)
                  .visibility(item.getFileType() === FileConstants.TXT_FILE_TYPE &&
                    !item.getFilePath().includes(FileConstants.DECOMPRESSED_FILE_DIRECTORY) ?
                    Visibility.Visible : Visibility.None)
                  .fontColor($r('app.color.operation_font'))
                  .margin({ left: $r("app.float.operation_left_margin") })
                  .onClick(() => {
                    this.compressDialogController = new CustomDialogController({
                      builder: CompressDialog({ fileName: item.getFileName() }),
                      customStyle: true,
                      alignment: DialogAlignment.Center
                    });
                    this.compressDialogController.open();
                  })
                Text(FileConstants.OPERATION_LIST[2])
                  .fontSize($r('app.float.operation_font'))
                  .lineHeight($r("app.float.operation_row_line"))
                  .fontWeight(FileConstants.FONT_WEIGHT_500)
                  .visibility(item.getFileType() === FileConstants.TXT_FILE_TYPE ? Visibility.None : Visibility.Visible)
                  .fontColor($r('app.color.operation_font'))
                  .onClick(() => {
                    switch (item.getFileType()) {
                      case FileConstants.COMPRESSED_FILE_SUFFIXES[0]:
                        this.compressUtil.decompressGzipFile(item.getFileName());
                        break;
                      case FileConstants.COMPRESSED_FILE_SUFFIXES[1]:
                        this.compressUtil.decompressZipFile(item.getFileName());
                        break;
                      case FileConstants.COMPRESSED_FILE_SUFFIXES[2]:
                        this.compressUtil.decompress7zFile(item.getFileName());
                        break;
                      case FileConstants.COMPRESSED_FILE_SUFFIXES[3]:
                        this.compressUtil.decompressTarFile(item.getFileName());
                        break;
                      default:
                        break;
                    }
                  })
              }
              .height($r("app.float.operation_row_line"))
              .padding({
                left: $r('app.float.operation_row_padding'),
                right: $r('app.float.operation_row_padding')
              })
            }
            .width(FileConstants.FULL_PERCENT)
            .height($r('app.float.list_row_height'))
            .borderRadius($r('app.float.list_row_radius'))
            .backgroundColor(Color.White)
            .padding({
              left: $r('app.float.page_padding'),
              right: $r('app.float.page_padding')
            })
          }
        }, (item: FileItem, index: number) => JSON.stringify(item) + index)
      }
      .width(FileConstants.FULL_PERCENT)
      .layoutWeight(1)

      Button(FileConstants.BUTTON_TEXTS[1])
        .fontWeight(FileConstants.FONT_WEIGHT_500)
        .fontSize($r('app.float.rawfile_button_font'))
        .width(FileConstants.FULL_PERCENT)
        .height($r('app.float.rawfile_button_height'))
        .margin({
          top: $r('app.float.rawfile_button_margin'),
          bottom: $r('app.float.rawfile_button_margin')
        })
        .onClick(() => {
          // Import the rawfile.
          this.fileUtil.copyRawfile('rawfile', FileConstants.TXT_FILE_TYPE, this.getUIContext());
        })
    }
    .width(FileConstants.FULL_PERCENT)
    .height(FileConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.page_background'))
    .padding({
      left: $r('app.float.page_padding'),
      right: $r('app.float.page_padding')
    })
  }
}