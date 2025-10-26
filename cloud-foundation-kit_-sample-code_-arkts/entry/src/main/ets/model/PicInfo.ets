/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { cloudDatabase } from '@kit.CloudFoundationKit';

class PicInfo extends cloudDatabase.DatabaseObject {
  public id: number | undefined;
  public picName: string | undefined;
  public price: number | undefined;

  public naturalbase_ClassName(): string {
    return 'PicInfo';
  }
}

export { PicInfo };