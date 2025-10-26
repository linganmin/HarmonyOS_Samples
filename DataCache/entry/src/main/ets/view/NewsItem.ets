/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { ImageType, ResData } from '../common/types/CommonTypes';
import * as Const from '../common/constant/CommonConstants';

@Component
export default struct NewsItem {
  private itemData: ResData = {} as ResData;

  build() {
    Column() {
      Row() {
        Image($r('app.media.news'))
          .height(Const.TITLE_TEXT_HEIGHT)
          .margin({
            top: Const.TITLE_TEXT_MARGIN_TOP,
            left: Const.TITLE_IMAGE_MARGIN_LEFT
          })
          .objectFit(ImageFit.Contain)
        Text(this.itemData.title)
          .fontSize(Const.TITLE_TEXT_FONT_SIZE)
          .fontColor($r('app.color.fontColor_text'))
          .height(Const.TITLE_TEXT_HEIGHT)
          .width(Const.TITLE_TEXT_WIDTH)
          .maxLines(Const.TITLE_TEXT_MAX_LINES)
          .margin({ left: Const.TITLE_TEXT_MARGIN_LEFT, top: Const.TITLE_TEXT_MARGIN_TOP })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(Const.TITLE_TEXT_FONT_WEIGHT)
      }

      Text(this.itemData.content)
        .fontSize(Const.CONTENT_FONT_SIZE)
        .fontColor($r('app.color.fontColor_text'))
        .width(Const.CONTENT_WIDTH)
        .lineHeight(Const.CONTENT_LINE_HEIGHT)
        .maxLines(Const.CONTENT_MAX_LINES)
        .margin({ left: Const.CONTENT_MARGIN_LEFT, top: Const.CONTENT_MARGIN_TOP })
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Grid() {
        ForEach(this.itemData.imagesUrl, (itemImg: ImageType) => {
          GridItem() {
            this.imageLoader(itemImg)
          }
        }, (itemImg: ImageType, index?: number) => JSON.stringify(itemImg) + index)
      }
      .columnsTemplate('1fr '.repeat(this.itemData.imagesUrl?.length ?? 0))
      .columnsGap(Const.GRID_COLUMNS_GAP)
      .rowsTemplate(Const.GRID_ROWS_TEMPLATE)
      .width(Const.GRID_WIDTH)
      .height(Const.GRID_HEIGHT)
      .margin({ left: Const.GRID_MARGIN_LEFT, top: Const.GRID_MARGIN_TOP,
        right: Const.GRID_MARGIN_LEFT })

      Text(this.itemData.source)
        .fontSize(Const.SOURCE_FONT_SIZE)
        .fontColor($r('app.color.fontColor_text2'))
        .width(Const.SOURCE_WIDTH)
        .maxLines(Const.SOURCE_MAX_LINES)
        .margin({ left: Const.SOURCE_MARGIN_LEFT, top: Const.SOURCE_MARGIN_TOP, bottom: Const.SOURCE_MARGIN_TOP })
        .textOverflow({ overflow: TextOverflow.None })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  imageLoader(img: ImageType) {
    Image(img.url)
      .objectFit(ImageFit.Cover)
      .borderRadius(Const.GRID_IMAGE_BORDER_RADIUS)
  }
}