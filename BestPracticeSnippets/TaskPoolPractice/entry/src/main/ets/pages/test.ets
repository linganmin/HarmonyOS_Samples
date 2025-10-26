// [Start abc]
import { a } from './a';
import { b } from './b';
import { c } from './c';
// [End abc]
import { hilog } from '@kit.PerformanceAnalysisKit';
// [Start err]
import { BusinessError } from '@kit.BasicServicesKit';
// [End err]
// [Start abc]
@Concurrent
function concurrentFunc() {
  hilog.info(0xFF00, 'sampleTag', 'value: ' + a);
}
// [End abc]
function  copy(pathDir:string){
  let fs;
  // [Start src]
  let srcPath = pathDir + "/srcDir/test.txt";
  let dstPath = pathDir + "/dstDir/test.txt";

  fs.copyFileSync(srcPath, dstPath);
  // [End src]
}
function copyfile(pathDir:string){
  let fs;
  // [Start err]
  let srcPath = pathDir + "/srcDir/test.txt";
  let dstPath = pathDir + "/dstDir/test.txt";
  fs.copyFile(srcPath, dstPath, 0).then(() => {
    hilog.info(0xFF00, 'sampleTag', 'copy file succeed');
  }).catch((err: BusinessError) => {
    hilog.error(0xFF00, 'sampleTag', 'copy file failed with error message: ' + err.message + ', error code: ' + err.code);
  });
  // [End err]

}