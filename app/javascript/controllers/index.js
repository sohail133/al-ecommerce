import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import AdminController from "./admin_controller"
application.register("admin", AdminController)

import DropdownController from "./dropdown_controller"
application.register("dropdown", DropdownController)

import FlashController from "./flash_controller"
application.register("flash", FlashController)
