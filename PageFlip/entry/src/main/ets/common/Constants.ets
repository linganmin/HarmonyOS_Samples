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


export class Constants {
  /**
   * Page flip zero.
   */
  static readonly PAGE_FLIP_ZERO: number = 0;

  /**
   * Page flip one.
   */
  static readonly PAGE_FLIP_ONE: number = 1;

  /**
   * Page flip two.
   */
  static readonly PAGE_FLIP_TWO: number = 2;

  /**
   * Page flip three.
   */
  static readonly PAGE_FLIP_THREE: number = 3;

  /**
   * Flip page z index.
   */
  static readonly FLIP_PAGE_Z_INDEX: number = 2;

  /**
   * Page flip to ast duration.
   */
  static readonly PAGE_FLIP_TO_AST_DURATION: number = 300;

  /**
   * Window width.
   */
  static readonly WINDOW_WIDTH: number = 600;

  /**
   * Page flip page_count.
   */
  static readonly PAGE_FLIP_PAGE_COUNT: number = 1;

  /**
   * Page flip page start.
   */
  static readonly PAGE_FLIP_PAGE_START: number = 1;

  /**
   * Page flip page end.
   */
  static readonly PAGE_FLIP_PAGE_END: number = 13;

  /**
   * Page flip right flip offset x.
   */
  static readonly PAGE_FLIP_RIGHT_FLIP_OFFSETX: number = 10;

  /**
   * Page flip left flip offset x.
   */
  static readonly PAGE_FLIP_LEFT_FLIP_OFFSETX: number = -10;

  /**
   * Page flip cache count.
   */
  static readonly PAGE_FLIP_CACHE_COUNT: number = 3;

  /**
   * Page flip resource.
   */
  static readonly PAGE_FLIP_RESOURCE: string = 'app.string.pageflip_content';

  /**
   * Sixty percent.
   */
  static readonly SIXTY_PERCENT: number = 0.6;

  /**
   * Distance fraction.
   */
  static readonly DISTANCE_FRACTION: number = 20;

  /**
   * Flip x diff.
   */
  static readonly FLIP_X_DIFF: number = -100;

  /**
   * Timer duration.
   */
  static readonly TIMER_DURATION: number = 8.3;
}

/**
 * Emulation flip draw position.
 */
export enum DrawPosition {
  DP_NONE = 1,
  DP_TOP = 2,
  DP_BOTTOM = 3,
  DP_MIDDLE = 4
}

/**
 * Emulation flip draw state.
 */
export enum DrawState {
  DS_NONE = 1,
  DS_MOVING = 2,
  DS_RELEASE = 3
}

/**
 * Direction of movement.
 */
export enum MoveForward {
  MF_NONE = 0,
  MF_FORWARD = 1,
  MF_BACKWARD = 2
}

/**
 * Page flip type.
 */
export enum PageFlipType {
  PFT_UP_DOWN = 0,
  PFT_COVER = 1,
  PFT_EMULATION = 2
}