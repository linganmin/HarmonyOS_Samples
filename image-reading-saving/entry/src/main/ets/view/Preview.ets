/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { LengthUnit } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 0x0000;

interface ImageInfos {
  label: Resource;
  value: string;
};

interface IndexNumber {
  index: number;
  length: number;
};

@Component
struct InfoItem {
  @Prop label: string | Resource;
  @Prop value: string;
  @Prop indexNumber: IndexNumber;

  build() {
    Row() {
      Text(this.label)
        .fontColor('rgba(0,0,0,0.9)')
        .fontWeight(500)
      Text(this.value)
        .fontColor('rgba(0,0,0,0.6)')
        .fontWeight(400)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .border({
      width: {
        bottom: this.indexNumber.index === this.indexNumber.length ? 0 : 1
      },
      color: 'rgba(0,0,0,0.2)'
    })
    .padding({
      top: 13.5,
      bottom: this.indexNumber.index === this.indexNumber.length ? 8 : 13.5
    })
  }
}

@Builder
export function PreviewBuild() {
  Preview();
}

@Component
export struct Preview {
  scroller: Scroller = new Scroller();
  @Consume('pageInfo') pageStack: NavPathStack;
  @State isShow: boolean = false;
  @State pixelMap: PixelMap | undefined = undefined;
  @State isEditable: boolean = false;
  private context: Context = this.getUIContext().getHostContext()!;
  uri: string = '';
  imageSource?: image.ImageSource;
  @State imageInfoNew: ImageInfos[] = [];
  @State bindSheetHeight: number | string = '';
  @State fileId: number = 0;

  getPixelFormatName(format: number): string {
    const keys = Object.keys(image.PixelMapFormat)
      .filter(key => isNaN(Number(key)));

    for (const key of keys) {
      if (image.PixelMapFormat[key] === format) {
        return key;
      }
    }
    return 'UNKNOWN';
  };

  getAlphaTypeName(format: number): string {
    const keys = Object.keys(image.AlphaType)
      .filter(key => isNaN(Number(key)));

    for (const key of keys) {
      if (image.AlphaType[key] === format) {
        return key;
      }
    }
    return 'UNKNOWN';
  };

  aboutToAppear(): void {
    try {
      this.uri = this.pageStack.getParamByName('Preview')[0] as string;
      const file: fs.File = fs.openSync(this.uri, fs.OpenMode.READ_ONLY);
      this.imageSource = image.createImageSource(file.fd);
      this.fileId = file.fd;
      let decodingOptions: image.DecodingOptions = {
        editable: true,
        desiredPixelFormat: 3,
        // Setting to AUTO will decode based on the image resource format, and if the image resource is an HDR resource,
        // it will be decoded as an HDR pixelMap.
        desiredDynamicRange: image.DecodingDynamicRange.AUTO,
      };
      this.imageSource.createPixelMap(decodingOptions).then((data) => {
        this.pixelMap = data;
      });
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'Preview', `Preview error: ${error.code}  msg:${error.message}`);
    }
  };

  aboutToDisappear(): void {
    this.imageSource!.release();
  }

  getStringValue(resName: string): string {
    try {
      return this.context.resourceManager.getStringByNameSync(resName);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'WriteBtn', `WriteBtn error: ${error.code}  msg:${error.message}`);
      return error.message;
    }
  }

  /**
   * Convert ImageInfo object to a recyclable array
   * @param imageInfo Image information data
   * @returns Recyclable array
   */
  getInfoItems(imageInfo: image.ImageInfo): Array<ImageInfos> {
    return [
      {
        label: $r('app.string.width'),
        value: `${imageInfo.size.width} ${this.getStringValue('pixel')}`
      },
      {
        label: $r('app.string.height'),
        value: `${imageInfo.size.height} ${this.getStringValue('pixel')}`
      },
      {
        label: $r('app.string.pixelFormat'),
        value: this.getPixelFormatName(imageInfo.pixelFormat)
      },
      {
        label: $r('app.string.alphaType'),
        value: this.getAlphaTypeName(imageInfo.alphaType)
      },
      {
        label: $r('app.string.picture_format'),
        value: imageInfo.mimeType
      },
      {
        label: $r('app.string.dynamic_range'),
        value: imageInfo.isHdr ? 'HDR' : 'SDR'
      }
    ];
  };

  @Builder
  myBuilder() {
    Scroll(this.scroller) {
      Flex({
        direction: FlexDirection.Column,
      }) {
        ForEach(this.imageInfoNew, (item: ImageInfos, index: number) => {
          InfoItem({
            label: item.label,
            value: item.value,
            indexNumber: {
              index,
              length: this.imageInfoNew.length - 1
            },
          });
        }, (item: string) => item)
      }
      .width('100%')
      .height(this.bindSheetHeight)
      .constraintSize({
        minHeight: 200,
      })
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(16)
    }
    .padding({
      top: 0,
      right: 16,
      bottom: 16,
      left: 16,
    })
    .width('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  build() {
    NavDestination() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center
      }) {
        Image(this.pixelMap).objectFit(ImageFit.Contain)
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.SpaceBetween,
          space: {
            main: { value: 12, unit: LengthUnit.VP }
          }
        }) {
          Button($r('app.string.view_image_information'), { buttonStyle: ButtonStyleMode.NORMAL })
            .bindSheet($$this.isShow, this.myBuilder(), {
              detents: [432, SheetSize.MEDIUM, SheetSize.LARGE],
              backgroundColor: '#e5e5e5',
              title: { title: $r('app.string.picture_information'), subtitle: "" },
              onDisappear: () => {
                this.isShow = false;
              },
              onHeightDidChange: (number) => {
                if (number > 432 && this.imageInfoNew.length > 6) {
                  this.bindSheetHeight = 'calc(100% + 28vp)';
                }
              }
            })
            .width('100%')
            .height(40)
            .onClick(async () => {
              try {
                const imageInfo = await this.imageSource!.getImageInfo();
                this.imageInfoNew = this.getInfoItems(imageInfo);
                this.isShow = true;
              } catch (error) {
                hilog.error(TAG, 'Preview', `failed with err:${error}`);
              }
            });
        }
        .padding(16)
      }
    }
    .title($r('app.string.preview'))
  }
}