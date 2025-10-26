/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.
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
 */

package com.huawei.wallet.hms.giftcard;

import com.huawei.wallet.hms.ServerApiService;
import com.huawei.wallet.hms.ServerApiServiceImpl;
import com.huawei.wallet.util.ConfigUtil;
import com.huawei.wallet.util.HwWalletObjectUtil;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import org.junit.Test;

/**
 * Gift card model tests.
 *
 * @since 2019-12-12
 */
public class GiftCardModelTest {
    private final ServerApiService serverApiService = new ServerApiServiceImpl();

    /**
     * Create a new gift card model.
     * Each gift card model indicates a style of gift card passes.
     * POST http://XXX/hmspass/v1/giftcard/model
     */
    @Test
    public void createGiftCardModel() {
        System.out.println("createGiftCardModel begin.");

        // Read a gift card model from a JSON file.
        JSONObject model = JSONObject.parseObject(ConfigUtil.readFile("GiftCardModel.json"));

        // Validate parameters.
        HwWalletObjectUtil.validateModel(model);

        // Post the new gift card model to HMS wallet server.
        String urlSegment = "/v1/giftcard/model";
        JSONObject responseModel = serverApiService.postToWalletServer(urlSegment, JSONObject.toJSONString(model));
        System.out.println("Posted gift card model: " + JSONObject.toJSONString(responseModel));
    }

    /**
     * Get a gift card model by its model ID.
     * Run the "createGiftCardModel" test before running this test.
     * GET http://xxx/hmspass/v1/giftcard/model/{modelId}
     */
    @Test
    public void getGiftCardModel() {
        System.out.println("getGiftCardModel begin.");

        // ID of the gift card model you want to get.
        String modelId = "GiftCardTestModel";

        // Get the gift card model.
        String urlSegment = "/v1/giftcard/model/";
        JSONObject responseModel = serverApiService.getHwWalletObjectById(urlSegment, modelId);
        System.out.println("Corresponding gift card model: " + JSONObject.toJSONString(responseModel));
    }

    /**
     * Get gift card models belonging to a specific appId.
     * Run the "createGiftCardModel" test before running this test.
     * GET http://xxx/hmspass/v1/giftcard/model?session=XXX&pageSize=XXX
     */
    @Test
    public void getGiftCardModelList() {
        System.out.println("getGiftCardModelList begin.");

        // Get a list of gift card models.
        String urlSegment = "/v1/giftcard/model";

        JSONArray models = serverApiService.getModels(urlSegment, 5);
        System.out.println("Total models count: " + models.size());
        System.out.println("Models list: " + models.toJSONString());
    }

    /**
     * Overwrite a gift card model.
     * Run the "createGiftCardModel" test before running this test.
     * PUT http://xxx/hmspass/v1/giftcard/model/{modelId}
     */
    @Test
    public void fullUpdateGiftCardModel() {
        System.out.println("fullUpdateGiftCardModel begin.");

        // Read a HwWalletObject from a JSON file. This HwWalletObject will overwrite the corresponding model.
        JSONObject model = JSONObject.parseObject(ConfigUtil.readFile("FullUpdateGiftCardModel.json"));

        // Validate parameters.
        HwWalletObjectUtil.validateModel(model);

        // Update the gift card model.
        String urlSegment = "/v1/giftcard/model/";
        JSONObject responseModel = serverApiService.fullUpdateHwWalletObject(urlSegment,
            model.getString("passStyleIdentifier"), JSONObject.toJSONString(model));
        System.out.println("Updated gift card model: " + JSONObject.toJSONString(responseModel));
    }

    /**
     * Update a gift card model.
     * Run the "createGiftCardModel" test before running this test.
     * PATCH http://xxx/hmspass/v1/giftcard/model/{modelId}
     */
    @Test
    public void partialUpdateGiftCardModel() {
        System.out.println("partialUpdateGiftCardModel begin.");

        // ID of the gift card model you want to update.
        String modelId = "GiftCardTestModel";

        // Read a HwWalletObject from a JSON file. This HwWalletObject will merge with the corresponding model.
        String modelStr = ConfigUtil.readFile("PartialUpdateGiftCardModel.json");

        // Update the gift card model.
        String urlSegment = "/v1/giftcard/model/";
        JSONObject responseModel = serverApiService.partialUpdateHwWalletObject(urlSegment, modelId, modelStr);
        System.out.println("Updated gift card model: " + JSONObject.toJSONString(responseModel));
    }

    /**
     * Add messages to a gift card model.
     * Run the "createGiftCardModel" test before running this test.
     * POST http://xxx/hmspass/v1/giftcard/model/{modelId}/addMessage
     */
    @Test
    public void addMessageToGiftCardModel() {
        System.out.println("addMessageToGiftCardModel begin.");

        // ID of the gift card model you want to update.
        String modelId = "GiftCardTestModel";

        // Create a list of messages you want to add to a model. Each message contains key, value, and label.
        // The list should not contain multiple messages with the same key. You can update an existing message by adding
        // a new message with the same key. One model contains at most 10 messages. If a model already have 10 messages
        // and you keep adding new messages, the oldest messages will be removed. You should not add more than 10
        // messages at a time.

        // Read messages from a JSON file.
        String messagesStr = ConfigUtil.readFile("Messages.json");

        // Add messages to the gift card model.
        String urlSegment = "/v1/giftcard/model/";
        JSONObject responseModel = serverApiService.addMessageToHwWalletObject(urlSegment, modelId, messagesStr);
        System.out.println("Updated gift card model: " + JSONObject.toJSONString(responseModel));
    }
}
