// [Start create_resource_config]
import { webview } from '@kit.ArkWeb';

export interface ResourceConfig {
  urlList: Array<string>,
  type: webview.OfflineResourceType,
  responseHeaders: Array<Header>,
  localPath: string,
}


export interface ExceptionResource {
  console: string,
  urlList: Array<string> | undefined | null;
  type: webview.OfflineResourceType  | undefined | null,
  responseHeaders: Array<Header> | undefined | null,
  resource?: Uint8Array | undefined | null
  localPath?: string,
}


export const baseURL: string = 'http://localhost:8083/resource/';
export const baseURL1: string = 'http://localhost:8083/resource/';


export const basicResources: Array<ResourceConfig> = [
  {
    localPath: "in_cache_middle.png",
    urlList: [
      baseURL,
      baseURL + "request.png",
      baseURL1 + "request.png",
    ],
    type: webview.OfflineResourceType.IMAGE,
    responseHeaders: []
  },
  {
    localPath: "in_cache.js",
    urlList: [
      baseURL,
      baseURL + "request.js",
      baseURL1 + "request.js"
    ],
    type: webview.OfflineResourceType.CLASSIC_JS,
    responseHeaders: [
      {headerKey: "Content-Type", headerValue: "text/javascript" },
      {headerKey: "Cache-Control", headerValue: "max-age=100000" },
    ]
  },
  {
    localPath: "in_cache_module1.js",
    urlList: [
      baseURL + "request_module1.js",
    ],
    type: webview.OfflineResourceType.MODULE_JS,
    responseHeaders: [
      {headerKey: "Content-Type", headerValue: "application/javascript" },
      {headerKey: "Access-Control-Allow-Origin" , headerValue: "*"},
      {headerKey: "Cache-Control", headerValue: "max-age=100000" },
    ]
  },
  {
    localPath: "in_cache_module2.js",
    urlList: [
      baseURL + "request_module2.js",
    ],
    type: webview.OfflineResourceType.MODULE_JS,
    responseHeaders: [
      {headerKey: "Content-Type", headerValue: "application/javascript" },
      {headerKey: "Access-Control-Allow-Origin" , headerValue: "*"},
      {headerKey: "Cache-Control", headerValue: "max-age=100000" },
    ]
  },
  {
    localPath: "in_cache.css",
    urlList: [
      baseURL,
      baseURL + "request.css",
      baseURL1 + "request.css",
    ],
    type: webview.OfflineResourceType.CSS,
    responseHeaders: [
      {headerKey: "resource-Type", headerValue: "text/css" },
      {headerKey: "Cache-Control", headerValue: "max-age=100000" },
    ]
  },
];
// [End create_resource_config]

// [Start inject_offline_resource]
// Call the offline resource injection cache interface
export async function injectOfflineResource(controller: WebviewController, resourceMapArr: Array<webview.OfflineResourceMap>): Promise<void> {
  try {
    controller.injectOfflineResources(resourceMapArr);
  } catch (err) {
    console.error("qqq injectOfflineResource error: " + err.code + " " + err.message);
  }
}
// [End inject_offline_resource]