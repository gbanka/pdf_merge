#import "PdfMergePlugin.h"
#if __has_include(<pdf_merge/pdf_merge-Swift.h>)
#import <pdf_merge/pdf_merge-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pdf_merge-Swift.h"
#endif

@implementation PdfMergePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPdfMergePlugin registerWithRegistrar:registrar];
}
@end
