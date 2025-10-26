/*
 * Copyright 2024. Huawei Technologies Co., Ltd. All rights reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 *
 */

package com.huawei.iap.server.demo.notification;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * AppServer
 *
 * @author iap
 * @since 2024-09-26
 */
public class AppServer {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    /**
     * Deal notification information V3.
     *
     * @param notificationPayloadStr Notification content, which is the payload decoded by jwsNotification.
     */
    public static void dealNotificationV3(String notificationPayloadStr) throws Exception {
        NotificationPayload notificationPayload = MAPPER.readValue(notificationPayloadStr, NotificationPayload.class);
        // TODO: Need to replace it with the actual business logic.
        String notificationSubtype = notificationPayload.getNotificationSubtype();
        switch (notificationSubtype) {
            case NotificationConstant.SubNotificationType.INITIAL_BUY:
                break;
            case NotificationConstant.SubNotificationType.DID_RENEW:
                break;
            case NotificationConstant.SubNotificationType.RESTORE:
                break;
            case NotificationConstant.SubNotificationType.AUTO_RENEW_ENABLED:
                break;
            case NotificationConstant.SubNotificationType.AUTO_RENEW_DISABLED:
                break;
            case NotificationConstant.SubNotificationType.DOWNGRADE:
                break;
            case NotificationConstant.SubNotificationType.UPGRADE:
                break;
            case NotificationConstant.SubNotificationType.REFUND_TRANSACTION:
                break;
            case NotificationConstant.SubNotificationType.BILLING_RETRY:
                break;
            case NotificationConstant.SubNotificationType.PRICE_INCREASE:
                break;
            case NotificationConstant.SubNotificationType.BILLING_RECOVERY:
                break;
            case NotificationConstant.SubNotificationType.PRODUCT_NOT_FOR_SALE:
                break;
            case NotificationConstant.SubNotificationType.APPLICATION_DELETE_SUBSCRIPTION_HOSTING:
                break;
            default:
                break;
        }
    }

}
