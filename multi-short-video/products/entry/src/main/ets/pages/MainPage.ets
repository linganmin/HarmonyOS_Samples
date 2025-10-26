/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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
import { BreakpointConstants } from '@ohos/commons';
import { Home } from '@ohos/home';

@Entry
@Component
struct ImagePickerPage {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;

  build() {
    GridRow({
      columns: {
        sm: BreakpointConstants.GRID_ROW_COLUMNS[0],
        md: BreakpointConstants.GRID_ROW_COLUMNS[1],
        lg: BreakpointConstants.GRID_ROW_COLUMNS[2]
      }
    }) {
      GridCol({ span: {
        sm: BreakpointConstants.GRID_COLUMN_SPANS[1],
        md: BreakpointConstants.GRID_COLUMN_SPANS[2],
        lg: BreakpointConstants.GRID_COLUMN_SPANS[2]
      } }) {
        Home()
      }

      if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
        GridCol({ span: {
          sm: BreakpointConstants.GRID_COLUMN_SPANS[0],
          md: BreakpointConstants.GRID_COLUMN_SPANS[0],
          lg: BreakpointConstants.GRID_COLUMN_SPANS[1]
        } }) {
          Image($r('app.media.comment2'))
            .objectFit(ImageFit.Contain)
        }
        .backgroundColor($r('app.color.comment_background'))
      }
    }
  }
}