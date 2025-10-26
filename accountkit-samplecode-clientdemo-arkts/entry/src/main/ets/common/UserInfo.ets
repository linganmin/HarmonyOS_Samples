/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
export interface UserInfo {
  isSilentLogin: boolean; // Specify whether to use silent sign-in.
  avatar?: string; // Avatar.
  nickName?: string; // Nickname.
  quickLoginAnonymousPhone?: string; // Anonymous mobile number.
}
