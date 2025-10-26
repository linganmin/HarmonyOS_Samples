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

import { dataSharePredicates, unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { util } from '@kit.ArkTS';
import {
  CollaborationServiceFilter,
  CollaborationServiceStateDialog,
  createCollaborationServiceMenuItems
} from '@hms.collaboration.service';
import { CommonConstants } from '../constants/CommonConstants';
import { ImageInfo } from '../model/ContentInfo';
import { fileSelect } from '../utils/FileUtil';
import { BreakpointType } from '../utils/BreakpointSystem';

const DOMAIN = 0x0000;
const TAG = 'AddPic';
const FORMAT = '%{public}s';

/*
 * Image area.
 */
@Component
export struct AddPic {
  @StorageLink('imageUriArray') imageUriArray: Array<ImageInfo> = [];
  @StorageLink('attachments') attachments: Object = [];
  @StorageLink('currentBreakpoint') currentBreakpoint: string = 'sm';
  @State pasteShow: boolean = false;
  @State toastShow: boolean = false;
  // Get the UIAbilityContext information of device A.
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  /*
   * Select picture method.
   */
  selectImage(): void {
    fileSelect().then((uri: Array<ResourceStr>) => {
      if ((this.imageUriArray.length + uri.length) > CommonConstants.MAX_ADD_PIC) {
        uri.length = CommonConstants.MAX_ADD_PIC - this.imageUriArray.length;
        try {
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.add_picture_prompt') });
        } catch (err) {
          hilog.error(DOMAIN, TAG, FORMAT, `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
        }
      }
      uri.forEach((item: ResourceStr) => {
        this.getThumbnail(item as string);
      });
    })
  }

  async getThumbnail(uri: string) {
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.context);
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo('uri', uri);
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };
    try {
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await phAccessHelper.getAssets(fetchOption);
      let asset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
      asset.getThumbnail((err, pixelMap) => {
        if (err === undefined) {
          hilog.info(DOMAIN, TAG, FORMAT, 'getThumbnail successful ' + pixelMap);
          let imageName = asset.displayName.substring(0, (asset.displayName).indexOf('.'));
          this.PixelMapToBuffer(pixelMap, imageName);
          this.imageUriArray.push({ imagePixelMap: pixelMap, imageName: imageName });
        } else {
          hilog.error(DOMAIN, TAG, FORMAT, `getThumbnail fail with error: ${err.code}, ${err.message}`);
        }
      });
    } catch (err) {
      hilog.error(DOMAIN, TAG, FORMAT, `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  PixelMapToBuffer(pixelMap: image.PixelMap, displayName: string): void {
    const imagePackerApi: image.ImagePacker = image.createImagePacker();
    let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 100 };
    imagePackerApi.packToData(pixelMap, packOpts).then((data: ArrayBuffer) => {
      this.writeDistributedFile(data, displayName);
    }).catch((err: BusinessError) => {
      hilog.info(DOMAIN, TAG, FORMAT, `PackToData failed. Cause code: ${err.code}, message: ${err.message}`);
    });
  }

  // [Start write]
  // [Start write_distributed_file]
  writeDistributedFile(buf: ArrayBuffer, displayName: string): void {
    // The asset is written to the distributed file directory.
    // Obtain the distributed file directory path.
    let distributedDir: string = this.context.distributedFilesDir;
    let fileName: string = '/' + displayName;
    let filePath: string = distributedDir + fileName;
    try {
      // Create a file in a distributed directory.
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      hilog.info(DOMAIN, TAG, FORMAT, 'Create file success.');
      // Write content to a file (if the asset is a picture, the picture can be converted to a buffer to write)
      fs.writeSync(file.fd, buf);
      // closed file.
      fs.closeSync(file.fd);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      hilog.info(DOMAIN, TAG, FORMAT,
        `Failed to openSync / writeSync / closeSync. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // [End write]
  // [End write_distributed_file]

  getDataFromUdmfRetry(event: DragEvent, callback: (data: DragEvent) => void) {
    try {
      let data: UnifiedData = event.getData();
      if (!data) {
        return false;
      }
      let records: Array<unifiedDataChannel.UnifiedRecord> = data.getRecords();
      if (!records || records.length <= 0) {
        return false;
      }
      callback(event);
      return true;
    } catch (e) {
      hilog.info(DOMAIN, TAG, FORMAT, "getData failed, code = " + (e as BusinessError).code + ", message = " +
      (e as BusinessError).message);
      return false;
    }
  }

  getDataFromUdmf(event: DragEvent, callback: (data: DragEvent) => void) {
    if (this.getDataFromUdmfRetry(event, callback)) {
      return;
    }
    setTimeout(() => {
      this.getDataFromUdmfRetry(event, callback);
    }, 1500);
  }

  // [Start fallInfo]
  // Remote images fall into.
  doInsertPicture(stateCode: number, bufferType: string, buffer: ArrayBuffer): void {
    if (stateCode != 0) {
      return;
    }
    if (bufferType === 'general.image') {
      let imageSource = image.createImageSource(buffer);
      imageSource.createPixelMap().then((pixelMap) => {
        if (this.imageUriArray.length < CommonConstants.MAX_ADD_PIC) {
          let uuid = util.generateRandomUUID();
          this.PixelMapToBuffer(pixelMap, uuid);
          this.imageUriArray.push({ imagePixelMap: pixelMap, imageName: uuid });
        }
      })
    }
  }

  // [End fallInfo]

  // Uri to pixelMap.
  uri2pixelMap(uri: string): void {
    try {
      let imageUri = uri;
      let file = fs.openSync(imageUri, fs.OpenMode.READ_ONLY);
      const imageSource = image.createImageSource(file.fd);
      fs.closeSync(file);
      const imagePackApi = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
      imagePackApi.packToData(imageSource, packOpts).then(async readBuffer => {
        let imageSource: image.ImageSource = image.createImageSource(readBuffer as ArrayBuffer);
        let option: image.InitializationOptions = {
          pixelFormat: 3,
          size: {
            width: 100,
            height: 100
          }
        };
        imageSource.createPixelMap(option).then((pixelMap: PixelMap) => {
          if (this.imageUriArray.length < CommonConstants.MAX_ADD_PIC) {
            let uuid = util.generateRandomUUID();
            this.PixelMapToBuffer(pixelMap, uuid);
            this.imageUriArray.push({ imagePixelMap: pixelMap, imageName: uuid });
          } else {
            try {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.add_picture_prompt') });
            } catch (err) {
              hilog.error(DOMAIN, TAG, FORMAT, `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
            }
          }
        });
      }).catch((err: BusinessError) => {
        hilog.info(DOMAIN, TAG, FORMAT, `PackToData failed. Cause code: ${err.code}, message: ${err.message}`);
      });
    } catch (err) {
      hilog.error(DOMAIN, TAG, FORMAT, `OpenSync failed. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  // [Start copy]
  // Copy picture.
  async setPasteDataTest(pixelMap: image.PixelMap): Promise<void> {
    let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_PIXELMAP, pixelMap);
    let systemPasteBoard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    await systemPasteBoard.setData(pasteData).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, FORMAT, `Failed to set pastedata. Code: ${err.code}, message: ${err.message}`);
    });
  }

  // [End copy]

  // [Start paste]
  // Paste picture.
  async getPasteDataTest(): Promise<void> {
    let systemPasteBoard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteBoard.getData((err: BusinessError, data: pasteboard.PasteData) => {
      if (err) {
        hilog.error(DOMAIN, TAG, FORMAT, `Failed to get pastedata. Code: ${err.code}, message: ${err.message}`);
        return;
      }
      // Process pasteData, obtain type, number, etc
      // Retrieve the number of records in the clipboard.
      let recordCount: number = data.getRecordCount();
      // Retrieve the type of data from the clipboard.
      let types: string = data.getPrimaryMimeType();
      hilog.info(DOMAIN, TAG, FORMAT, `recordCount: ${recordCount}, types: ${types}`);
      // Retrieve the content of data from the clipboard.
      if (types === 'pixelMap') {
        let primaryPixelMap: image.PixelMap = data.getPrimaryPixelMap();
        if (this.imageUriArray.length < CommonConstants.MAX_ADD_PIC) {
          let uuid = util.generateRandomUUID();
          this.PixelMapToBuffer(primaryPixelMap, uuid);
          this.imageUriArray.push({ imagePixelMap: primaryPixelMap, imageName: uuid });
        } else {
          this.toastShow = true;
        }
      } else if (types === 'text/uri') {
        this.uri2pixelMap(data.getPrimaryUri());
      }
    });
  }

  // [End paste]

  // [Start onDrop]
  // [Start buffer]
  build() {
    Column() {
      // [StartExclude onDrop]
      CollaborationServiceStateDialog({
        onState: (stateCode: number, bufferType: string, buffer: ArrayBuffer): void => this.doInsertPicture(stateCode,
          bufferType, buffer)
      })
      // [StartExclude buffer]
      this.addPic();
      // [EndExclude buffer]
      // [EndExclude onDrop]
    }
    // [StartExclude buffer]
    .draggable(true)
    .allowDrop([uniformTypeDescriptor.UniformDataType.IMAGE,
      uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP])
    .onDrop((dragEvent?: DragEvent) => {
      // The logic behind the image falling in, achieving image writing.
      // [StartExclude onDrop]
      this.getDataFromUdmf((dragEvent as DragEvent), async (event: DragEvent) => {
        try {
          let records: Array<unifiedDataChannel.UnifiedRecord> = event.getData().getRecords();
          for (let i = 0; i < records.length; i++) {
            // PixelMap converted from image to pixelMap in the image system.
            if (records[i].getType() === uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP) {
              let pixelMapRecord = records[i] as unifiedDataChannel.SystemDefinedPixelMap;
              const mWidth: number = (pixelMapRecord.details?.width ?? -1) as number;
              const mHeight: number = (pixelMapRecord.details?.height ?? -1) as number;
              const mPixelFormat: image.PixelMapFormat =
                (pixelMapRecord.details?.['pixel-format'] ?? image.PixelMapFormat.UNKNOWN) as image.PixelMapFormat;
              const mItemPixelMapData: Uint8Array = pixelMapRecord.rawData;
              const opts: image.InitializationOptions = {
                srcPixelFormat: mPixelFormat,
                pixelFormat: mPixelFormat,
                size: {
                  width: mWidth,
                  height: mHeight
                }
              };
              const buffer: ArrayBuffer = mItemPixelMapData.buffer.slice(mItemPixelMapData.byteOffset,
                mItemPixelMapData.byteOffset + mItemPixelMapData.byteLength);
              const pixelMap = await image.createPixelMap(buffer, opts);
              if (this.imageUriArray.length < CommonConstants.MAX_ADD_PIC) {
                let uuid = util.generateRandomUUID();
                this.PixelMapToBuffer(pixelMap, uuid);
                this.imageUriArray.push({ imagePixelMap: pixelMap, imageName: uuid });
              } else {
                try {
                  this.getUIContext().getPromptAction().showToast({ message: $r('app.string.add_picture_prompt') });
                } catch (err) {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
                }
              }
            } else {
              // Convert the image from imageUri to PixelMap.
              this.uri2pixelMap((records[i] as unifiedDataChannel.Image).imageUri);
            }
          }
          event.useCustomDropAnimation = false;
          // If the result is explicitly set to successful, pass this value to the onDragEnd of the dragging party.
          event.setResult(DragResult.DRAG_SUCCESSFUL);
        } catch (err) {
          hilog.error(DOMAIN, TAG, FORMAT, `GetData failed. Cause code: ${err.code}, message: ${err.message}`);
        }
        // [EndExclude onDrop]
      })
    })

    // [EndExclude buffer]
  }

  // [End buffer]

  // [StartExclude onDrop]
  @Builder
  copy(imagePixelMap: image.PixelMap) {
    Row() {
      Text($r('app.string.copy'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: 16 })
    .height(48)
    .width(224)
    .onClick(() => {
      this.setPasteDataTest(imagePixelMap);
    })
  }

  @Builder
  paste() {
    Row() {
      PasteButton({ text: PasteDescription.PASTE })
        .fontSize(16)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Color.White)
        .padding({ right: 176 })
        .width('100%')
        .onClick(() => {
          this.getPasteDataTest();
          this.pasteShow = false;
        })
    }
    .height(48)
    .width(224)
  }
  // [EndExclude onDrop]

  /*
   *  Adding an image.
   */
  @Builder
  addPic() {
    Row() {
      List({ space: CommonConstants.LIST_COMM_SPACE }) {
        ForEach(this.imageUriArray, (item: ImageInfo) => {
          ListItem() {
            Image(item.imagePixelMap)// [StartExclude onDrop]
              .width($r('app.integer.add_image_area_size'))
              .height($r('app.integer.add_image_area_size'))
              .borderRadius($r('app.integer.border_radius3'))
              .visibility(item ? Visibility.Visible : Visibility.None)// [EndExclude onDrop]
              .draggable(true)
              .onDragEnd((event) => {
                // The logic after dragging and dropping is completed.
                // [StartExclude onDrop]
                // The result value obtained from onDragEnd is set by the recipient onDrop.
                if (event.getResult() === DragResult.DRAG_FAILED) {
                  try {
                    this.getUIContext().getPromptAction().showToast({ duration: 100, message: 'Drag failed' });
                  } catch (err) {
                    hilog.error(DOMAIN, TAG, FORMAT,
                      `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
                  }
                }
                // [EndExclude onDrop]
              })// [StartExclude onDrop]
              .bindMenu(this.copy(item.imagePixelMap))
            // [EndExclude onDrop]
          }
        }, (item: ImageInfo, index: number) => JSON.stringify(item) + index)
        // [StartExclude onDrop]
        this.addDefaultPic()
        // [EndExclude onDrop]
      }
      // [StartExclude onDrop]
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)

      // [EndExclude onDrop]
    }
    // [StartExclude onDrop]
    .height($r('app.integer.add_image_area_size'))
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(VerticalAlign.Center)
    .padding({
      left: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
        $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint),
      right: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
        $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint)
    })
    .onClick(() => {
      this.pasteShow = false;
      this.pasteShow = true;
    })
    .bindMenu(this.pasteShow, this.paste(), {
      onDisappear: () => {
        if (this.toastShow) {
          try {
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.add_picture_prompt') });
          } catch (err) {
            hilog.error(DOMAIN, TAG, FORMAT, `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
          }
          this.toastShow = false;
        }
      }
    })

    // [EndExclude onDrop]
  }

  // [End onDrop]

  // [Start menu]
  // Remote menu.
  @Builder
  MyTestMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.picture_2')),
        content: $r('app.string.local_device')
      })
        .onClick(() => {
          if (this.imageUriArray.length < CommonConstants.MAX_ADD_PIC) {
            this.selectImage();
          } else {
            try {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.add_picture_prompt') });
            } catch (err) {
              hilog.error(DOMAIN, TAG, FORMAT, `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
            }
          }
        })
      createCollaborationServiceMenuItems([CollaborationServiceFilter.ALL], 9)
    }
  }

  // [End menu]

  /*
   * Add default image.
   */
  @Builder
  addDefaultPic() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize($r('app.integer.add_icon_size'))
          .fontColor([$r('sys.color.font_primary')])
        Text(this.imageUriArray.length === 0 ? $r('app.string.add_high_img') :
          (this.imageUriArray.length < CommonConstants.MAX_ADD_PIC ? $r('app.string.continue_add') :
            $r('app.string.image_add')))
          .fontSize($r('app.integer.text_size_body3'))
          .fontColor($r('app.color.add_image_background'))
          .margin({ top: $r('app.integer.comm_padding_margin_mini') })
      }
      .justifyContent(FlexAlign.Center)
      .width(CommonConstants.FULL_PERCENT)
    }
    .borderStyle(BorderStyle.Dashed)
    .borderWidth($r('app.integer.default_border_width'))
    .borderColor($r('app.color.add_image_border_color'))
    .borderRadius($r('app.integer.border_radius3'))
    .width($r('app.integer.add_image_area_size'))
    .height($r('app.integer.add_image_area_size'))
    .margin({
      right: $r('app.integer.add_default_pic_right'),
      bottom: $r('app.integer.add_default_pic_bottom')
    })
    .bindMenu(this.MyTestMenu())
  }
}