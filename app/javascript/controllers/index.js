import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import AdminController from "./admin_controller"
application.register("admin", AdminController)

import DropdownController from "./dropdown_controller"
application.register("dropdown", DropdownController)

import FlashController from "./flash_controller"
application.register("flash", FlashController)

import FlashToastController from "./flash_toast_controller"
application.register("flash-toast", FlashToastController)

import HeroSliderController from "./hero_slider_controller"
application.register("hero-slider", HeroSliderController)

import ReviewsSliderController from "./reviews_slider_controller"
application.register("reviews-slider", ReviewsSliderController)

import FilterAccordionController from "./filter_accordion_controller"
application.register("filter-accordion", FilterAccordionController)

import CartVariantController from "./cart_variant_controller"
application.register("cart-variant", CartVariantController)

import RowClickController from "./row_click_controller"
application.register("row-click", RowClickController)

import TabsController from "./tabs_controller"
application.register("tabs", TabsController)

import RatingController from "./rating_controller"
application.register("rating", RatingController)

import ProductVariantController from "./product_variant_controller"
application.register("product-variant", ProductVariantController)

import FavoriteController from "./favorite_controller"
application.register("favorite", FavoriteController)
