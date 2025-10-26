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
import { CommonConstants } from '../common/CommonConstants';
import { ImageInfo } from '../model/ContentInfo';
import { SelectedDataSource } from '../model/SelectedDataSource';
import { DataUtils } from '../utils/DataUtils';
import { FileUtils } from '../utils/FileUtils';
import Logger from '../utils/Logger';
import { UIUtils } from '../utils/UIUtils';

@Component
export struct ListAddPictureView {
  @StorageLink(CommonConstants.KEY_IMAGE_INFO) imageInfoArr: Array<ImageInfo> = [];
  private readonly tag: string = 'ListAddPictureView';
  listScroller: ListScroller = new ListScroller();
  swiperController: SwiperController | undefined = undefined;
  @Prop itemSize: Resource;
  @Link currentIndex: number;
  @Link selectedData: SelectedDataSource;

  build() {
    Row() {
      List({ scroller: this.listScroller, space: DataUtils.fromResToNumber($r('app.float.space_8')) }) {
        this.setAddItem();
        LazyForEach(this.selectedData, (item: PixelMap) => {
          this.setPictureItem(item);
        });
      }
      .cachedCount(2)
      .width($r('app.string.full_screen'))
      .height(this.itemSize)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .width($r('app.string.full_screen'))
  }

  @Builder
  setAddItem() {
    ListItem() {
      Stack() {
        Button($r('sys.media.ohos_ic_public_add'), { type: ButtonType.Normal, stateEffect: true })
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .width(this.itemSize)
          .height(this.itemSize)
        Image($r('sys.media.ohos_ic_public_add'))
          .width($r('app.float.rounded_size_20'))
          .height($r('app.float.rounded_size_20'))
          .fillColor($r('sys.color.ohos_id_color_component_normal'))
      }.align(Alignment.Center)
    }.onClick(() => {
      // Show picker
      UIUtils.showPickerView(this.getUIContext(), this.imageInfoArr.length, async (uriArr: string[]) => {
        Logger.debug(this.tag, `picker view uriArr: ${uriArr.length}`);
        while (uriArr.length > 0) {
          let uri = uriArr.pop();
          if (uri === undefined) {
            continue;
          }
          FileUtils.copyFileToDestination(uri, DataUtils.context.distributedFilesDir);
          let imageInfo: ImageInfo | undefined = FileUtils.createPixelMap(uri);
          if (imageInfo) {
            this.imageInfoArr.unshift(imageInfo);
            this.selectedData.unshiftData(imageInfo.imagePixelMap);
          }
        }
        if (this.swiperController !== undefined) {
          this.currentIndex = 0;
          this.swiperController?.changeIndex(this.currentIndex);
        }
      });
    })
  }

  @Builder
  setPictureItem(item: PixelMap) {
    ListItem() {
      Stack() {
        Image(item)
          .objectFit(ImageFit.Cover)
          .width(this.itemSize)
          .height(this.itemSize)
          .border({
            width: this.currentIndex === -1 ? $r('app.float.zero') : $r('app.float.board_width'),
            color: this.currentIndex === this.selectedData.getItemIndex(item) ?
            $r('sys.color.ohos_id_color_emphasize') : Color.White,
            style: BorderStyle.Solid
          })
          .onClick(() => {
            if (this.swiperController !== undefined) {
              this.currentIndex = this.selectedData.getItemIndex(item);
              this.swiperController.changeIndex(this.currentIndex)
            }
          })
        Image($r('app.media.close_mark_circle_fill'))
          .width($r('app.float.rounded_size_22'))
          .height($r('app.float.rounded_size_22'))
          .margin({ top: $r('app.float.margin_4'), right: $r('app.float.margin_4') })
          .onClick(() => {
            // Delete selected picture
            let index = this.selectedData.getItemIndex(item);
            this.imageInfoArr.splice(index, 1);
            this.selectedData.deleteData(index);
            if (this.swiperController !== undefined) {
              this.currentIndex = Math.max(0, index - 1);
            }
          })
      }
      .width(this.itemSize)
      .height(this.itemSize)
      .align(Alignment.TopEnd)
    }
  }
}