/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { image } from '@kit.ImageKit';
import { notificationManager } from '@kit.NotificationKit';
import {
  logger,
  notificationUtil,
  notificationContentUtil,
  notificationRequestUtil,
  wantAgentUtil
} from 'notification';

const TAG: string = 'Sample_Notification';
const BUNDLE_NAME: string = 'com.samples.customnotificationbadge';
const ABILITY_NAME: string = 'MainAbility';
// The multi line text content of a multi line notification.
const MULTI_LINE_CONTENT: Array<string> = ['line0', 'line1', 'line2', 'line3'];

interface NOTIFICATION_GROUP_TYPE {
  BASIC: string,
  LONG_TEXT: string,
  MULTI_LINE: string,
  PICTURE: string,
  CONVERSATION: string
};

// Define notification groups for different types of notifications.
const NOTIFICATION_GROUP: NOTIFICATION_GROUP_TYPE = {
  BASIC: 'BASIC',
  LONG_TEXT: 'LONG_TEXT',
  MULTI_LINE: 'MULTI_LINE',
  PICTURE: 'PICTURE',
  CONVERSATION: 'CONVERSATION'
};

export default class NotificationOperations {
  private context: Context;
  private basicContent: notificationManager.NotificationBasicContent;

  // Initialize the basic notification parameters in the initialization function.
  constructor(context: Context) {
    this.context = context;
    let notificationTitle = '';
    let notificationText = this.context.resourceManager.getStringSync($r('app.string.notification_content').id);
    let notificationAdditional =
      this.context.resourceManager.getStringSync($r('app.string.notification_additional').id);
    this.basicContent = {
      title: notificationTitle,
      text: notificationText,
      additionalText: notificationAdditional
    };
  }

  publishBasicNotification = () => {
    try {
      logger.info(TAG, 'publishBasicNotification');
      this.basicContent.title = this.context.resourceManager.getStringSync($r('app.string.basic_notification').id);
      let notificationContent = notificationContentUtil.initBasicNotificationContent(this.basicContent);
      notificationUtil.publishNotification(notificationRequestUtil.initBasicNotificationRequest(notificationContent as notificationManager.NotificationContent) as notificationManager.NotificationRequest);
    } catch (error) {
      logger.error(TAG, `publishBasicNotification error, error = ${JSON.stringify(error)}`);
    }
  };
  publishLongTextNotification = () => {
    try {
      logger.info(TAG, 'publishLongTextNotification');
      this.basicContent.title = this.context.resourceManager.getStringSync($r('app.string.long_text_notification').id);
      let notificationLongText = this.context.resourceManager.getStringSync($r('app.string.notification_long_text').id);
      let notificationBriefText =
        this.context.resourceManager.getStringSync($r('app.string.notification_brief_text').id);
      let notificationExpandedText =
        this.context.resourceManager.getStringSync($r('app.string.notification_expanded_title').id);
      let notificationContent =
        notificationContentUtil.initNotificationLongTextContent(this.basicContent, notificationLongText,
          notificationBriefText, notificationExpandedText);
      notificationUtil.publishNotification(notificationRequestUtil.initBasicNotificationRequest(notificationContent as notificationManager.NotificationContent) as notificationManager.NotificationRequest);
    } catch (error) {
      logger.info(TAG, `publishLongTextNotification error, error = ${JSON.stringify(error)}`);
    }
  };
  publishMultiLineNotification = () => {
    try {
      logger.info(TAG, 'publishMultiLineNotification');
      this.basicContent.title = this.context.resourceManager.getStringSync($r('app.string.multiline_notification').id);
      let notificationBriefText =
        this.context.resourceManager.getStringSync($r('app.string.notification_brief_text').id);
      let notificationLongTitle =
        this.context.resourceManager.getStringSync($r('app.string.notification_expanded_title').id);
      let notificationContent =
        notificationContentUtil.initNotificationMultiLineContent(this.basicContent, notificationBriefText,
          notificationLongTitle, MULTI_LINE_CONTENT);
      notificationUtil.publishNotification(notificationRequestUtil.initBasicNotificationRequest(notificationContent as notificationManager.NotificationContent) as notificationManager.NotificationRequest);
    } catch (error) {
      logger.info(TAG, `publishMultiLineNotification error, error = ${JSON.stringify(error)}`);
    }
  };
  publishPictureNotification = async () => {
    try {
      logger.info(TAG, 'publishPictureNotification');
      this.basicContent.title = this.context.resourceManager.getStringSync($r('app.string.picture_notification').id);
      let notificationBriefText =
        this.context.resourceManager.getStringSync($r('app.string.notification_brief_text').id);
      let notificationExpandedText =
        this.context.resourceManager.getStringSync($r('app.string.notification_expanded_title').id);
      let imageArray = await this.context.resourceManager.getMediaContent($r('app.media.notification_icon').id);
      let imageResource = image.createImageSource(imageArray.buffer as ArrayBuffer);
      let picture = await imageResource.createPixelMap();
      let notificationContent =
        notificationContentUtil.initNotificationPictureContent(this.basicContent, notificationBriefText,
          notificationExpandedText, picture);
      notificationUtil.publishNotification(notificationRequestUtil.initBasicNotificationRequest(notificationContent as notificationManager.NotificationContent) as notificationManager.NotificationRequest);
    } catch (error) {
      logger.info(TAG, `publishPictureNotification error, error = ${JSON.stringify(error)}`);
    }
  };
  publishConversationNotification = async () => {
    try {
      logger.info(TAG, 'publishConversationNotification');
      this.basicContent.title =
        this.context.resourceManager.getStringSync($r('app.string.conversation_notification').id);
      let notificationContent = notificationContentUtil.initNotificationConversationContent(this.basicContent);
      notificationUtil.publishNotification(notificationRequestUtil.initBasicNotificationRequest(notificationContent as notificationManager.NotificationContent) as notificationManager.NotificationRequest,
        NOTIFICATION_GROUP.CONVERSATION);
    } catch (error) {
      logger.info(TAG, `publishNotificationWithWantAgent error, error = ${JSON.stringify(error)}`);
    }
  };
  publishNotificationWithButtons = async () => {
    try {
      if (this.basicContent !== undefined && this.basicContent !== null) {
        logger.info(TAG, `publishNotificationWithButtons`);
        this.basicContent.title =
          this.context.resourceManager.getStringSync($r('app.string.notification_with_buttons').id);
        let actionButtons: notificationManager.NotificationActionButton[] = [
          {
            title: this.context.resourceManager.getStringSync($r('app.string.first_button').id),
            wantAgent: await wantAgentUtil.createWantAgentForCommonEvent('')
          },
          {
            title: this.context.resourceManager.getStringSync($r('app.string.second_button').id),
            wantAgent: await wantAgentUtil.createWantAgentForStartAbility(BUNDLE_NAME, ABILITY_NAME)
          }
        ]
        let notificationContent = notificationContentUtil.initBasicNotificationContent(this.basicContent);
        let notificationRequest =
          notificationRequestUtil.initButtonNotificationRequest(notificationContent, actionButtons);
        notificationUtil.publishNotification(notificationRequest);
      }
    } catch (error) {
      logger.info(TAG, `publishNotificationWithButtons error, error = ${JSON.stringify(error)}`);
    }
  };
  publishNotificationWithWantAgent = async () => {
    try {
      logger.info(TAG, `publishNotificationWithWantAgent`);
      if (this.basicContent !== undefined && this.basicContent !== null) {
        this.basicContent.title = this.context.resourceManager.getStringSync($r('app.string.basic_notification').id);
        let notificationWantAgent = await wantAgentUtil.createWantAgentForStartAbility(BUNDLE_NAME, ABILITY_NAME);
        let notificationContent = notificationContentUtil.initBasicNotificationContent(this.basicContent);
        let notificationRequest =
          notificationRequestUtil.initWantAgentNotificationRequest(notificationContent, notificationWantAgent);
        notificationUtil.publishNotification(notificationRequest);
      }
    } catch (error) {
      logger.info(TAG, `publishNotificationWithWantAgent error, error = ${JSON.stringify(error)}`);
    }
  };
}