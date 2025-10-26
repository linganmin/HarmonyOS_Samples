export default {
  readSync: (fd: number, arrayBuffer: ArrayBuffer)=>{
    let mockJsonObj: object = {
      'file_to_open': [
        "/data/service/el2/100/hmdfs/account/files/Documents/aaa.txt",
      ],
      'kia_filelist': [
        "/data/service/el2/100/hmdfs/account/files/Docs/Documents/aaa.txt"
      ],
      'kia_keyword': [
        "key1",
      ],
      'kia_suffix': [
        "suffix1",
      ],
      "set_kia_tag": [{
          "tag": "this is a kia"
      }],
      "query_kia_tag": [
        "/data/service/el2/100/hmdfs/account/files/Documents/aaa.txt",
        "/data/service/el2/100/hmdfs/account/files/Documents/bbb.txt"
      ],
      "file_to_delete": [
        "/data/service/el2/100/hmdfs/account/files/Documents/ccc.txt"
      ],
      "update_policy": {
        "default_policy": 1
      },
      "add_net_policy": {
        "netsegment_update_type": 1,
      },
      "query_file_uri": [
        "/data/service/el2/100/hmdfs/account/files/Documents/aaa.txt"
      ]
    }
    let mockJsonStr: string = JSON.stringify(mockJsonObj)
    let bufferView = new Uint8Array(arrayBuffer);
    for (var i = 0; i < mockJsonStr.length; i++) {
      bufferView[i] = mockJsonStr.charCodeAt(i);
    }
    return mockJsonStr.length;
  }
}
