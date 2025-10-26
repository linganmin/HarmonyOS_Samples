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
// [Start live_view_manager]
import { liveViewManager } from '@kit.LiveViewKit';
// [End live_view_manager]
import { Want, WantAgent, wantAgent } from '@kit.AbilityKit';
import { CyclingConstants, CyclingStatus } from '../constants/CyclingConstants';
import { TextCapsuleBuilder } from '../liveview/TextCapsuleBuilder';
import { TextLayoutBuilder } from '../liveview/TextLayoutBuilder';
import { LiveViewEnvironment } from './LiveViewEnvironment';
import { LiveViewDataBuilder } from './LiveViewDataBuilder';
import { LiveNotification } from './LiveNotification';
import { LiveViewContext } from './LiveViewContext';


type LiveView = liveViewManager.LiveView;

export class LiveViewController {
  private liveNotification?: LiveNotification;
  private liveViewData?: liveViewManager.LiveViewData;

  public getLiveViewEnvironment() {
    return this.liveNotification?.env ?? {
      id: 0,
      event: 'RENT'
    };
  }

  public rebuild(context: LiveViewContext, liveView: LiveView) {
    this.liveViewData = liveView.liveViewData;
    this.liveViewData.primary.keepTime = CyclingConstants.KEEP_TIME;
    this.liveNotification = LiveNotification.rebuild(context, liveView);
  }

  // [Start start_live_view]
  public async startLiveView(context: LiveViewContext,
    liveViewEnvironment?: LiveViewEnvironment): Promise<liveViewManager.LiveViewResult> {
    // build liveView
    this.liveViewData = await LiveViewController.buildDefaultView(context);
    let env = liveViewEnvironment;
    if (!env) {
      env = {
        id: 0,
        event: 'RENT'
      };
    }
    this.liveNotification = LiveNotification.from(context, env);
    return await this.liveNotification.create(this.liveViewData);
  }

  // [End start_live_view]
  // [Start update_live_view]
  public async updateLiveView(status: number, context: LiveViewContext): Promise<liveViewManager.LiveViewResult> {
    // update liveView
    const liveViewData = this.liveViewData!;
    switch (status) {
      case CyclingStatus.WAITING_PAYMENT:
        liveViewData.primary.title = CyclingConstants.WAITING_PAYMENT_TITLE;
        liveViewData.primary.content = [
          {
            text: CyclingConstants.WAITING_PAYMENT_CONTENT,
            textColor: CyclingConstants.CONTENT_COLOR
          }
        ];
        liveViewData.primary.clickAction = await LiveViewController.buildWantAgent(context.want);
        liveViewData.primary.layoutData = new TextLayoutBuilder()
          .setTitle(CyclingConstants.WAITING_PAYMENT_LAYOUT_TITLE)
          .setContent(CyclingConstants.WAITING_PAYMENT_LAYOUT_CONTENT)
          .setDescPic('bike_page.png');

        liveViewData.capsule = new TextCapsuleBuilder()
          .setIcon('white_bike.png')
          .setBackgroundColor(CyclingConstants.CAPSULE_COLOR)
          .setTitle(CyclingConstants.WAITING_PAYMENT_LAYOUT_TITLE)
        break;
      case CyclingStatus.PAYMENT_COMPLETED:
        liveViewData.primary.title = CyclingConstants.WAITING_PAYMENT_TITLE;
        liveViewData.primary.clickAction = await LiveViewController.buildWantAgent(context.want);
        liveViewData.primary.content = [
          {
            text: CyclingConstants.WAITING_PAYMENT_PAY,
            textColor: CyclingConstants.CONTENT_COLOR
          },
          {
            text: CyclingConstants.WAITING_PAYMENT_PAY_SUCCESS,
            textColor: CyclingConstants.CONTENT_COLOR
          }
        ];

        liveViewData.primary.layoutData = new TextLayoutBuilder()
          .setTitle(CyclingConstants.WAITING_PAYMENT_PAY_END)
          .setContent(CyclingConstants.WAITING_PAYMENT_LAYOUT_CONTENT)
          .setDescPic('bike_page.png');

        liveViewData.capsule = new TextCapsuleBuilder()
          .setIcon('white_bike.png')
          .setBackgroundColor(CyclingConstants.CAPSULE_COLOR)
          .setTitle(CyclingConstants.PAYMENT_COMPLETED_CAPSULE_TITLE)

        return await this.liveNotification!.stop(liveViewData);
      default:
        break;
    }

    return await this.liveNotification!.update(liveViewData);
  }

  // [End update_live_view]
  // [Start build_default_view]
  private static async buildDefaultView(context: LiveViewContext) {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');

    const layoutData = new TextLayoutBuilder()
      .setTitle(uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.ridding_text_third').id))
      .setContent(uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.pay_text_fifth').id))
      .setDescPic('bike_page.png');

    const capsule = new TextCapsuleBuilder()
      .setIcon('white_bike.png')
      .setBackgroundColor(CyclingConstants.CAPSULE_COLOR)
      .setTitle(uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.riding_text').id))

    const liveViewData = new LiveViewDataBuilder()
      .setTitle(uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.riding_text').id))
      .setContentText(uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.default_view_riding_time')
        .id))
      .setContentColor(CyclingConstants.CONTENT_COLOR)
      .setLayoutData(layoutData)
      .setCapsule(capsule)
      .setWant(await LiveViewController.buildWantAgent(context.want))

    return liveViewData;
  };

  // [End build_default_view]

  private static async buildWantAgent(want: Want): Promise<WantAgent> {
    const
      wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [want],
        operationType: wantAgent.OperationType.START_ABILITIES,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };
    const agent = await wantAgent.getWantAgent(wantAgentInfo);
    return agent;
  }
}

export const liveViewController: LiveViewController = new LiveViewController();