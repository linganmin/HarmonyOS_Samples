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

export default function PutSyncHasSaveTimeTest() {
  const KEY = 'PutSyncHasSaveTimeTest';

  describe('PutSyncHasSaveTimeTest', () => {
    beforeEach(async () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      await dataCache.clear();
    })

    it('putSync uint8array save 1s', 0, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = new Uint8Array();
      dataCache.putSync(KEY, data, 1);
      expect(dataCache.getSync(KEY)).assertInstanceOf('Uint8Array');
      await new Promise<void>((resolve) => {
        setTimeout(() => {
          resolve();
        }, 2100);
      });
      expect(dataCache.getSync(KEY)).assertUndefined();
      done();
    })

    it('putSync string save 1s', 1, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      dataCache.putSync(KEY, data, 1);
      expect(dataCache.getSync(KEY)).assertEqual(data);
      await new Promise<void>((resolve) => {
        setTimeout(() => {
          resolve();
        }, 2100);
      });
      expect(dataCache.getSync(KEY)).assertUndefined();
      done();
    })

    it('putSync boolean save 1s', 2, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = false;
      dataCache.putSync(KEY, data, 1);
      expect(dataCache.getSync(KEY)).assertEqual(data);
      await new Promise<void>((resolve) => {
        setTimeout(() => {
          resolve();
        }, 2100);
      }).then(() => {
        expect(dataCache.getSync(KEY)).assertUndefined();
        done();
      });
    })

    it('putSync number save 1s', 3, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = 111;
      dataCache.putSync(KEY, data, 1);
      expect(dataCache.getSync(KEY)).assertEqual(data);
      await new Promise<void>((resolve) => {
        setTimeout(() => {
          resolve();
        }, 2100);
      }).then(() => {
        expect(dataCache.getSync(KEY)).assertUndefined();
        done();
      });
    })

    it('putSync object save 1s', 4, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data: TestObjectData = {
        test: 'test'
      };
      dataCache.putSync(KEY, data, 1);
      expect(dataCache.getSync<TestObjectData>(KEY)?.test).assertEqual(data.test);
      await new Promise<void>((resolve) => {
        setTimeout(() => {
          resolve();
        }, 2100);
      }).then(() => {
        expect(dataCache.getSync(KEY)).assertUndefined();
        done();
      });
    })

    it('putSync when key is empty', 5, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      try {
        dataCache.putSync('', data, 1);
      } catch (error) {
        expect(error.code).assertEqual(401);
      }
    })

    it('putSync when value is empty', 6, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '';
      try {
        dataCache.putSync(KEY, data, 1);
      } catch (error) {
        expect(error.code).assertEqual(401);
      }
    })

    it('putSync when cache is empty', 8, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      dataCache.putSync(KEY, data, 1);
      expect(dataCache.getSync(KEY)).assertEqual(data);
    })

    it('putSync when cache is not empty', 9, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      dataCache.putSync('key1', '222');
      const data = '111';
      dataCache.putSync(KEY, data, 1);
      expect(dataCache.getSync(KEY)).assertEqual(data);
    })

    it('putSync when key is repeat', 10, () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      dataCache.putSync(KEY, '222', 1);
      const data = '111';
      dataCache.putSync(KEY, data, 1);
      expect(dataCache.getSync(KEY)).assertEqual(data);
    })
  })
}
