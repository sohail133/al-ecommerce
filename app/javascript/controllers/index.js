import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import AdminController from "./admin_controller"
application.register("admin", AdminController)
