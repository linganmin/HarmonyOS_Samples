/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { Color, Vec4 } from '@kit.ArkGraphics3D';
import { AnimatorOptions } from '@kit.ArkUI';

export class Constants {
  /**
   * Full percent.
   */
  static readonly FULL_PERCENT: string = '100%';

  /**
   * Ninety percent.
   */
  static readonly NINETY_PERCENT: string = '90%';

  /**
   * Thirty percent.
   */
  static readonly THIRTY_PERCENT: string = '30%';

  /**
   * Twenty five percent.
   */
  static readonly TWENTY_FIVE_PERCENT: string = '25%'

  /**
   * Twenty percent.
   */
  static readonly TWENTY_PERCENT: string = '20%';

  /**
   * Percent 13.
   */
  static readonly THIRTEEN_PERCENT: string = '13%';

  /**
   * List space.
   */
  static readonly LIST_SPACE: number = 12;

  /**
   * Helmet node path.
   */
  static readonly HELMET_NODE_PATH: string = 'rootNode_/Scene/node_damagedHelmet_-6514';

  /**
   * Helmet path.
   */
  static readonly HELMET_PATH: string = 'node_damagedHelmet_-6514';

  /**
   * Helmet parent path.
   */
  static readonly HELMET_PARENT_PATH: string = 'Scene/node_damagedHelmet_-6514';

  /**
   * Scene node path.
   */
  static readonly SCENE_NODE_PATH: string = 'rootNode_/Scene';

  /**
   * Cube path.
   */
  static readonly CUBE_PATH: string = 'rootNode_/Unnamed Node 1/Cube';

  /**
   * Camera position z index.
   */
  static readonly CAMERA_POSITION_Z_INDEX: number = 5;

  /**
   * Font weight 500.
   */
  static readonly FONT_WEIGHT_FIVE_HUNDRED: number = 500;

  /**
   * Clear color.
   */
  static readonly CLEAR_COLOR: Color = {
    r: 0,
    g: 0,
    b: 0,
    a: 0.0
  };

  /**
   * Clear color blue.
   */
  static readonly CLEAR_COLOR_BLUE: Color = {
    r: 0,
    g: 0,
    b: 1,
    a: 1
  };

  /**
   * Clear color red.
   */
  static readonly CLEAR_COLOR_RED: Color = {
    r: 1,
    g: 0,
    b: 0,
    a: 1
  };

  /**
   * XAxis value.
   */
  static readonly XAXIS_VALUE: number = 10;

  /**
   * XAxis step.
   */
  static readonly XAXIS_STEP: number = 0.1;

  /**
   * PI RADIAN.
   */
  static readonly PI_RADIAN: number = 180;

  /**
   * Degree 45.
   */
  static readonly DEGREE_FORTY_FIVE: number = 45;

  /**
   * Degree 60.
   */
  static readonly DEGREE_SIXTY: number = 60;

  /**
   * Degree 90.
   */
  static readonly DEGREE_NINETY: number = 90;

  /**
   * Colors
   */
  static readonly COLORS: Color[] = [
    {
      r: 0.8,
      g: 0.1,
      b: 0.2,
      a: 1.0
    },
    {
      r: 0.1,
      g: 0.8,
      b: 0.2,
      a: 1.0
    },
    {
      r: 0.2,
      g: 0.1,
      b: 0.8,
      a: 1.0
    }
  ];

  /**
   * Intensities.
   */
  static readonly INTENSITIES: number[] = [100.0, 500.0, 1000.0, 1500.0, 2000.0];

  /**
   * Half hundred.
   */
  static readonly HALF_HUNDRED: number = 50.0;

  /**
   * Animation option.
   */
  static readonly ANIMATION_OPTION: AnimatorOptions = {
    duration: 2000,
    easing: 'ease',
    delay: 0,
    fill: 'none',
    direction: 'normal',
    iterations: -1,
    begin: 100,
    end: 200
  };

  /**
   * String no.
   */
  static readonly STRING_NO: string = 'no';

  /**
   * String start.
   */
  static readonly STRING_START: string = 'start';

  /**
   * String finish.
   */
  static readonly STRING_FINISH: string = 'finish';

  /**
   * Environment factor.
   */
  static readonly  ENVIRONMENT_FACTOR: Vec4[] = [
    {
      x: 1,
      y: 1,
      z: 1,
      w: 1
    },
    {
      x: 40,
      y: 1,
      z: 1,
      w: 1
    },
    {
      x: 1,
      y: 40,
      z: 1,
      w: 1
    },
    {
      x: 1,
      y: 1,
      z: 40,
      w: 1
    },
  ];

  /**
   * Background color.
   */
  static readonly BACKGROUND_COLOR: string = '#F1F3F5'
}