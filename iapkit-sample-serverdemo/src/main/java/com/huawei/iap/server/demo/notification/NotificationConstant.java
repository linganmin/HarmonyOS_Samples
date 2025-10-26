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

/**
 * NotificationConstant
 *
 * @author iap
 * @since 2024-09-26
 */
public interface NotificationConstant {
    interface NotificationType {
        String DID_NEW_TRANSACTION = "DID_NEW_TRANSACTION";

        String DID_CHANGE_RENEWAL_STATUS = "DID_CHANGE_RENEWAL_STATUS";

        String REVOKE = "REVOKE";

        String RENEWAL_TIME_MODIFIED = "RENEWAL_TIME_MODIFIED";

        String EXPIRE = "EXPIRE";

        String SYNC = "SYNC";
    }

    interface SubNotificationType {
        String INITIAL_BUY = "INITIAL_BUY";

        String DID_RENEW = "DID_RENEW";

        String RESTORE = "RESTORE";

        String AUTO_RENEW_ENABLED = "AUTO_RENEW_ENABLED";

        String AUTO_RENEW_DISABLED = "AUTO_RENEW_DISABLED";

        String DOWNGRADE = "DOWNGRADE";

        String UPGRADE = "UPGRADE";

        String REFUND_TRANSACTION = "REFUND_TRANSACTION";

        String BILLING_RETRY = "BILLING_RETRY";

        String PRICE_INCREASE = "PRICE_INCREASE";

        String BILLING_RECOVERY = "BILLING_RECOVERY";

        String PRODUCT_NOT_FOR_SALE = "PRODUCT_NOT_FOR_SALE";

        String APPLICATION_DELETE_SUBSCRIPTION_HOSTING = "APPLICATION_DELETE_SUBSCRIPTION_HOSTING";

        String RENEWAL_EXTENDED = "RENEWAL_EXTENDED";
    }
}
