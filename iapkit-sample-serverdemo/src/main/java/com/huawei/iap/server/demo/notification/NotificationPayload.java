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
 * NotificationPayload
 *
 * @author iap
 * @since 2024-09-26
 */
public class NotificationPayload {
    private String notificationType;

    private String notificationSubtype;

    private String notificationRequestId;

    private NotificationMetaData notificationMetaData;

    private String notificationVersion;

    private Long signedTime;

    public String getNotificationType() {
        return notificationType;
    }

    public void setNotificationType(String notificationType) {
        this.notificationType = notificationType;
    }

    public String getNotificationSubtype() {
        return notificationSubtype;
    }

    public void setNotificationSubtype(String notificationSubtype) {
        this.notificationSubtype = notificationSubtype;
    }

    public String getNotificationRequestId() {
        return notificationRequestId;
    }

    public void setNotificationRequestId(String notificationRequestId) {
        this.notificationRequestId = notificationRequestId;
    }

    public NotificationMetaData getNotificationMetaData() {
        return notificationMetaData;
    }

    public void setNotificationMetaData(NotificationMetaData notificationMetaData) {
        this.notificationMetaData = notificationMetaData;
    }

    public String getNotificationVersion() {
        return notificationVersion;
    }

    public void setNotificationVersion(String notificationVersion) {
        this.notificationVersion = notificationVersion;
    }

    public Long getSignedTime() {
        return signedTime;
    }

    public void setSignedTime(Long signedTime) {
        this.signedTime = signedTime;
    }
}
