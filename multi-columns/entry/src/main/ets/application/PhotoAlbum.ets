/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { PhotoContent } from '../common/PhotoContent';
import { PhotoSideBar } from '../common/PhotoSideBar';
import { LengthMetrics, window } from '@kit.ArkUI';
import { getBottom, getLeft, getRight, getTop } from '../common/Constants';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let storage = uiContext?.getSharedLocalStorage();

@Entry(storage)
@Component
struct PhotoAlbum {
  @State localPadding: LocalizedPadding = { top: LengthMetrics.vp(0), start: LengthMetrics.vp(0) };
  @StorageLink('cutout') @Watch('cutoutChange') avoidAreas: window.AvoidAreaOptions | undefined = undefined;
  @StorageLink('windowHeight') windowHeight: number = 0;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @State sideBarStatus: boolean = true;
  @LocalStorageLink('currentBreakPoint') currentBreakPoint: string = 'sm';

  cutoutChange(): void {
    let topPX = getTop(this.avoidAreas);
    let rightPX = getRight(this.avoidAreas, this.windowWidth);
    let bottomPX = getBottom(this.avoidAreas, this.windowHeight);
    let leftPX = getLeft(this.avoidAreas);
    this.localPadding = {
      top: LengthMetrics.px(topPX),
      end: LengthMetrics.px(rightPX),
      bottom: LengthMetrics.px(bottomPX),
      start: LengthMetrics.px(leftPX)
    }
  }

  build() {
    Column() {
      GridRow() {
        GridCol({ span: { sm: 12, md: 12, lg: 12 } }) {
          SideBarContainer(SideBarContainerType.AUTO) {
            Column() {
              PhotoSideBar()
                .margin({ top: AppStorage.get<number>('statusBarHeight') as number + 44 })
            }
            .backgroundColor($r('sys.color.gray_01'))

            Column() {
              PhotoContent({ sideBarStatus: $sideBarStatus })
            }
          }
          .controlButton({
            left: 24,
            top: AppStorage.get<number>('statusBarHeight') as number + 14,
            width: 24,
            height: 24
          })
          .onChange((value: boolean) => {
            this.sideBarStatus = value;
          })
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}