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

import { BreakpointConstants } from '../constants/BreakpointConstants';
import { EditorComponent } from '../view/EditorComponent';
import { CommonConstants } from '../constants/CommonConstants';
import { BottomToolbar } from '../view/BottomToolbar';
import { TopArea } from '../view/TopArea';
import { AddPic } from '../view/AddPic';

@Entry
@Component
struct Home {
  // Whether to display the current information list.
  @StorageLink('isShowLocalInfo') isShowLocalInfo: boolean = false;
  // Whether to display the information about adding a local device.
  @StorageLink('isAddLocalInfo') isAddLocalInfo: boolean = false;
  // Display the current location information after selecting.
  @StorageLink('selectLocalInfo') selectLocalInfo: string = '';
  // Height of the status bar.
  @StorageLink('statusBarHeight') statusBarHeight: number = 0;
  // Whether to display the soft keyboard.
  @State isKeyboard: boolean = false;

  changeFocus(isAllClose: boolean): void {
    if (isAllClose) {
      // Soft keyboard loses focus.
      focusControl.requestFocus(CommonConstants.TEXT_ID);
    } else {
      if (this.isKeyboard) {
        // Obtaining the Focus of the Soft Keyboard.
        focusControl.requestFocus(CommonConstants.TITLE_ID);
      } else {
        // Soft keyboard loses focus.
        focusControl.requestFocus(CommonConstants.TEXT_ID);
      }
    }
  }

  build() {
    GridRow({
      columns: {
        sm: BreakpointConstants.GRID_ROW_COLUMNS[0],
        md: BreakpointConstants.GRID_ROW_COLUMNS[1],
        lg: BreakpointConstants.GRID_ROW_COLUMNS[2]
      }
    }) {
      GridCol({
        span: {
          sm: BreakpointConstants.GRID_COLUMN_SPANS[0],
          md: BreakpointConstants.GRID_COLUMN_SPANS[1],
          lg: BreakpointConstants.GRID_COLUMN_SPANS[2]
        }
      }) {
        Stack({ alignContent: Alignment.Bottom }) {
          Flex({ direction: FlexDirection.Column }) {
            // Top area.
            TopArea()
            // Focus-obtaining area.
            Text('')
              .focusOnTouch(true)
              .focusable(true)
              .id(CommonConstants.TEXT_ID)
            // Image area.
            AddPic()
            // Text editing area.
            EditorComponent({
              isKeyboard: this.isKeyboard,
              isShowLocalInfo: this.isShowLocalInfo
            })
            // Bottom zone.
            BottomToolbar({
              isAddLocalInfo: this.isAddLocalInfo,
              selectLocalInfo: this.selectLocalInfo,
              isShowLocalInfo: this.isShowLocalInfo,
              isKeyboard: this.isKeyboard,
              changeFocus: (isAllClose: boolean) => {
                this.changeFocus(isAllClose);
              }
            })
          }
        }
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .padding({ top: this.statusBarHeight })
      }
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
  }
}