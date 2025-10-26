/**
 * FAQ:如何通过AKI三方库实现ArkTS与C/C++之间的跨语言调用
 */
// [Start aki_jsbind]
#include <aki/jsbind.h> 
#include <string>
// 1、User defined business 
std::string SayHello(std::string msg){  return msg + " too.";}  
 
// 2、Export business interface
// Step 1: Register the AKI plugin
JSBIND_ADDON(entry) // Register AKI plugin name: This is the compiled *. so name, following the same rules as Node API
 
// Step 2: Register FFI Features
JSBIND_GLOBAL() 
{ 
  JSBIND_FUNCTION(SayHello); 
}
// [End aki_jsbind]
