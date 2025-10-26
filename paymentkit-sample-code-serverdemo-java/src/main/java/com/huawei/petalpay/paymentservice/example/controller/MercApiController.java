/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.petalpay.paymentservice.example.controller;

import com.huawei.petalpay.paymentservice.apiservice.client.model.BaseGwRspWithSign;
import com.huawei.petalpay.paymentservice.apiservice.client.model.PreOrderCreateRequestV2;
import com.huawei.petalpay.paymentservice.apiservice.client.model.PreOrderCreateResponse;
import com.huawei.petalpay.paymentservice.apiservice.client.model.PreSignRequestV2;
import com.huawei.petalpay.paymentservice.apiservice.client.model.PreSignResponse;
import com.huawei.petalpay.paymentservice.core.client.DefaultPetalPayClient;
import com.huawei.petalpay.paymentservice.core.client.PetalPayClient;
import com.huawei.petalpay.paymentservice.example.common.CommonResponse;
import com.huawei.petalpay.paymentservice.example.common.MercConfigUtil;

import lombok.extern.slf4j.Slf4j;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 商户对华为支付相关接口的调用
 *
 * @author 华为支付
 * @since 2023-10-28
 */
@Slf4j
@RestController
@RequestMapping(path = "/test/merc/api", produces = MediaType.APPLICATION_JSON_VALUE)
public class MercApiController {

    private static PetalPayClient payClient = new DefaultPetalPayClient(MercConfigUtil.getMercConfig());

    /**
     * 预下单接口调用
     */
    @PostMapping(value = "/preorder", produces = MediaType.APPLICATION_JSON_VALUE)
    public CommonResponse aggrPreOrderForAppV2() {
        // 组装对象
        PreOrderCreateRequestV2 preOrderReq = getPreOrderCreateRequestV2();
        PreOrderCreateResponse response = null;
        try {
            response = payClient.execute("POST", "/api/v2/aggr/preorder/create/app", PreOrderCreateResponse.class,
                preOrderReq);
        } catch (Exception e) {
            // todo 异常处理
            log.error("request error ", e);
            return CommonResponse.buildErrorRsp(e.getMessage());
        }
        if (!validResponse(response)) {
            // todo 异常处理
            log.error("response is invalid ", response);
            return CommonResponse.buildFailRsp(response);
        }
        return CommonResponse.buildSuccessRsp(payClient.buildOrderStr(response.getPrepayId()));
    }

    /**
     * 预签约接口调用
     */
    @PostMapping(value = "/presign", produces = MediaType.APPLICATION_JSON_VALUE)
    public CommonResponse contractPreSignAppV2() {
        // 组装对象
        PreSignRequestV2 preSignReq = getPreSignRequestV2();
        PreSignResponse response = null;
        try {
            response = payClient.execute("POST", "/api/v2/contract/presign/app", PreSignResponse.class, preSignReq);
        } catch (Exception e) {
            // todo 异常处理
            log.error("request error ", e);
            return CommonResponse.buildErrorRsp(e.getMessage());
        }
        if (!validResponse(response)) {
            // todo 异常处理
            log.error("response is invalid ", response);
            return CommonResponse.buildFailRsp(response);
        }
        return CommonResponse.buildSuccessRsp(payClient.buildContractStr(response.getPreSignNo()));
    }

    public static boolean validResponse(BaseGwRspWithSign rsp) {
        return rsp != null && "000000".equals(rsp.getResultCode());
    }

    /**
     * 预下单接口请求参数组装，商户请根据业务自行实现
     */
    public static PreOrderCreateRequestV2 getPreOrderCreateRequestV2() {
        return PreOrderCreateRequestV2.builder()
            .mercOrderNo("pay-example-" + System.currentTimeMillis()) // 每次订单号都要变，请将pay-example-修改为商户自己的订单前缀
            .appId(MercConfigUtil.APP_ID)  // appId，需要配置为与商户绑定的正确的appId
            .mercNo(MercConfigUtil.MERC_NO) // 商户的商户号
            .tradeSummary("请修改为对应的商品简称") // 请修改为商品简称
            .bizType("100002") // (100001：虚拟商品购买,100002：实物商品购买,100003：预付类账号充值,100004：航旅交通服务,100005：活动票务订购,100006：商业服务消费,100007：生活服务消费,100008：租金缴纳,100009：会员费缴纳,100011：其他商家消费,100037：公共便民服务)
            .totalAmount(2L)
            .callbackUrl("https://www.xxxxxx.com/hw/pay/callback") //回调通知地址，通知URL必须为直接可访问的URL，要求为https地址。最大长度为512。请替换为格式正确的结果通知回调地址。
            .build();
    }

    /**
     * 预签约接口请求参数组装，商户请根据业务自行实现
     */
    private PreSignRequestV2 getPreSignRequestV2() {
        return PreSignRequestV2.builder()
            .appId(MercConfigUtil.APP_ID) // appId，需要配置为与商户绑定的正确的appId
            .mercContractCode("pay-example-" + System.currentTimeMillis()) // 签约协议号，每次请求都要变，请将pay-example-修改为商户自己的订单前缀
            .mercNo(MercConfigUtil.MERC_NO) // 商户号
            .planId("100") // 协议模板ID，该模板ID是商户在向华为支付提交代扣权限申请时由华为支付生成。请填写正确的协议模板ID。
            .callbackUrl("https://www.xxxxxx.com/hw/sign/callback") //回调通知地址，通知URL必须为直接可访问的URL，要求为https地址。最大长度为512。请替换为格式正确的结果通知回调地址。
            .build();
    }
}
