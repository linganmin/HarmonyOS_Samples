/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
export enum ErrorCode {
  // The operation for obtaining the shipping address is canceled.
  SHIPPING_ADDRESS_USER_CANCELED = 1008100006,
  // Authorization revoking is performed.
  AUTHENTICATION_USER_CANCELED = 1001502012,
  // The operation for obtaining the invoice title is canceled.
  INVOICE_ASSISTANT_USER_CANCELED = 1010060001,
  // The operation for obtaining the avatar is canceled.
  EXTEND_SERVICE_USER_CANCELED = 1001600005,
  // A network exception occurred in the API for obtaining the shipping address.
  SHIPPING_ADDRESS_NETWORK_ERROR = 1008100002,
  // A network exception occurs in the authorization API.
  AUTHENTICATION_NETWORK_ERROR = 1001502005,
  // A network exception occurred in the API for obtaining the invoice title.
  INVOICE_ASSISTANT_NETWORK_ERROR = 1010060005,
  // A network exception occurred in the API for obtaining the avatar.
  EXTEND_SERVICE_NETWORK_ERROR = 1001600001,
  // No HUAWEI ID has been signed in.
  ERROR_CODE_LOGIN_OUT = 1001502001,
  // Internal error.
  ERROR_CODE_INTERNAL_ERROR = 1001502009,
  // Authorization revoking is performed.
  ERROR_CODE_USER_CANCEL = 1001502012,
  // System service exception.
  ERROR_CODE_SYSTEM_SERVICE = 12300001,
  //  Repeated request.
  ERROR_CODE_REQUEST_REFUSE = 1001500002
}
