package com.huawei.iap.server.demo;

import com.huawei.iap.server.demo.notification.AppServer;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.HashMap;
import java.util.Map;

/**
 * APIExample
 *
 * @author iap
 * @since 2024-09-26
 */
public class APIExample {

    public static void main(String[] args) throws Exception {
        testGenJwt();
        testOrderService();
        testSubService();
        testJWSCheck();
        testDealNotificationV3();
    }

    public static void testGenJwt() throws Exception {
        Map<String, Object> bodyMap = new HashMap<>();
        bodyMap.put("purchaseOrderId", "purchaseOrderId");
        bodyMap.put("purchaseToken", "purchaseToken");
        ObjectMapper objectMapper = new ObjectMapper();
        String bodyJsonStr = objectMapper.writeValueAsString(bodyMap);
        String jwt = JWTGenerator.genJwt(bodyJsonStr);
        System.out.println(jwt);
    }

    public static void testOrderService() throws Exception {
        String purchaseOrderId = "purchaseOrderId";
        String purchaseToken = "purchaseToken";
        OrderService.orderStatusQuery(purchaseOrderId, purchaseToken);
        OrderService.orderShippedConfirm(purchaseOrderId, purchaseToken);
    }

    public static void testSubService() throws Exception {
        String purchaseOrderId = "purchaseOrderId";
        String purchaseToken = "purchaseToken";
        SubscriptionService.subStatusQuery(purchaseOrderId, purchaseToken);
        SubscriptionService.subShippedConfirm(purchaseOrderId, purchaseToken);
    }

    public static void testJWSCheck() throws Exception {
        String jwsStr = "jwsStr";
        System.out.println(JWSChecker.checkAndDecodeJWS(jwsStr));
    }

    public static void testDealNotificationV3() throws Exception {
        String notificationPayloadStr = "notificationPayloadStr";
        AppServer.dealNotificationV3(notificationPayloadStr);
    }
}
