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
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContext } from '../testability/GlobalContext';

export default function DataCacheTest() {
  const KEY = 'instance';

  describe('DataCacheTest', () => {
    beforeEach(async () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      await dataCache.clear();
    })

    it('delete', 0, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      dataCache.putSync(KEY, data);
      dataCache.delete(KEY).then(() => {
        expect(dataCache.getSync('test')).assertUndefined();
        done();
      })
    })

    it('delete when key is empty', 1, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      dataCache.delete('').catch((error: BusinessError) => {
        expect(error.code).assertEqual(15500000);
        done();
      })
    })

    it('delete when key is not exit', 2, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      dataCache.delete(KEY).then(() => {
        expect(true).assertTrue();
        done();
      });
    })

    it('clear', 3, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      dataCache.putSync('test1', data);
      dataCache.putSync('test2', data);
      dataCache.clear().then(() => {
        expect(dataCache.getSync('test1')).assertUndefined();
        expect(dataCache.getSync('test2')).assertUndefined();
        done();
      })
    })

    it('clear when not cache', 4, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      dataCache.clear().then(() => {
        expect(true).assertTrue();
        done();
      });
    })
  })
}
