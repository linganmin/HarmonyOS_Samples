/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.huawei.serviceTimeline;

import static com.huawei.serviceTimeline.utils.CheckUtils.checkNotNull;
import com.huawei.serviceTimeline.entry.ServiceTimelineClient;
import com.huawei.serviceTimeline.httpclient.URLConnectionHttpClient;
import com.huawei.serviceTimeline.model.Config;
import com.huawei.serviceTimeline.model.message.ServiceTimeline;
import com.huawei.serviceTimeline.model.message.ServiceTimelineException;
import com.huawei.serviceTimeline.model.message.ServiceTimelineResponse;
import com.huawei.serviceTimeline.model.message.delivery.ClickButton;
import com.huawei.serviceTimeline.model.message.delivery.Takeaways;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.Collections;
import java.util.Date;

/**
 * A simple delivery message for takeaways
 */
public class TakeawaysExamples {
    private final static URLConnectionHttpClient httpClient = URLConnectionHttpClient.builder().connectTimeout(10000)
        //            .proxy(new Proxy(Proxy.Type.HTTP, new InetSocketAddress("xxx.com", 8080))) // If necessary, use a proxy.
        .readTimeout(10000).build();

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper().disable(
        DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES).setSerializationInclusion(JsonInclude.Include.NON_NULL);

    private final ServiceTimelineClient serviceTimelineClient;

    private final Config config;

    // 下单时间
    private final Long orderTime;

    public TakeawaysExamples() {
        this.orderTime = new Date().getTime()/1000;
        this.config = loadConfig();
        serviceTimelineClient = ServiceTimelineClient.builder().httpClient(httpClient).config(this.config).build();
    }

    private Config loadConfig() {
        URL url = ServiceTimelineClient.class.getClassLoader().getResource("config.json");
        String path = checkNotNull(url, "config doesn't exist.").getPath();
        try {
            return OBJECT_MAPPER.readValue(new File(path), Config.class);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read config, " + e.getMessage());
        }
    }

    /**
     * send pending payment status
     */
    public ServiceTimelineResponse sendPendingPayment(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways pendingPayment = Takeaways.builder()
            .status(1)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchant name")
            .customerAddress("customer address")
            .paymentEndTime("请在20:00前支付")
            .button(ClickButton.builder().type(1).text("立即支付").action("action url").uri("click uri").build())
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .appendButtons(Collections.singletonList(
                ClickButton.builder().type(1).text("立即支付").action("action url").uri("click uri").build()))
            .build();

        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(pendingPayment)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     * send order placed status
     */
    public ServiceTimelineResponse sendOrderPlaced(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways orderPlaced = Takeaways.builder()
            .status(2)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchant name")
            .customerAddress("customer address")
            .pickupNumber("pickupNumber")
            .deliveryTime("20:00")
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .build();

        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(orderPlaced)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     * send in production status
     */
    public ServiceTimelineResponse sendInProduction(String toOpenId, String code) throws ServiceTimelineException {

        Takeaways inProduction = Takeaways.builder()
            .status(3)
            .expireTime(60)
            .deliveryTime("20:00")
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchantName")
            .customerAddress("customerAddress")
            .pickupNumber("pickupNumber")
            .pickupTime("20:00")
            .remainOrders("1单/共2杯")
            .waitTime("预计20-30分钟")
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .build();

        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(inProduction)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     * send production finished status
     */
    public ServiceTimelineResponse sendProductionFinished(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways productionFinished = Takeaways.builder()
            .status(4)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchantName")
            .customerAddress("customerAddress")
            .pickupNumber("pickupNumber")
            .deliveryTime("20:00")
            .button(ClickButton.builder().type(1).text("取餐码").action("action url").uri("click uri").build())
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .appendButtons(Collections.singletonList(
                ClickButton.builder().type(1).text("取餐码").action("action url").uri("click uri").build()))
            .build();

        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(productionFinished)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     * send rider accepted status
     */
    public ServiceTimelineResponse sendRiderAccepted(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways riderAccepted = Takeaways.builder()
            .status(5)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchantName")
            .customerAddress("customerAddress")
            .pickupNumber("pickupNumber")
            .deliveryTime("20:00")
            .button(ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build())
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .appendButtons(Collections.singletonList(
                ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build()))
            .build();

        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(riderAccepted)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     *  send rider drive store status
     */
    public ServiceTimelineResponse sendRiderDriveStore(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways riderDriveStore = Takeaways.builder()
            .status(6)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchantName")
            .customerAddress("customerAddress")
            .pickupNumber("pickupNumber")
            .deliveryTime("20:00")
            .button(ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build())
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .appendButtons(Collections.singletonList(
                ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build()))
            .build();

        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(riderDriveStore)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     *  rider arrived store status
     */
    public ServiceTimelineResponse sendRiderArrivedStore(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways riderArrivedStore = Takeaways.builder()
            .status(7)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchantName")
            .customerAddress("customerAddress")
            .pickupNumber("pickupNumber")
            .deliveryTime("20:00")
            .button(ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build())
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .appendButtons(Collections.singletonList(
                ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build()))
            .build();

        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(riderArrivedStore)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     *  rider delivering status
     */
    public ServiceTimelineResponse sendRiderDelivering(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways riderDelivering = Takeaways.builder()
            .status(8)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("请前往某店")
            .customerAddress("customerAddress")
            .pickupNumber("pickupNumber")
            .deliveryTime("20:00")
            .button(ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build())
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .appendButtons(Collections.singletonList(
                ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build()))
            .build();
        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(riderDelivering)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     * send takeaways delivered status
     */
    public ServiceTimelineResponse sendTakeawaysDelivered(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways orderFinished = Takeaways.builder()
            .status(9)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchantName")
            .customerAddress("customerAddress")
            .pickupNumber("pickupNumber")
            .realDeliveryTime(new Date().getTime()/1000)
            .button(ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build())
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .appendButtons(Collections.singletonList(
                ClickButton.builder().type(1).text("联系骑手").action("action url").uri("click uri").build()))
            .build();
        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(orderFinished)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     * send order finished status
     */
    public ServiceTimelineResponse sendOrderFinished(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways orderFinished = Takeaways.builder()
            .status(10)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchantName")
            .customerAddress("customerAddress")
            .pickupNumber("pickupNumber")
            .realDeliveryTime(new Date().getTime()/1000)
            .button(ClickButton.builder().type(1).text("去评价").action("action url").uri("click uri").build())
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .appendButtons(Collections.singletonList(
                ClickButton.builder().type(1).text("去评价").action("action url").uri("click uri").build()))
            .build();
        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(orderFinished)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }

    /**
     * send order cancel status
     */
    public ServiceTimelineResponse sendOrderCancel(String toOpenId, String code) throws ServiceTimelineException {
        Takeaways orderCancel = Takeaways.builder()
            .status(11)
            .expireTime(60)
            .orderTime(this.orderTime)
            .amount("¥ 20.00")
            .productCount(1)
            .productName("奶茶")
            .productImg("test_1")
            .merchantName("merchantName")
            .customerAddress("customerAddress")
            .cancelTime(new Date().getTime()/1000)
            .cancelReason("用户主动取消")
            .button(ClickButton.builder().type(1).text("去评价").action("action url").uri("click uri").build())
            .clickAction(ClickButton.builder().type(1).action("action url").uri("click uri").build())
            .appendButtons(Collections.singletonList(
                ClickButton.builder().type(1).text("去评价").action("action url").uri("click uri").build()))
            .build();
        ServiceTimeline<Takeaways> serviceTimeline = ServiceTimeline.<Takeaways>builder()
            .appId(this.config.getAppId())
            .toOpenId(toOpenId)
            .sceneId(this.config.getSceneId())
            .subSceneId(this.config.getSubSceneId())
            .code(code)
            .content(orderCancel)
            .build();

        return serviceTimelineClient.sendMessage(serviceTimeline);
    }


    public static void main(String[] args) throws ServiceTimelineException {
        String toOpenId = "************-***"; // Please replace the toOpenId.
        String code = "***************"; // Please replace the code.

        TakeawaysExamples takeawaysExamples = new TakeawaysExamples();
        System.out.println("--- takeaways process starts ---");
        // First -- pending payment
        System.out.println(takeawaysExamples.sendPendingPayment(toOpenId, code));
        // Second -- order placed
        System.out.println(takeawaysExamples.sendOrderPlaced(toOpenId, code));
        // Third -- in production
        System.out.println(takeawaysExamples.sendInProduction(toOpenId, code));
        // Fourth -- production finished
        System.out.println(takeawaysExamples.sendProductionFinished(toOpenId, code));
        // Fifth -- rider accepted
        System.out.println(takeawaysExamples.sendRiderAccepted(toOpenId, code));
        // SixTh -- rider drive store
        System.out.println(takeawaysExamples.sendRiderDriveStore(toOpenId, code));
        // Seventh -- rider arrived store
        System.out.println(takeawaysExamples.sendRiderArrivedStore(toOpenId, code));
        // Eighth -- rider delivering
        System.out.println(takeawaysExamples.sendRiderDelivering(toOpenId, code));
        // Ninth -- takeaways delivered
        System.out.println(takeawaysExamples.sendTakeawaysDelivered(toOpenId, code));
        // Tenth -- order finished
        System.out.println(takeawaysExamples.sendOrderFinished(toOpenId, code));
        // order cancel
        // System.out.println(takeawaysExamples.sendOrderCancel(toOpenId, code));
        System.out.println("--- takeaways process over ---");
    }
}
