  #include "imagepicker.h"
  #import <Foundation/Foundation.h>
  #include <UIKit/UIKit.h>
  #include <qpa/qplatformnativeinterface.h>
  #include <QtGui>
  #include <QtQuick>
  #include <MobileCoreServices/MobileCoreServices.h>

  #define PICKER 6
  #define CAMERA 7

  @interface ImagePickerDelegate : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
                                       ImagePicker *m_imagePicker;
  }
- (id)initWithObject:(ImagePicker *)imagePicker;
  @end


  @implementation ImagePickerDelegate

  - (id) initWithObject:(ImagePicker *)imagePicker
  {
      self = [super init];
      if (self) {
          m_imagePicker = imagePicker;
      }
      return self;
  }





  - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
  {
      NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
      NSString *fileName = [NSString stringWithFormat:@"/image-%f.jpg", [[NSDate date] timeIntervalSince1970]];
      path = [path stringByAppendingString:fileName];
      UIImage *image = nil;
      if([info objectForKey:UIImagePickerControllerEditedImage])
      {
          image = [info objectForKey:UIImagePickerControllerEditedImage];
      }
      else
      {
          image = [info objectForKey:UIImagePickerControllerOriginalImage];
      }

      UIImage *uImage = [UIImage imageWithCGImage:[image CGImage]
              scale:1
              orientation:UIImageOrientationDown];
      [UIImageJPEGRepresentation(uImage, 1) writeToFile:path options:NSAtomicWrite error:nil];
      [picker dismissViewControllerAnimated:YES completion:nil];
      emit m_imagePicker->capturedImage(QString::fromNSString(path));
  }

  @end

  QT_BEGIN_NAMESPACE

  ImagePicker::ImagePicker(QQuickItem *parent) :
    QQuickItem(parent),
    m_delegate([[ImagePickerDelegate alloc] initWithObject:this])
  {

  }



  /**
   * @brief ImagePicker::openPicker
   */
  void ImagePicker::openPicker()
  {
      UIView *view = (__bridge UIView *) (QGuiApplication::platformNativeInterface()->nativeResourceForWindow("uiview", window()));
      UIViewController *qtController = [[view window] rootViewController];
      UIImagePickerController *imageController = [[UIImagePickerController alloc] init];
      [imageController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
      [imageController setAllowsEditing: YES];
      //[imageController setDelegate:(__bridge id)(m_delegate)];
      [imageController setDelegate:m_delegate];
      [imageController setMediaTypes: [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil]];
      [[imageController view] setTag:PICKER];
      [qtController presentViewController:imageController animated:YES completion:nil];

      UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
      [rootViewController presentViewController:imageController animated:YES completion:nil];

  }

  /**
   * @brief ImagePicker::openCamera
   */
  void ImagePicker::openCamera()
  {
      UIImagePickerController *imageController = [[UIImagePickerController alloc] init];
      [imageController setSourceType:UIImagePickerControllerSourceTypeCamera];
      [imageController setAllowsEditing: YES];
      [imageController setDelegate:m_delegate];
      //[imageController setDelegate:(__bridge id)(m_delegate)];

      [imageController setMediaTypes: [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil]];
      [[imageController view] setTag:CAMERA];

      UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
      [rootViewController presentViewController:imageController animated:YES completion:nil];
  }

  QT_END_NAMESPACE
