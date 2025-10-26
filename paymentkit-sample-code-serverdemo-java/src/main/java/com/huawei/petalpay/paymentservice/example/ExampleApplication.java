/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.petalpay.paymentservice.example;

import com.huawei.petalpay.paymentservice.core.tools.JsonUtils;
import com.huawei.petalpay.paymentservice.example.common.CommonResponse;
import com.huawei.petalpay.paymentservice.example.controller.MercApiController;

import lombok.extern.slf4j.Slf4j;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 服务启动类
 *
 * @author 华为支付
 * @since 2024-02-22
 */
@Slf4j
@SpringBootApplication
public class ExampleApplication {
    public static void main(String[] args) {
        SpringApplication.run(ExampleApplication.class, args);
        test();
    }

    /**
     * 验证接口调用
     */
    public static void test() {
        MercApiController mercApiController = new MercApiController();
        CommonResponse rsp = null;
        rsp = mercApiController.aggrPreOrderForAppV2();
        log.info("aggrPreOrderForAppV2 rsp: " + JsonUtils.obj2Json(rsp));

        rsp = mercApiController.contractPreSignAppV2();
        log.info("contractPreSignAppV2 rsp: " + JsonUtils.obj2Json(rsp));
    }
}
