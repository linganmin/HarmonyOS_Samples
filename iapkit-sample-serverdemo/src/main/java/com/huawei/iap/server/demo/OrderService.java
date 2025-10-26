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

package com.huawei.iap.server.demo;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.HashMap;
import java.util.Map;

/**
 * OrderService
 *
 * @author iap
 * @since 2024-09-26
 */
public class OrderService extends IAPServer {

    /**
     * Order Status Query Url
     */
    private static final String URL_ORDER_STATUS_QUERY = "/order/harmony/v1/application/order/status/query";

    /**
     * Order Shipped Confirm Url
     */
    private static final String URL_ORDER_SHIPPED_CONFIRM = "/order/harmony/v1/application/purchase/shipped/confirm";

    /**
     * This API is used to query the latest status of a consumable or non-consumable order.
     * @param purchaseOrderId Order ID of a purchase.
     * @param purchaseToken Purchase token of a product, which you can obtain from the information returned after a purchase or an order query.
     * @throws Exception Exception
     */
    public static void orderStatusQuery(String purchaseOrderId, String purchaseToken) throws Exception {
        Map<String, Object> bodyMap = new HashMap<>();
        bodyMap.put("purchaseOrderId", purchaseOrderId);
        bodyMap.put("purchaseToken", purchaseToken);
        ObjectMapper objectMapper = new ObjectMapper();
        String bodyJsonStr = objectMapper.writeValueAsString(bodyMap);
        String response = httpPost(URL_ROOT + URL_ORDER_STATUS_QUERY, bodyJsonStr);
        // TODO: Need to replace it with the actual business logic.
        System.out.println("order status query response is: " + response);
    }

    /**
     * This API is used to acknowledge that a purchased consumable or non-consumable has been delivered.
     * @param purchaseOrderId Order ID of a purchase.
     * @param purchaseToken Purchase token of a product, which you can obtain from the information returned after a purchase or an order query.
     * @throws Exception Exception
     */
    public static void orderShippedConfirm(String purchaseOrderId, String purchaseToken) throws Exception {
        Map<String, Object> bodyMap = new HashMap<>();
        bodyMap.put("purchaseOrderId", purchaseOrderId);
        bodyMap.put("purchaseToken", purchaseToken);
        ObjectMapper objectMapper = new ObjectMapper();
        String bodyJsonStr = objectMapper.writeValueAsString(bodyMap);
        String response = httpPost(URL_ROOT + URL_ORDER_SHIPPED_CONFIRM, bodyJsonStr);
        // TODO: Need to replace it with the actual business logic.
        System.out.println("order shipped confirm response is: " + response);
    }

}
