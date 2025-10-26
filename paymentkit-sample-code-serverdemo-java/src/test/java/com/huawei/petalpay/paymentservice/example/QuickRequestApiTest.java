/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.petalpay.paymentservice.example;

import com.huawei.petalpay.paymentservice.core.client.DefaultPetalPayClient;
import com.huawei.petalpay.paymentservice.core.client.PetalPayClient;
import com.huawei.petalpay.paymentservice.core.tools.JsonUtils;
import com.huawei.petalpay.paymentservice.example.common.CommonResponse;
import com.huawei.petalpay.paymentservice.example.common.MercConfigUtil;

import lombok.extern.slf4j.Slf4j;

import org.apache.commons.lang3.StringUtils;
import org.junit.Test;

import java.util.Map;

/**
 * 快速发起一个请求
 *
 * @author 华为支付
 * @since 2024-04-19
 */
@Slf4j
public class QuickRequestApiTest {
    private static PetalPayClient payClient = new DefaultPetalPayClient(MercConfigUtil.getMercConfig());

    private Object request(String httpMethod, String apiUrl, String bodyStr) {
        try {
            Map<String, Object> body = null;
            if (StringUtils.isNotBlank(bodyStr)){
                 body = JsonUtils.json2Obj(bodyStr, Map.class);
            }
            return payClient.execute(httpMethod, apiUrl, Object.class, body);
        } catch (Exception e) {
            log.error("request error ", e);
            return CommonResponse.buildErrorRsp(e.getMessage());
        }
    }

    @Test
    public void quick_send_request_by_post_test() {
        log.info("RESPONSE: " + JsonUtils.obj2Json(request(
            "POST",
            "/api/v2/aggr/preorder/create/app",
            "{}"
        )));
    }

    @Test
    public void quick_send_request_by_get_test() {
        log.info("RESPONSE: " + JsonUtils.obj2Json(request(
            "GET",
            "/api/v2/aggr/transactions/merc-orders/{mercOrderNo}",
            null
        )));
    }
}