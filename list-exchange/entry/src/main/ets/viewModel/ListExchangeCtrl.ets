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

import curves from '@ohos.curves';
import { logger } from '../utils/Logger'
import { CommonConstants } from '../constants/CommonConstants';
import { ListItemModifier } from './AttributeModifier';

/**
 * Operation Status Enumeration
 */
enum OperationStatus {
  IDLE,
  PRESSING,
  MOVING,
  DROPPING,
  DELETE
}

/**
 * List item toggle control
 */
@Observed
export class ListExchangeCtrl<T> {
  private deductionData: T[];
  private modifier: ListItemModifier[];
  private dragRefOffset: number = 0;
  offsetY: number = 0;
  state: OperationStatus = OperationStatus.IDLE;
  UIContext: UIContext

  constructor(deductionData: T[], UIContext: UIContext) {
    this.deductionData = deductionData;
    this.modifier = [];
    deductionData.forEach(() => {
      this.modifier.push(new ListItemModifier());
    })
    this.UIContext = UIContext
  }

  /**
   * Gets the properties of the ListItem
   * @param item
   * @returns Returns the custom property object
   */
  getModifier(item: T): ListItemModifier {
    const index: number = this.deductionData.indexOf(item);
    return this.modifier[index];
  }

  /**
   * List long press function
   * @param item
   */
  onLongPress(item: T): void {
    const index: number = this.deductionData.indexOf(item);
    this.dragRefOffset = 0;
    this.UIContext.animateTo({ curve: Curve.Friction, duration: CommonConstants.ANIMATE_DURATION }, () => {
      this.state = OperationStatus.PRESSING;
      this.modifier[index].hasShadow = true;
      this.modifier[index].scale = 1.04;
    })
  }

  /**
   * ListItem move function
   * @param item
   * @param offsetY
   */
  onMove(item: T, offsetY: number): void {
    // Get the index of the current component
    const index: number = this.deductionData.indexOf(item);
    this.offsetY = offsetY - this.dragRefOffset;
    this.modifier[index].offsetY = this.offsetY;
    const direction: number = this.offsetY > 0 ? 1 : -1;
    // Animation of zooming out and restoring the covered sub-component when dragging is triggered
    const curveValue: ICurve = curves.initCurve(Curve.Sharp);
    const value: number = curveValue.interpolate(Math.abs(this.offsetY) / CommonConstants.ITEM_HEIGHT);
    // Calculate Scaling
    const shrinkScale: number = 1 - value / 10;
    if (index < this.modifier.length - 1) {
      this.modifier[index + 1].scale = direction > 0 ? shrinkScale : 1;
    }
    if (index > 0) {
      this.modifier[index - 1].scale = direction > 0 ? 1 : shrinkScale;
    }
    // Toggle Actions for List Items
    if (Math.abs(this.offsetY) > CommonConstants.ITEM_HEIGHT / 2) {
      this.UIContext.animateTo({ curve: Curve.Friction, duration: CommonConstants.ANIMATE_DURATION }, () => {
        this.offsetY -= direction * CommonConstants.ITEM_HEIGHT;
        this.dragRefOffset += direction * CommonConstants.ITEM_HEIGHT;
        this.modifier[index].offsetY = this.offsetY;
        this.changeItem(index, index + direction);
      })
    }
  }

  /**
   * ListItem place function
   * @param item
   */
  onDrop(item: T): void {
    logger.info(`onDrop start`);
    const index: number = this.deductionData.indexOf(item);
    this.dragRefOffset = 0;
    this.offsetY = 0;
    AppStorage.setOrCreate('isLongPress', false);

    /**
     * Resumes the zoomed-out subcomponent that is being dragged and provides the animation
     * Construct an interpolator spring curve object
     * Initial velocity is 0,Quality is 1,Stiffness is 400,Damping is 38
     */
    this.UIContext.animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
      this.state = OperationStatus.DROPPING;
      if (index < this.modifier.length - 1) {
        this.modifier[index + 1].scale = 1;
      }
      if (index > 0) {
        this.modifier[index - 1].scale = 1;
      }
    })

    /**
     * Restores the zoom-in and shadow effects of the dragged subcomponent and provides animations
     * Construct an interpolator spring curve object
     * Initial velocity is 14,Quality is 1,Stiffness is 170,Damping is 17
     */
    this.UIContext.animateTo({ curve: curves.interpolatingSpring(14, 1, 170, 17) }, () => {
      this.state = OperationStatus.IDLE;
      this.modifier[index].hasShadow = false;
      this.modifier[index].scale = 1;
      this.modifier[index].offsetY = 0;
    })
    logger.info(`onDrop end`);
  }

  /**
   * ListItem Swap Position
   * @param index
   * @param newIndex
   */
  changeItem(index: number, newIndex: number): void {
    const tmp: T[] = this.deductionData.splice(index, 1);
    this.deductionData.splice(newIndex, 0, tmp[0]);
    const tmp2: ListItemModifier[] = this.modifier.splice(index, 1);
    this.modifier.splice(newIndex, 0, tmp2[0]);
  }

  /**
   * Delete List Item
   * @param item
   */
  deleteItem(item: T): void {
    const index: number = this.deductionData.indexOf(item);
    this.dragRefOffset = 0;
    this.UIContext.animateTo({
      curve: Curve.Friction, duration: CommonConstants.ANIMATE_DURATION, onFinish: () => {
        this.UIContext.animateTo({
          curve: Curve.Friction, duration: CommonConstants.ANIMATE_DURATION, onFinish: () => {
            this.state = OperationStatus.IDLE;
          }
        }, () => {
          this.modifier.splice(index, 1);
          this.deductionData.splice(index, 1);
        })
      }
    }, () => {
      this.state = OperationStatus.DELETE;
      this.modifier[index].offsetX = CommonConstants.LIST_ITEM_LEFT_OFFSET;
      this.modifier[index].opacity = 0;
    })
  }
}