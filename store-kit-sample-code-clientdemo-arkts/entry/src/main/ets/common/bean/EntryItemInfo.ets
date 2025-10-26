/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

export class EntryItemInfo {
  itemId: string;
  itemName: Resource;
  itemClickAction: string;

  constructor(itemId: string, itemName: Resource, itemClickAction: string) {
    this.itemId = itemId;
    this.itemName = itemName;
    this.itemClickAction = itemClickAction;
  }
}