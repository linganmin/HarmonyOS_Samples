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

import { TabType } from '../types/CommonTypes';

export const TOTAL_COUNT = 20;
export const IMAGE_BASE64_PREFIX = 'data:image/png;base64,';
export const PAGE_SIZE: number = 5;
export const FULL_WIDTH: string = '100%';
export const FULL_HEIGHT: string = '100%';
export const TAB_HEIGHT: string = '7.2%';
export const TAB_PADDING: string  = '2.2%';
export const TAB_Z_INDEX: number = 9;
export const TAB_FONT_SIZE: number = 18;
export const TAB_ACTIVE_FONT_SIZE: number = 24;
export const TAB_FONT_WEIGHT: number = 400;
export const TAB_ACTIVE_FONT_WEIGHT: number = 600;
export const CUSTOM_LAYOUT_HEIGHT: number = 70;

export const CLEAR_HEIGHT = 30;
export const CLEAR_FONT_SIZE = 16;
export const CLEAR_FONT_WEIGHT = 400;
export const CLEAR_PADDING = 16;
export const CLEAR_BORDER_WIDTH = 1;

export const TAB_TYPES: Array<TabType> = [
  { id: 0, name: $r('app.string.homepage') },
  { id: 1, name: $r('app.string.recommendation') }
];

export const enum PageState {
  LOADING = 0,
  SUCCESS = 1,
  FAIL = 2
}

export const LIST_DIVIDER_STROKE_WIDTH: number = 0.5;
export const LIST_GET_TAB_DATA_TYPE_ONE: number = 1;
export const LIST_ITEM_BORDER_RADIUS: number = 16;
export const LIST_NONE_IMAGE_SIZE: number = 120;
export const LIST_NONE_TEXT_OPACITY: number = 0.6;
export const LIST_NONE_TEXT_SIZE: number = 16;
export const LIST_NONE_TEXT_MARGIN: number = 12;
export const LIST_ITEM_MARGIN_TOP: string = '2.8%';
export const LIST_MARGIN_LEFT: string = '3.3%';
export const LIST_MARGIN_RIGHT: string = '3.3%';
export const LIST_ITEM_HEIGHT: string = '32%';
export const LIST_ITEM_MIN_HEIGHT = 170;
export const LIST_WIDTH: string =  '93.3%';
export const TITLE_TEXT_MAX_LINES: number = 1;
export const TITLE_TEXT_FONT_SIZE: number = 16;
export const TITLE_TEXT_FONT_WEIGHT: number = 700;
export const TITLE_TEXT_MARGIN_LEFT = 10;
export const TITLE_TEXT_MARGIN_TOP = 16;
export const TITLE_TEXT_HEIGHT = 20;
export const TITLE_TEXT_WIDTH: string = '78.6%';
export const TITLE_IMAGE_MARGIN_LEFT: string = '3.5%';
export const TITLE_IMAGE_MARGIN_TOP: string = '7.9%';
export const TITLE_IMAGE_HEIGHT: string = '8.9%';
export const TITLE_IMAGE_WIDTH: string = '10.9%';

export const CONTENT_WIDTH: string = '93%';
export const CONTENT_HEIGHT: string = '16.8%';
export const CONTENT_LINE_HEIGHT = 20;
export const CONTENT_MARGIN_LEFT: string = '3.5%';
export const CONTENT_MARGIN_TOP = 10;
export const CONTENT_MAX_LINES: number = 2;
export const CONTENT_FONT_SIZE: number = 14;

export const SOURCE_MAX_LINES: number = 1;
export const SOURCE_FONT_SIZE: number = 12;
export const SOURCE_MARGIN_LEFT: string = '3.5%';
export const SOURCE_MARGIN_TOP = 10;
export const SOURCE_HEIGHT: string = '7.2%';
export const SOURCE_WIDTH: string = '93%';

export const GRID_MARGIN_LEFT: string = '3.5%';
export const GRID_MARGIN_RIGHT = 14;
export const GRID_MARGIN_TOP: string = '5.1%';
export const GRID_WIDTH: string = '93%';
export const GRID_HEIGHT = 54;
export const GRID_ASPECT_RATIO: number = 4;
export const GRID_COLUMNS_GAP: number = 5;
export const GRID_ROWS_TEMPLATE: string = '1fr';
export const GRID_IMAGE_BORDER_RADIUS: number = 8;

export const REFRESH_MARGIN_LEFT: string = '40%';
export const REFRESH_TEXT_MARGIN_BOTTOM: number = 1;
export const REFRESH_TEXT_MARGIN_LEFT: number = 7;
export const REFRESH_TEXT_FONT_SIZE: number = 17;
export const REFRESH_IMAGE_WIDTH: number = 18;
export const REFRESH_IMAGE_HEIGHT: number = 18;

export const NO_MORE_NORMAL_PADDING: number = 8;
export const NO_MORE_TITLE_FONT: string = '16fp';

export const REFRESH_DELAY_PULL_DOWN_REFRESH: number = 50;
export const REFRESH_CLOSE_PULL_DOWN_REFRESH_TIME: number = 150;
export const REFRESH_DELAY_SHRINK_ANIMATION_TIME: number = 500;

export const DELAY_TIME: number = 1000;
export const Y_OFF_SET_COEFFICIENT: number = 0.1;
export const DELAY_ANIMATION_DURATION: number = 300;
export const ANIMATION_DURATION: number = 2000;
export const enum RefreshState {
  DROPDOWN = 0,
  RELEASE = 1,
  REFRESH = 2,
  SUCCESS = 3,
  FAIL = 4
}