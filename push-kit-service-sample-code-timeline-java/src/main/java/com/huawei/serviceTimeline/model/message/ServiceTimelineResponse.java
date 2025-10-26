/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.model.message;

/**
 * ServiceTimelineResponse.
 */
public class ServiceTimelineResponse {
    private String code;

    private String msg;

    private String requestId;

    public ServiceTimelineResponse() {
    }

    public static ServiceTimelineResponse fromHttpFailure(String code, String msg) {
        ServiceTimelineResponse serviceTimelineResponse = new ServiceTimelineResponse();
        serviceTimelineResponse.setCode(code);
        serviceTimelineResponse.setMsg("Failed to execute http request. " + msg);
        return serviceTimelineResponse;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    @Override
    public String toString() {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("serviceTimelineResponse{" + "code='")
            .append(code)
            .append('\'')
            .append(", msg='")
            .append(msg)
            .append('\'');
        if (requestId != null) {
            stringBuilder.append(", requestId='").append(requestId).append('\'');
        }
        stringBuilder.append("}");
        return stringBuilder.toString();
    }
}
