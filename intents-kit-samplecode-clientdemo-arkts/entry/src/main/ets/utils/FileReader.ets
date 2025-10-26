import type { BusinessError } from '@kit.BasicServicesKit';
import type { Context } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';

export class FileReader {
  public static async readJson(context: Context, fileName: string): Promise<string> {
    try {
      return await FileReader.readJsonFile(context.getApplicationContext().filesDir + "/" + fileName);
    } catch (error) {
      return await FileReader.readRawFile(context, 'config/' + fileName);
    }
  }

  private static async readJsonFile(filePath: string): Promise<string> {
    return await fileIo.readText(filePath).then(str => {
      return Promise.resolve(str);
    }).catch((err: BusinessError) => {
      console.log("readText failed with error:" + err);
      return Promise.reject("readText failed with error:" + err);
    });
  }

  private static async readRawFile(moduleContext: Context, filePath: string): Promise<string> {
    return buffer.from((await moduleContext.resourceManager.getRawFileContent(filePath)).buffer)?.toString();
  }
}
