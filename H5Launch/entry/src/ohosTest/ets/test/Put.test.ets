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

export default function PutTest() {
  const KEY = 'PutTest';

  describe('PutTest', () => {
    beforeEach(async () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      await dataCache.clear();
    })

    it('put uint8array', 0, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = new Uint8Array();
      dataCache.put(KEY, data).then(() => {
        expect(dataCache.getSync(KEY)).assertInstanceOf('Uint8Array');
        done();
      });
    })

    it('put string', 1, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      dataCache.put(KEY, data).then(() => {
        expect(dataCache.getSync(KEY)).assertEqual(data);
        done();
      });
    })

    it('put boolean', 2, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = true;
      dataCache.put(KEY, data).then(() => {
        expect(dataCache.getSync(KEY)).assertEqual(data);
        done();
      });
    })

    it('put number', 3, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = 11;
      dataCache.put(KEY, data).then(() => {
        expect(dataCache.getSync(KEY)).assertEqual(data);
        done();
      });
    })

    it('put object', 4, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data: TestObjectData = {
        test: 'test'
      };
      await dataCache.put(KEY, data).then(() => {
        expect(dataCache.getSync<TestObjectData>(KEY)?.test).assertEqual(data.test);
        done();
      });
    })

    it('put when key is empty', 5, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      try {
        await dataCache.put('', data);
      } catch (error) {
        expect(error.code).assertEqual(15500000);
        done();
      }
    })

    it('put when value is empty', 6, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '';
      dataCache.put(KEY, data).then(() => {
        expect(true).assertTrue();
        done();
      });
    })

    it('put when cache is empty', 7, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      await dataCache.put(KEY, data);
      expect(dataCache.getSync(KEY)).assertEqual(data);
      done();
    })

    it('put when cache is not empty', 8, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      dataCache.putSync('key1', '222');
      const data = '111';
      await dataCache.put(KEY, data);
      expect(dataCache.getSync(KEY)).assertEqual(data);
      done();
    })

    it('put when key is repeat', 9, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      await dataCache.put(KEY, '222');
      const data = '111';
      await dataCache.put(KEY, data);
      expect(dataCache.getSync(KEY)).assertEqual(data);
      done();
    })
  })
}
