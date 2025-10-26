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

import { GridManager, NodeItem, RecyclerView } from '@hadss/scroll_components';
import { Utils } from '../common/util/Utils';
import PhotoGridViewModel from '../viewModel/PhotoGridViewModel';
import PhotoSizeViewModel from '../viewModel/PhotoSizeViewModel';
import PhotoViewModel from '../viewModel/PhotoViewModel';
import { buildPhoto } from './PhotoCellComponent';
import { PhotoSize } from '../common/constants/CommonConstants';

// [Start pages_reuse]
@Component
export default struct PhotoGridComponent {
  // [StartExclude pages_reuse]
  @State fontBgColor: string[] = ['#fff1f0f0', '#fff1f0f0', '#ffcac8c8'];
  gridViewManager: GridViewManager =
    new GridViewManager({ defaultNodeItem: "photoContainer", context: this.getUIContext() });
  @State viewModel: PhotoGridViewModel = new PhotoGridViewModel(this.gridViewManager, this.fontBgColor);
  // [EndExclude pages_reuse]

  // [Start set_column]
  // [Start set_direction]
  aboutToAppear(): void {
    // [StartExclude set_column]
    // [StartExclude pages_reuse]
    // [StartExclude set_direction]
    this.gridViewManager.photoSize = this.viewModel.photoSize;
    // [EndExclude pages_reuse]
    if (Utils.getInstance().nodePool) {
      // register recycle pool.
      this.gridViewManager.registerRecyclePool(Utils.getInstance().nodePool!);
    } else {
      Utils.getInstance().nodePool = this.gridViewManager.getRecyclePool();
    }
    // [StartExclude pages_reuse]
    // [EndExclude set_column]
    this.gridViewManager.setViewStyle()
      .columnsTemplate(this.viewModel.columnsTemplate);
    // [StartExclude set_column]
    // [EndExclude set_direction]
    this.gridViewManager.setViewStyle()
      .layoutDirection(GridDirection.Row);
    // [StartExclude set_direction]
    this.gridViewManager.setViewStyle()
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);

    this.gridViewManager.setViewStyle()
      .columnsGap(this.viewModel.columnsGap)
      .rowsGap(this.viewModel.rowsGap)
      .scrollBar(BarState.Off)
      .width("100%")
      .height("100%");

    this.gridViewManager.setItemViewStyle((gridItem) => {
      gridItem({ style: GridItemStyle.PLAIN })
    });

    // [EndExclude pages_reuse]
    // register template after register recycle pool.
    this.gridViewManager.registerNodeItem('photoContainer', wrapBuilder(buildPhoto));
    // [StartExclude pages_reuse]
    this.viewModel.loadData();
    // [EndExclude pages_reuse]
    // [EndExclude set_column]
    // [EndExclude set_direction]
  }
  // [End set_direction]
  // [End set_column]

  // [StartExclude pages_reuse]
  @Styles
  btnStyle() {
    .width(50)
    .height(32)
    .borderRadius(16)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      RecyclerView({
        viewManager: this.gridViewManager
      })

      Stack() {
        Row({ space: 20 }) {
          Text('S')
            .btnStyle()
            .backgroundColor(this.fontBgColor[0])
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.viewModel.changeMode(PhotoSize.Small);
            })

          Text('M')
            .btnStyle()
            .backgroundColor(this.fontBgColor[1])
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.viewModel.changeMode(PhotoSize.Medium);
            })

          Text('L')
            .btnStyle()
            .backgroundColor(this.fontBgColor[2])
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.viewModel.changeMode(PhotoSize.Large);
            })
        }
        .justifyContent(FlexAlign.SpaceAround)
        .width(200)
        .height(36)
        .borderRadius(18)
        .backgroundColor("#fff1f0f0")
        .opacity(0.9)
        .margin({
          bottom: 20
        })
      }
    }
    .width("100%")
    .height("100%")
  }
  // [EndExclude pages_reuse]
}
// [End pages_reuse]

class GridViewManager extends GridManager {
  private _photoSize: PhotoSizeViewModel = new PhotoSizeViewModel();

  public set photoSize(value: PhotoSizeViewModel) {
    this._photoSize = value;
  }

  onWillCreateItem(index: number, data: PhotoViewModel): NodeItem<PhotoCellData> | null {
    let node: NodeItem<PhotoCellData> | null = this.dequeueReusableNodeByType('photoContainer');
    node?.setData({ photo: data, photoSize: this._photoSize });
    return node;
  }
}

export interface PhotoCellData {
  photo: PhotoViewModel;
  photoSize: PhotoSizeViewModel;
}