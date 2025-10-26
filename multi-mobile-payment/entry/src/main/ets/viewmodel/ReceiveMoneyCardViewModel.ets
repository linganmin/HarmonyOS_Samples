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

export class ReceiveMoneyCardViewModel {
  private receiveMoneyServiceCards: ReceiveMoneyServiceCardItem[] = [];

  constructor() {
    this.receiveMoneyServiceCards.push(new ReceiveMoneyServiceCardItem($r('app.media.receive_money_record'),
      $r('app.string.collection_record'),''));
    this.receiveMoneyServiceCards.push(new ReceiveMoneyServiceCardItem($r('app.media.receive_money_notice'),
      $r('app.string.voice_reminder_for_money'),''));
    this.receiveMoneyServiceCards.push(new ReceiveMoneyServiceCardItem($r('app.media.receive_money_record'),
      $r('app.string.merchant_services'), $r('app.string.free_exchange_for_receiving_money')));
  }

  public getReceiveMoneyServiceCards() {
    return this.receiveMoneyServiceCards;
  }

  public getReceiveMoneyServiceCardsWithNotBrief(): ReceiveMoneyServiceCardItem[] {
    const data: ReceiveMoneyServiceCardItem[] = [...this.receiveMoneyServiceCards];
    data[2].setBrief('');
    return data;
  }
}

export class ReceiveMoneyServiceCardItem {
  /**
   * service card left icon.
   */
  private image: Resource;
  /**
   * service card bottom text.
   */
  private text: Resource;
  /**
   * service card function brief.
   */
  private brief: ResourceStr;

  constructor(image: Resource, text: Resource, brief: ResourceStr) {
    this.image = image;
    this.text = text;
    this.brief = brief;
  }

  public getImage() {
    return this.image;
  }

  public getText() {
    return this.text;
  }

  public getBrief() {
    return this.brief;
  }

  public setBrief(brief: ResourceStr) {
    this.brief = brief;
  }
}