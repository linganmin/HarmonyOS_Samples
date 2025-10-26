/*
 * The MIT License (MIT)
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 */

import { describe, it, expect, beforeEach } from '@ohos/hypium'
import { DataCache } from '@hadss/datacache';
import { GlobalContext } from '../testability/GlobalContext';

export default function GetInstanceTest() {

  describe('GetInstanceTest', () => {
    beforeEach(async () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      await dataCache.clear();
    })

    it('getInstance method success', 0, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      expect(dataCache instanceof DataCache).assertTrue();
    })

    it('getInstance method when param error', 1, () => {
      try {
        DataCache.getInstance({} as Context);
      } catch (error) {
        expect(error.code).assertEqual(401);
      }
    })
  })
}
