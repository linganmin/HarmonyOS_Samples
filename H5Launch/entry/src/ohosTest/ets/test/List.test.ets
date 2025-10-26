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
import AverageTimeTest from './AverageTime.test';

import DataCacheTest from './DataCache.test';
import GetTest from './Get.test';
import GetInstanceTest from './GetInstance.test';
import GetSyncTest from './GetSync.test';
import PutTest from './Put.test';
import PutHasSaveTimeTest from './PutHasSaveTime.test';
import PutSyncTest from './PutSync.test';
import PutSyncHasSaveTimeTest from './PutSyncHasSaveTime.test';

export default function testsuite() {
  GetInstanceTest();
  GetTest();
  GetSyncTest();
  PutTest();
  PutHasSaveTimeTest();
  PutSyncTest();
  PutSyncHasSaveTimeTest();
  DataCacheTest();
  AverageTimeTest();
}

