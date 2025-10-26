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

import { GridManager } from "@hadss/scroll_components";
import { CommonConstants, PhotoSize } from "../common/constants/CommonConstants"
import { PhotoModel } from "../model/PhotoModel";
import PhotoSizeViewModel from "./PhotoSizeViewModel";
import PhotoViewModel from "./PhotoViewModel";

@Observed
export default class PhotoGridViewModel {
  @Track fontBgColor: string[] = ['#fff1f0f0', '#fff1f0f0', '#ffcac8c8'];
  @Track photoSize: PhotoSizeViewModel = new PhotoSizeViewModel();
  @Track columnsTemplate: string = '1fr 1fr 1fr 1fr';
  @Track columnsGap: number = CommonConstants.PHOTO_GRID_COLUMNS_GAP;
  @Track rowsGap: number = CommonConstants.PHOTO_GRID_ROWS_GAP;
  @Track data: PhotoViewModel[] = [];
  gridViewManager?: GridManager;

  constructor(gridViewManager: GridManager, fontBgColor: string[]) {
    this.gridViewManager = gridViewManager;
    this.fontBgColor = fontBgColor;
  }

  loadData() {
    for (let index = 0; index < 192; index++) {
      let photoData: PhotoModel = new PhotoModel();
      if (index % 2 === 0) {
        photoData.photoPath = $r('app.media.album_photo6');
      } else {
        photoData.photoPath = $r('app.media.album_photo5');
      }
      let model = new PhotoViewModel();
      model.updateModel(photoData);
      this.data.push(model);
    }
    this.gridViewManager?.setDataSource(this.data);
  }

  changeMode(mode: PhotoSize) {
    for (let index = 0; index < 3; index++) {
      if (index === mode) {
        this.fontBgColor[index] = '#ffcac8c8';
      } else {
        this.fontBgColor[index] = '#fff1f0f0';
      }
    }

    if (mode === PhotoSize.Small) {
      this.setViewMore();
    } else if (mode === PhotoSize.Medium) {
      this.setViewMed();
    } else {
      this.setViewLess();
    }

    this.gridViewManager?.setViewStyle()
      .columnsTemplate(this.columnsTemplate)
      .columnsGap(this.columnsGap)
      .rowsGap(this.rowsGap)
  }


  setViewLess() {
    this.columnsTemplate = '1fr 1fr 1fr 1fr';
    this.columnsGap = CommonConstants.PHOTO_GRID_COLUMNS_GAP;
    this.rowsGap = CommonConstants.PHOTO_GRID_ROWS_GAP;

    this.photoSize.width = 90;
    this.photoSize.height = 90;
  }

  setViewMed() {
    this.columnsTemplate = '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr';
    this.columnsGap = 0;
    this.rowsGap = 0;

    this.photoSize.width = 40;
    this.photoSize.height = 40;
  }

  setViewMore() {
    this.columnsTemplate = '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr';
    this.columnsGap = 0;
    this.rowsGap = 0;

    this.photoSize.width = 20;
    this.photoSize.height = 20;
  }
}