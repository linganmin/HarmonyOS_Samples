import { ProductDetailModel } from "../model/BasicDataSource";
import { ProductDetailSource } from "../model/ProductDetailSource";

// [Start transition_scene_usually]
@Component
export struct TransitionScene {
  private productData: ProductDetailSource = new ProductDetailSource();

  aboutToAppear(): void {
    this.productData.getProductData();
  }

  build() {
    WaterFlow() {
      LazyForEach(this.productData, (item: ProductDetailModel) => {
        FlowItem() {
          // ...
        }
      }, (item: ProductDetailModel) => item.id.toString())
    }
    // ...
  }
}
// [End transition_scene_usually]