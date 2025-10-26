@rem Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
@echo off

hdc shell mount -o rw,remount /
hdc target mount

hdc shell "touch /data/service/el2/100/../../bbb.txt"
hdc shell "touch /data/service/el2/100/hmdfs/account/files/Docs/Documents/aaa.txt"
hdc shell "touch /data/service/el2/100/hmdfs/account/files/Docs/Documents/bbb.txt"
hdc shell "touch /data/service/el2/100/hmdfs/account/files/Docs/Documents/ccc.txt"
hdc shell "touch /data/service/el2/100/hmdfs/account/files/Docs/Documents/test_8.png"
hdc shell "touch /data/service/el2/100/hmdfs/account/files/Docs/Documents/test_1.docx"
hdc shell "touch /data/service/el2/100/hmdfs/account/files/Docs/Documents/bbb.docx"
hdc shell "touch /data/service/el2/100/hmdfs/account/files/Docs/Documents/ccc.docx"

hdc shell param set const.edm.is_hwit_device true
hdc shell param set const.pc_security.fileguard_force_enable true
hdc shell "rm /data/service/el1/public/file_guard/policy_store.json"
hdc shell "pkill file_guard"

hdc shell mkdir -p /data/service/el2/
hdc file send test.json /data/service/el2/test.json
hdc file send .\screenshot\test_water.png /data/service/el2/test_water.png
