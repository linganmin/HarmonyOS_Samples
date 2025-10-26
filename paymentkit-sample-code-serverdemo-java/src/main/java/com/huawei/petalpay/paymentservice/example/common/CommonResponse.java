/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.petalpay.paymentservice.example.common;

import lombok.Getter;
import lombok.Setter;

/**
 * 通用响应结构体，商户请根据自己业务定义
 *
 * @author 华为支付
 * @since 2024-02-22
 */
@Getter
@Setter
public class CommonResponse {
    private String resultCode;

    private String subDesc;

    private Object result;

    public static CommonResponse buildSuccessRsp(Object result) {
        CommonResponse rsp = new CommonResponse();
        rsp.setResultCode("000000");
        rsp.setSubDesc("SUCCESS");
        rsp.setResult(result);
        return rsp;
    }

    public static CommonResponse buildFailRsp(Object result) {
        CommonResponse rsp = new CommonResponse();
        rsp.setResultCode("-1");
        rsp.setSubDesc("FAIL");
        rsp.setResult(result);
        return rsp;
    }

    public static CommonResponse buildErrorRsp(String errMsg) {
        CommonResponse rsp = new CommonResponse();
        rsp.setResultCode("-1");
        rsp.setSubDesc("ERROR");
        rsp.setResult(errMsg);
        return rsp;
    }
}
