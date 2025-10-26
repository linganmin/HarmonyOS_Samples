/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.petalpay.paymentservice.example.common;

import com.huawei.petalpay.paymentservice.core.config.PetalPayConfig;
import com.huawei.petalpay.paymentservice.core.constant.SignType;

import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.util.Properties;

/**
 * 获取商户配置信息的工具类
 *
 * @author 华为支付
 * @since 2024-02-22
 */
@Slf4j
public class MercConfigUtil {
    /**
     * 商户秘钥
     */
    public static final String MERC_PRIVATE_KEY;

    /**
     * 应用id
     */
    public static final String APP_ID;

    /**
     * 商户号
     */
    public static final String MERC_NO;

    /**
     * 商户证书序列号
     */
    public static final String MERC_AUTH_ID;

    /**
     * 商户公私钥类型
     */
    public static final SignType SIGN_TYPE;

    /**
     * 请求域名
     */
    public static final String SERVER_HOST;

    /**
     * rsp和通知回调验签公钥
     */
    public static final String HW_PAY_PUBLIC_KEY_FOR_CALLBACK;

    /**
     * SESSSIONKEY加密公钥
     */
    public static final String HW_PUBLIC_KEY_FOR_SESSIONKEY;

    static {
        Properties p2 = new Properties();
        try {
            p2.load(MercConfigUtil.class.getClassLoader().getResourceAsStream("petalpayconfig.properties"));
        } catch (IOException e) {
            log.error("get petalpayconfig.properties error: {}", e.getMessage());
        }
        MERC_PRIVATE_KEY = p2.getProperty("PETALPAY.MERC_PRIVATE_KEY");
        MERC_NO = p2.getProperty("PETALPAY.MERC_NO");
        APP_ID = p2.getProperty("PETALPAY.APPID");
        MERC_AUTH_ID = p2.getProperty("PETALPAY.MERC_AUTH_ID");
        SIGN_TYPE = "RSA".equals(p2.getProperty("PETALPAY.SIGN_TYPE")) ? SignType.RSA : SignType.SM2;
        SERVER_HOST = p2.getProperty("PETALPAY.SERVER_HOST");
        HW_PAY_PUBLIC_KEY_FOR_CALLBACK = p2.getProperty("PETALPAY.HW_PAY_PUBLIC_KEY_FOR_CALLBACK");
        HW_PUBLIC_KEY_FOR_SESSIONKEY = p2.getProperty("PETALPAY.HW_PUBLIC_KEY_FOR_SESSIONKEY");
    }

    // 商户配置
    public static PetalPayConfig getMercConfig() {
        return PetalPayConfig.builder().callerId(MERC_NO) // (必填)商户号
            .appId(APP_ID) // (必填) 应用id
            .privateKey(MERC_PRIVATE_KEY) // (必填) 商户秘钥
            .authId(MERC_AUTH_ID) // (必填) 商户证书序列号
            .signType(SIGN_TYPE) // (选填) 商户公私钥类型，默认RSA加密
            .petalpayPublicKey(HW_PAY_PUBLIC_KEY_FOR_CALLBACK) // (非必填) 验签公钥(和接口级配置needVerifyRsp对应，公钥和商户通知回调验签公钥同一个)
            .domainHost(SERVER_HOST).build();
    }

}
