/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
export enum ErrorCode {
  // The agreements are not accepted.
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001,
  // No HUAWEI ID has been signed in.
  ERROR_CODE_LOGIN_OUT = 1001502001,
  // A network exception occurs in the authorization API.
  AUTHENTICATION_NETWORK_ERROR = 1001502005,
  // Internal error.
  ERROR_CODE_INTERNAL_ERROR = 1001502009,
  // Authorization revoking is performed.
  ERROR_CODE_USER_CANCEL = 1001502012,
  // System service exception.
  ERROR_CODE_SYSTEM_SERVICE = 12300001,
  // Repeated request.
  ERROR_CODE_REQUEST_REFUSE = 1001500002
}
