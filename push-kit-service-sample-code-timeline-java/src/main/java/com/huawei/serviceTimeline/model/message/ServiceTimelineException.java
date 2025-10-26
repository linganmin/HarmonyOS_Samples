/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.model.message;

/**
 * ServiceTimeline exception.
 */
public class ServiceTimelineException extends Exception {
    public ServiceTimelineException() {
    }

    public ServiceTimelineException(String message) {
        super(message);
    }
}
