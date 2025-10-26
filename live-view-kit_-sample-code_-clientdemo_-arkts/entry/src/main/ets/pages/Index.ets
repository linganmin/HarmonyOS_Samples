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

import { ContextUtil } from '../utils/ContextUtil';

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();
  @Provide('timeOutIdFlight') timeOutIdFlight: number | undefined = undefined;
  @Provide('isProcessingFlight') isProcessingFlight: boolean = false;
  @Provide('timeOutIdDelivery') timeOutIdDelivery: number | undefined = undefined;
  @Provide('isProcessingDelivery') isProcessingDelivery: boolean = false;
  @Provide('timeOutIdScore') timeOutIdScore: number | undefined = undefined;
  @Provide('isProcessingScore') isProcessingScore: boolean = false;
  @Provide('timeOutIdNavigation') timeOutIdNavigation: number | undefined = undefined;
  @Provide('isProcessingNavigation') isProcessingNavigation: boolean = false;
  @Provide('timeOutIdPickUp') timeOutIdPickUp: number | undefined = undefined;
  @Provide('isProcessingPickUp') isProcessingPickUp: boolean = false;
  @Provide('timeOutIdQueue') timeOutIdQueue: number | undefined = undefined;
  @Provide('isProcessingQueue') isProcessingQueue: boolean = false;
  @Provide('timeOutIdRent') timeOutIdRent: number | undefined = undefined;
  @Provide('isProcessingRent') isProcessingRent: boolean = false;
  @Provide('timeOutIdTaxi') timeOutIdTaxi: number | undefined = undefined;
  @Provide('isProcessingTaxi') isProcessingTaxi: boolean = false;
  @Provide('timeOutIdTrain') timeOutIdTrain: number | undefined = undefined;
  @Provide('isProcessingTrain') isProcessingTrain: boolean = false;
  @Provide('timeOutIdWork') timeOutIdWork: number | undefined = undefined;
  @Provide('isProcessingWork') isProcessingWork: boolean = false;

  onPageShow(): void {
    if (ContextUtil.wantUrl) {
      this.pathStack.pushPath({
        name: ContextUtil.wantUrl
      });
      ContextUtil.wantUrl = undefined;
    }
  }

  @Builder
  featureButton(buttonText: Resource, buttonImage: Resource, callbackOnClick: () => void) {
    Button({ type: ButtonType.Normal }) {
      Row() {
        Column() {
          Text(buttonText)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
          Rect()
            .radius(1)
            .fill('#0A59F7')
            .height(2)
            .width(32)
        }
        .width(120)
        .height('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 24, top: 24 })

        Blank()
        Image(buttonImage)
          .width('auto')
          .height(128)
          .padding({ top: 6, left: 16 })
          .margin({ right: "3%" })
      }
      .width('100%')
      .height(140)
    }
    .width('90%')
    .height(140)
    .margin({ top: '5%' })
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .onClick(callbackOnClick)
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate('PathStack', this.pathStack);
  }

  build() {
    Navigation(this.pathStack) {
      Scroll() {
        Flex({ direction: FlexDirection.Column }) {
          this.featureButton($r("app.string.Index_delivery"), $r("app.media.delivery176x128_4x"), this.instantDelivery);
          this.featureButton($r("app.string.Taxi_travel"), $r("app.media.taxi"), this.taxiHailing);
          this.featureButton($r("app.string.Train_travel"), $r("app.media.train"), this.trainDeparture);
          this.featureButton($r("app.string.Call_queue"), $r("app.media.fooddome"), this.queueingUp);
          this.featureButton($r("app.string.Match_score"), $r("app.media.score"), this.matchScore);
          this.featureButton($r("app.string.Navigation"), $r("app.media.navigation"), this.navigation);
          this.featureButton($r("app.string.Flight_travel"), $r("app.media.flight_2"), this.flightTravel);
          this.featureButton($r("app.string.timer_title"), $r("app.media.timer_2"), this.timer);
          this.featureButton($r("app.string.Rent_share"), $r("app.media.share_2"), this.rentShare);
          this.featureButton($r("app.string.Pick_up"), $r("app.media.pick"), this.pickUp);
          this.featureButton($r("app.string.Workout"), $r("app.media.workout"), this.workout);
          Row(){}.margin({ top: '5%'});
        }
      }
      .height('100%')
      .width('100%')
    }
    .hideBackButton(true)
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor('#FFF1F3F5')
    .mode(NavigationMode.Stack)
    .title('实况窗体验')
  }

  private instantDelivery = () => {
    this.pathStack.pushPath({ name: 'InstantDelivery' });
  }
  private taxiHailing = () => {
    this.pathStack.pushPath({ name: 'TaxiHailing' });
  }
  private trainDeparture = () => {
    this.pathStack.pushPath({ name: 'TrainDeparture' });
  }
  private queueingUp = () => {
    this.pathStack.pushPath({ name: 'QueueingUp' });
  }
  private matchScore = () => {
    this.pathStack.pushPath({ name: 'MatchScore' });
  }
  private navigation = () => {
    this.pathStack.pushPath({ name: 'Navigation' });
  }
  private flightTravel = () => {
    this.pathStack.pushPath({ name: 'FlightTravel' });
  }
  private timer = () => {
    this.pathStack.pushPath({ name: 'Timer' })
  }
  private rentShare = () => {
    this.pathStack.pushPath({ name: 'RentShare' });
  }
  private pickUp = () => {
    this.pathStack.pushPath({ name: 'PickUp' });
  }
  private workout = () => {
    this.pathStack.pushPath({ name: 'Workout' });
  }
}