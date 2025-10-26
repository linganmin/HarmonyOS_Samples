import { MovingPhotoView, MovingPhotoViewController, photoAccessHelper } from '@kit.MediaLibraryKit';

@Entry
@Component
struct MovingPhotoPage {
  // [Start moving_photo_view_controller]
  @State src: photoAccessHelper.MovingPhoto | undefined = undefined;
  controller: MovingPhotoViewController = new MovingPhotoViewController();

  // [End moving_photo_view_controller]

  build() {
    Column() {
      // [Start moving_photo_view]
      MovingPhotoView({
        movingPhoto: this.src,
        controller: this.controller
      })
      // [End moving_photo_view]
    }
  }
}