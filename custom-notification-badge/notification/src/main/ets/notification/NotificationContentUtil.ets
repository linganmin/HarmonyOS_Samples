/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
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

interface NotificationContentUtilResultType {
  notificationContentType: notificationManager.ContentType,
  normal?: notificationManager.NotificationBasicContent,
  longText?: notificationManager.NotificationLongTextContent,
  multiLine?: notificationManager.NotificationMultiLineContent,
  picture?: notificationManager.NotificationPictureContent
};

class NotificationContentUtil {
  /**
   * init basic notification content
   * @param basicContent
   * @return return the created NotificationContent
   */
  initBasicNotificationContent(basicContent: notificationManager.NotificationBasicContent) {
    let result: NotificationContentUtilResultType = {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
      // Basic notification content
      normal: basicContent
    }
    return result;
  }

  /**
   *  init longText notification content
   *
   * @param basicContent
   * @param notificationLongText
   * @param notificationBriefText
   * @param notificationExpandedTitle
   * @return return the created NotificationContent
   */
  initNotificationLongTextContent(basicContent: notificationManager.NotificationBasicContent,
    notificationLongText: string, notificationBriefText: string, notificationExpandedTitle: string) {
    let result: NotificationContentUtilResultType = {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_LONG_TEXT,
      longText: {
        title: basicContent.title,
        text: basicContent.text,
        // Notification of secondary content
        additionalText: basicContent.additionalText ? basicContent.additionalText : '',
        longText: notificationLongText,
        briefText: notificationBriefText,
        expandedTitle: notificationExpandedTitle
      }
    };
    return result;
  }

  /**
   * init multiline notification content
   * @param basicContent
   * @param notificationBriefText
   * @param notificationLongTitle
   * @param notificationLines
   * @return return the created NotificationContent
   */
  initNotificationMultiLineContent(basicContent: notificationManager.NotificationBasicContent,
    notificationBriefText: string, notificationLongTitle: string, notificationLines: Array<string>) {
    let result: NotificationContentUtilResultType = {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_MULTILINE,
      multiLine: {
        title: basicContent.title,
        text: basicContent.text,
        // Notification of secondary content
        additionalText: basicContent.additionalText ? basicContent.additionalText : '',
        briefText: notificationBriefText,
        longTitle: notificationLongTitle,
        lines: notificationLines
      }
    };
    return result;
  }

  /**
   * init picture notification content
   * @param basicContent
   * @param notificationBriefText
   * @param notificationExpandedTitle
   * @param notificationPicture
   * @return return the created NotificationContent
   */
  initNotificationPictureContent(basicContent: notificationManager.NotificationBasicContent,
    notificationBriefText: string, notificationExpandedTitle: string, notificationPicture: image.PixelMap) {
    let result: NotificationContentUtilResultType = {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_PICTURE,
      picture: {
        title: basicContent.title,
        text: basicContent.text,
        additionalText: basicContent.additionalText ? basicContent.additionalText : '',
        briefText: notificationBriefText,
        expandedTitle: notificationExpandedTitle,
        picture: notificationPicture
      }
    };
    return result;
  }

  /**
   * init conversation notification content
   * @param basicContent
   * @return return the created NotificationContent
   */
  initNotificationConversationContent(basicContent: notificationManager.NotificationBasicContent) {
    let result: NotificationContentUtilResultType = {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_CONVERSATION,
      normal: basicContent
    };
    return result;
  }
}

export let notificationContentUtil = new NotificationContentUtil();