/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.model.message.delivery;

import java.util.List;

/**
 * Takeaways content
 */
public class Takeaways {
    private Integer status;

    private Integer expireTime;

    private String deliveryTime;

    private Long orderTime;

    private String amount;

    private Integer productCount;

    private String productName;

    private String productImg;

    private String merchantName;

    private String customerAddress;

    private String pickupNumber;

    private String pickupTime;

    private String remainOrders;

    private String waitTime;

    private String paymentEndTime;

    private Long realDeliveryTime;

    private Long cancelTime;

    private String cancelReason;

    private ClickButton button;

    private ClickButton clickAction;

    private List<ClickButton> appendButtons;

    public static Builder builder() {
        return new Builder();
    }

    public Takeaways(Builder builder) {
        this.status = builder.status;
        this.expireTime = builder.expireTime;
        this.deliveryTime = builder.deliveryTime;
        this.orderTime = builder.orderTime;
        this.amount = builder.amount;
        this.productCount = builder.productCount;
        this.productName = builder.productName;
        this.productImg = builder.productImg;
        this.merchantName = builder.merchantName;
        this.customerAddress = builder.customerAddress;
        this.pickupNumber = builder.pickupNumber;
        this.pickupTime = builder.pickupTime;
        this.remainOrders = builder.remainOrders;
        this.waitTime = builder.waitTime;
        this.paymentEndTime = builder.paymentEndTime;
        this.realDeliveryTime = builder.realDeliveryTime;
        this.cancelTime = builder.cancelTime;
        this.cancelReason = builder.cancelReason;
        this.button = builder.button;
        this.clickAction = builder.clickAction;
        this.appendButtons = builder.appendButtons;
    }

    public static final class Builder {
        private Integer status;

        private Integer expireTime;

        private String deliveryTime;

        private Long orderTime;

        private String amount;

        private Integer productCount;

        private String productName;

        private String productImg;

        private String merchantName;

        private String customerAddress;

        private String pickupNumber;

        private String pickupTime;

        private String remainOrders;

        private String waitTime;

        private String paymentEndTime;

        private Long realDeliveryTime;

        private Long cancelTime;

        private String cancelReason;

        private ClickButton button;

        private ClickButton clickAction;

        private List<ClickButton> appendButtons;

        public Builder status(Integer status) {
            this.status = status;
            return this;
        }

        public Builder expireTime(Integer expireTime) {
            this.expireTime = expireTime;
            return this;
        }

        public Builder deliveryTime(String deliveryTime) {
            this.deliveryTime = deliveryTime;
            return this;
        }

        public Builder orderTime(Long orderTime) {
            this.orderTime = orderTime;
            return this;
        }

        public Builder amount(String amount) {
            this.amount = amount;
            return this;
        }

        public Builder productCount(Integer productCount) {
            this.productCount = productCount;
            return this;
        }

        public Builder productName(String productName) {
            this.productName = productName;
            return this;
        }

        public Builder productImg(String productImg) {
            this.productImg = productImg;
            return this;
        }

        public Builder merchantName(String merchantName) {
            this.merchantName = merchantName;
            return this;
        }

        public Builder customerAddress(String customerAddress) {
            this.customerAddress = customerAddress;
            return this;
        }

        public Builder pickupNumber(String pickupNumber) {
            this.pickupNumber = pickupNumber;
            return this;
        }

        public Builder pickupTime(String pickupTime) {
            this.pickupTime = pickupTime;
            return this;
        }

        public Builder remainOrders(String remainOrders) {
            this.remainOrders = remainOrders;
            return this;
        }

        public Builder waitTime(String waitTime) {
            this.waitTime = waitTime;
            return this;
        }

        public Builder paymentEndTime(String paymentEndTime) {
            this.paymentEndTime = paymentEndTime;
            return this;
        }

        public Builder realDeliveryTime(Long realDeliveryTime) {
            this.realDeliveryTime = realDeliveryTime;
            return this;
        }

        public Builder cancelTime(Long cancelTime) {
            this.cancelTime = cancelTime;
            return this;
        }

        public Builder cancelReason(String cancelReason) {
            this.cancelReason = cancelReason;
            return this;
        }

        public Builder button(ClickButton button) {
            this.button = button;
            return this;
        }

        public Builder clickAction(ClickButton clickAction) {
            this.clickAction = clickAction;
            return this;
        }

        public Builder appendButtons(List<ClickButton> appendButtons) {
            this.appendButtons = appendButtons;
            return this;
        }

        public Takeaways build() {
            return new Takeaways(this);
        }
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer getExpireTime() {
        return expireTime;
    }

    public void setExpireTime(Integer expireTime) {
        this.expireTime = expireTime;
    }

    public String getDeliveryTime() {
        return deliveryTime;
    }

    public void setDeliveryTime(String deliveryTime) {
        this.deliveryTime = deliveryTime;
    }

    public Long getOrderTime() {
        return orderTime;
    }

    public void setOrderTime(Long orderTime) {
        this.orderTime = orderTime;
    }

    public String getAmount() {
        return amount;
    }

    public void setAmount(String amount) {
        this.amount = amount;
    }

    public Integer getProductCount() {
        return productCount;
    }

    public void setProductCount(Integer productCount) {
        this.productCount = productCount;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductImg() {
        return productImg;
    }

    public void setProductImg(String productImg) {
        this.productImg = productImg;
    }

    public String getMerchantName() {
        return merchantName;
    }

    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }

    public String getCustomerAddress() {
        return customerAddress;
    }

    public void setCustomerAddress(String customerAddress) {
        this.customerAddress = customerAddress;
    }

    public String getPickupNumber() {
        return pickupNumber;
    }

    public void setPickupNumber(String pickupNumber) {
        this.pickupNumber = pickupNumber;
    }

    public String getPickupTime() {
        return pickupTime;
    }

    public void setPickupTime(String pickupTime) {
        this.pickupTime = pickupTime;
    }

    public String getRemainOrders() {
        return remainOrders;
    }

    public void setRemainOrders(String remainOrders) {
        this.remainOrders = remainOrders;
    }

    public String getWaitTime() {
        return waitTime;
    }

    public void setWaitTime(String waitTime) {
        this.waitTime = waitTime;
    }

    public String getPaymentEndTime() {
        return paymentEndTime;
    }

    public void setPaymentEndTime(String paymentEndTime) {
        this.paymentEndTime = paymentEndTime;
    }

    public Long getRealDeliveryTime() {
        return realDeliveryTime;
    }

    public void setRealDeliveryTime(Long realDeliveryTime) {
        this.realDeliveryTime = realDeliveryTime;
    }

    public Long getCancelTime() {
        return cancelTime;
    }

    public void setCancelTime(Long cancelTime) {
        this.cancelTime = cancelTime;
    }

    public String getCancelReason() {
        return cancelReason;
    }

    public void setCancelReason(String cancelReason) {
        this.cancelReason = cancelReason;
    }

    public ClickButton getButton() {
        return button;
    }

    public void setButton(ClickButton button) {
        this.button = button;
    }

    public ClickButton getClickAction() {
        return clickAction;
    }

    public void setClickAction(ClickButton clickAction) {
        this.clickAction = clickAction;
    }

    public List<ClickButton> getAppendButtons() {
        return appendButtons;
    }

    public void setAppendButtons(List<ClickButton> appendButtons) {
        this.appendButtons = appendButtons;
    }
}
