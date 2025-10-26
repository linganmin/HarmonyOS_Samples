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

package com.huawei.push.model.message.payload;

import java.util.ArrayList;
import java.util.List;

import static com.huawei.push.utils.CheckUtils.checkNotNull;

/**
 * Notification.
 */
public class Notification {
    private final String category;
    private final String title;
    private final String body;
    private final String image;
    private final Integer style;
    private final Integer notifyId;
    private final String profileId;
    private final List<String> inboxContent;
    private final ClickAction clickAction;
    private final Badge badge;

    private Notification(Builder builder) {
        this.category = checkNotNull(builder.category);
        this.title = checkNotNull(builder.title);
        this.body = checkNotNull(builder.body);
        this.image = builder.image;
        this.style = builder.style;
        this.notifyId = builder.notifyId;
        this.profileId = builder.profileId;
        this.inboxContent = builder.inboxContent;
        this.clickAction = checkNotNull(builder.clickAction);
        this.badge = builder.badge;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private String category;
        private String title;
        private String body;
        private String image;
        private Integer style;
        private Integer notifyId;
        private String profileId;
        private List<String> inboxContent;
        private ClickAction clickAction;
        private Badge badge;

        private Builder() {

        }

        public Builder category(Category category) {
            this.category = checkNotNull(category).name();
            return this;
        }

        public Builder title(String title) {
            this.title = title;
            return this;
        }

        public Builder body(String body) {
            this.body = body;
            return this;
        }

        public Builder image(String image) {
            this.image = image;
            return this;
        }

        public Builder style(Integer style) {
            this.style = style;
            return this;
        }

        public Builder notifyId(Integer notifyId) {
            this.notifyId = notifyId;
            return this;
        }

        public Builder profileId(String profileId) {
            this.profileId = profileId;
            return this;
        }

        public Builder addInboxContent(String inboxContent) {
            if (inboxContent == null) {
                throw new IllegalArgumentException();
            }
            if (this.inboxContent == null) {
                this.inboxContent = new ArrayList<>();
            }
            this.inboxContent.add(inboxContent);
            return this;
        }

        public Builder clickAction(ClickAction clickAction) {
            this.clickAction = clickAction;
            return this;
        }

        public Builder badge(Badge badge) {
            this.badge = badge;
            return this;
        }

        public Notification build() {
            return new Notification(this);
        }
    }

    public enum Category {
        IM(0), VOIP(1), SUBSCRIPTION(2), TRAVEL(3), HEALTH(4), WORK(5), ACCOUNT(6),
        EXPRESS(7), FINANCE(8), DEVICE_REMINDER(9), SYSTEM_REMINDER(10), MAIL(11),
        CUSTOMER_SERVICE(12), MARKETING(13), NEWS(14), CONTENT_RECOMMENDATION(15),
        SOCIAL_DYNAMICS(16), PROMO(17), PLAY_VOICE(18);

        private final int val;

        Category(int val) {
            this.val = val;
        }

        public int getVal() {
            return val;
        }
    }

    public String getCategory() {
        return category;
    }

    public String getTitle() {
        return title;
    }

    public String getBody() {
        return body;
    }

    public String getImage() {
        return image;
    }

    public Integer getStyle() {
        return style;
    }

    public Integer getNotifyId() {
        return notifyId;
    }

    public String getProfileId() {
        return profileId;
    }

    public List<String> getInboxContent() {
        return inboxContent;
    }

    public ClickAction getClickAction() {
        return clickAction;
    }

    public Badge getBadge() {
        return badge;
    }
}
