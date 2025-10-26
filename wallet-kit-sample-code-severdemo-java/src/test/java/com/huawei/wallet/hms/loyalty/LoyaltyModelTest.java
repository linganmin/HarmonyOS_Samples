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

package com.huawei.wallet.hms.loyalty;

import com.huawei.wallet.hms.ServerApiService;
import com.huawei.wallet.hms.ServerApiServiceImpl;
import com.huawei.wallet.util.ConfigUtil;
import com.huawei.wallet.util.HwWalletObjectUtil;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import org.junit.Test;

/**
 * Loyalty model tests.
 *
 * @since 2019-12-12
 */
public class LoyaltyModelTest {
    private final ServerApiService serverApiService = new ServerApiServiceImpl();

    /**
     * Create a new loyalty model.
     * Each loyalty model indicates a style of loyalty passes.
     * POST http://XXX/hmspass/v1/loyalty/model
     */
    @Test
    public void createLoyaltyModel() {
        System.out.println("createLoyaltyModel begin.");

        // Read a loyalty model from a JSON file.
        JSONObject model = JSONObject.parseObject(ConfigUtil.readFile("LoyaltyModel.json"));

        // Validate parameters.
        HwWalletObjectUtil.validateModel(model);

        // Post the new loyalty model to HMS wallet server.
        String urlSegment = "/v1/loyalty/model";
        JSONObject responseModel = serverApiService.postToWalletServer(urlSegment, JSONObject.toJSONString(model));
        System.out.println("Posted loyalty model: " + JSONObject.toJSONString(responseModel));
    }

    /**
     * Get a loyalty model by its model ID.
     * Run the "createLoyaltyModel" test before running this test.
     * GET http://xxx/hmspass/v1/loyalty/model/{modelId}
     */
    @Test
    public void getLoyaltyModel() {
        System.out.println("getLoyaltyModel begin.");

        // ID of the loyalty model you want to get.
        String modelId = "LoyaltyTestModel";

        // Get the loyalty model.
        String urlSegment = "/v1/loyalty/model/";
        JSONObject responseModel = serverApiService.getHwWalletObjectById(urlSegment, modelId);
        System.out.println("Corresponding loyalty model: " + JSONObject.toJSONString(responseModel));
    }

    /**
     * Get loyalty models belonging to a specific appId.
     * Run the "createLoyaltyModel" test before running this test.
     * GET http://xxx/hmspass/v1/loyalty/model?session=XXX&pageSize=XXX
     */
    @Test
    public void getLoyaltyModelList() {
        System.out.println("getLoyaltyModelList begin.");

        // Get a list of loyalty models.
        String urlSegment = "/v1/loyalty/model";

        JSONArray models = serverApiService.getModels(urlSegment, 5);
        System.out.println("Total models count: " + models.size());
        System.out.println("Models list: " + models.toJSONString());
    }

    /**
     * Overwrite a loyalty model.
     * Run the "createLoyaltyModel" test before running this test.
     * PUT http://xxx/hmspass/v1/loyalty/model/{modelId}
     */
    @Test
    public void fullUpdateLoyaltyModel() {
        System.out.println("fullUpdateLoyaltyModel begin.");

        // Read a HwWalletObject from a JSON file. This HwWalletObject will overwrite the corresponding model.
        JSONObject model = JSONObject.parseObject(ConfigUtil.readFile("FullUpdateLoyaltyModel.json"));

        // Validate parameters.
        HwWalletObjectUtil.validateModel(model);

        // Update the loyalty model.
        String urlSegment = "/v1/loyalty/model/";
        JSONObject responseModel = serverApiService.fullUpdateHwWalletObject(urlSegment,
            model.getString("passStyleIdentifier"), JSONObject.toJSONString(model));
        System.out.println("Updated loyalty model: " + JSONObject.toJSONString(responseModel));
    }

    /**
     * Update a loyalty model.
     * Run the "createLoyaltyModel" test before running this test.
     * PATCH http://xxx/hmspass/v1/loyalty/model/{modelId}
     */
    @Test
    public void partialUpdateLoyaltyModel() {
        System.out.println("partialUpdateLoyaltyModel begin.");

        // ID of the loyalty model you want to update.
        String modelId = "LoyaltyTestModel";

        // Read a HwWalletObject from a JSON file. This HwWalletObject will merge with the corresponding model.
        String modelStr = ConfigUtil.readFile("PartialUpdateLoyaltyModel.json");

        // Update the loyalty model.
        String urlSegment = "/v1/loyalty/model/";
        JSONObject responseModel = serverApiService.partialUpdateHwWalletObject(urlSegment, modelId, modelStr);
        System.out.println("Updated loyalty model: " + JSONObject.toJSONString(responseModel));
    }

    /**
     * Add messages to a loyalty model.
     * Run the "createLoyaltyModel" test before running this test.
     * POST http://xxx/hmspass/v1/loyalty/model/{modelId}/addMessage
     */
    @Test
    public void addMessageToLoyaltyModel() {
        System.out.println("addMessageToLoyaltyModel begin.");

        // ID of the loyalty model you want to update.
        String modelId = "LoyaltyTestModel";

        // Create a list of messages you want to add to a model. Each message contains key, value, and label.
        // The list should not contain multiple messages with the same key. You can update an existing message by adding
        // a new message with the same key. One model contains at most 10 messages. If a model already have 10 messages
        // and you keep adding new messages, the oldest messages will be removed. You should not add more than 10
        // messages at a time.

        // Read messages from a JSON file.
        String messagesStr = ConfigUtil.readFile("Messages.json");

        // Add messages to the loyalty model.
        String urlSegment = "/v1/loyalty/model/";
        JSONObject responseModel = serverApiService.addMessageToHwWalletObject(urlSegment, modelId, messagesStr);
        System.out.println("Updated loyalty model: " + JSONObject.toJSONString(responseModel));
    }
}
