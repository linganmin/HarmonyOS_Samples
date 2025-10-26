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
import { GlobalContext, TestObjectData } from '../testability/GlobalContext';

export default function PutSyncTest() {
  const KEY = 'PutSyncTest';

  describe('PutSyncTest', () => {
    beforeEach(async () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      await dataCache.clear();
    })

    it('putSync uint8array', 0, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = new Uint8Array();
      dataCache.putSync(KEY, data);
      expect(dataCache.getSync(KEY)).assertInstanceOf('Uint8Array');
    })

    it('putSync string', 1, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      dataCache.putSync(KEY, data);
      expect(dataCache.getSync(KEY)).assertEqual(data);
    })

    it('putSync boolean', 2, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = true;
      dataCache.putSync(KEY, data);
      expect(dataCache.getSync(KEY)).assertEqual(data);
    })

    it('putSync number', 3, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = 12;
      dataCache.putSync(KEY, data);
      expect(dataCache.getSync(KEY)).assertEqual(data);
    })

    it('putSync object', 4, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data: TestObjectData = {
        test: 'test'
      };
      dataCache.putSync(KEY, data);
      expect(dataCache.getSync<TestObjectData>(KEY)?.test).assertEqual(data.test);
    })

    it('putSync when key is empty', 5, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      try {
        dataCache.putSync('', data);
      } catch (error) {
        expect(error.code).assertEqual(401);
      }
    })

    it('putSync when value is empty', 6, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '';
      try {
        dataCache.putSync(KEY, data);
      } catch (error) {
        expect(error.code).assertEqual(401);
      }
    })

    it('putSync when cache is empty', 7, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      dataCache.putSync(KEY, data);
      expect(dataCache.getSync(KEY)).assertEqual(data);
    })

    it('putSync when cache is not empty', 8, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      dataCache.putSync('key1', '222');
      const data = '111';
      dataCache.putSync(KEY, data);
      expect(dataCache.getSync(KEY)).assertEqual(data);
    })

    it('putSync when key is repeat', 9, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      dataCache.putSync(KEY, '222');
      const data = '111';
      dataCache.putSync(KEY, data);
      expect(dataCache.getSync(KEY)).assertEqual(data);
    })
  })
}
