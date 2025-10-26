/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.petalpay.paymentservice.example.controller;

import com.huawei.petalpay.paymentservice.apiservice.client.model.NotifyPaymentReq;
import com.huawei.petalpay.paymentservice.core.callback.CallBackBaseResponse;
import com.huawei.petalpay.paymentservice.core.tools.VerifyTools;

import com.alibaba.fastjson.JSONObject;

import lombok.extern.slf4j.Slf4j;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 华为支付通知回调商户的接口
 *
 * @author 华为支付
 * @since 2023-10-28
 */
@Slf4j
@RestController
@RequestMapping(path = "/test/merc/callback", produces = MediaType.APPLICATION_JSON_VALUE)
public class CallbackController {
    /**
     * 华为支付通知回调签名公钥
     */
    public static final String HW_PAY_PUBLIC_KEY_FOR_CALLBACK = "";

    /**
     * 支付回调模拟接口（不同的场景，用不同的接口处理）
     *
     * @param callbackRequest 入参
     * @return CallBackBaseResponse
     */
    @PostMapping(value = "/v1/transation/result", produces = MediaType.APPLICATION_JSON_VALUE)
    public CallBackBaseResponse transationResultNotify(@RequestBody Object callbackRequest) {
        String callbackStr = JSONObject.toJSONString(callbackRequest);
        // TransResultCallbackReq-支付回调实体类
        return VerifyTools.getCallbackResult(callbackStr, HW_PAY_PUBLIC_KEY_FOR_CALLBACK, reqString -> {
            NotifyPaymentReq callbackReq = JSONObject.parseObject(reqString, NotifyPaymentReq.class);
            // 商户自行业务处理
            doProcess(callbackReq);
        });
    }

    /**
     * 业务处理
     *
     * @param reqBody
     */
    private void doProcess(Object reqBody) {
        log.info("Please write merchant business process here");
    }
}
