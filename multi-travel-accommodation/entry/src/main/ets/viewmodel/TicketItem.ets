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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext!.getHostContext()!;

export class TicketItem {
  /**
   * The date of the ticket.
   */
  public date: string;
  /**
   * The startTime of the ticket.
   */
  public startTime: string;
  /**
   * The arriveTime of the ticket.
   */
  public arriveTime: string;
  /**
   * The startPoint of the ticket.
   */
  public startPoint: Resource;
  /**
   * The arrivePoint of the ticket.
   */
  public arrivePoint: Resource;
  /**
   * The transportName of the ticket.
   */
  public transportName: Resource;
  /**
   * The tranTrip of the ticket.
   */
  public tranTrip: string;
  /**
   * The totalDuration of the ticket.
   */
  public totalDuration: string;
  /**
   * The money of the ticket.
   */
  public money: number;
  /**
   * The secondClassNumber of the ticket.
   */
  public secondClassNumber: number;
  /**
   * The firstClassNumber of the ticket.
   */
  public firstClassNumber: number;
  /**
   * The businessNumber of the ticket.
   */
  public businessNumber: number;

  /**
   * constructor method.
   */
  constructor(date: string, startTime: string, arriveTime: string, startPoint: Resource,
    arrivePoint: Resource, transportName: Resource, tranTrip: string, totalDuration: string, money: number,
    secondClassNumber: number, firstClassNumber: number, businessNumber: number) {
    this.date = date;
    this.startTime = startTime;
    this.arriveTime = arriveTime;
    this.startPoint = startPoint;
    this.arrivePoint = arrivePoint;
    this.transportName = transportName;
    this.tranTrip = tranTrip;
    this.totalDuration = totalDuration;
    this.money = money;
    this.secondClassNumber = secondClassNumber;
    this.firstClassNumber = firstClassNumber;
    this.businessNumber = businessNumber;
  }

  /**
   * Method for determining whether there is a ticket.
   */
  getWetherHasTicket(): boolean {
    if (this.secondClassNumber + this.firstClassNumber + this.businessNumber === 0) {
      return false;
    }
    return true;
  }

  /**
   * Method for determining whether it is a train.
   */
  getWetherTrain(): boolean {
    try {
      let train: string = context.resourceManager.getStringSync($r('app.string.train').id);
      let transportName: string = context.resourceManager.getStringSync(this.transportName.id);
      if (transportName === train) {
        return true;
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x00, 'TicketItem', `getStringSync failed, code = ${err.code}, message = ${err.message}`);
    }

    return false;
  }
}