/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { functionalButtonComponentManager } from '@kit.ScenarioFusionKit';

export interface UserInfo {
  avatar?: string; // Avatar.
  phone?: string; // Mobile number
  address?: functionalButtonComponentManager.ChooseAddressResult; // Shipping address.
  invoiceTitle?: functionalButtonComponentManager.ChooseInvoiceTitleResult; // Invoice title.
}
