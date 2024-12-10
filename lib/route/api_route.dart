import 'package:tugas_api/app/http/controllers/customer_controllers.dart';
import 'package:tugas_api/app/http/controllers/product_controllers.dart';
import 'package:tugas_api/app/http/controllers/product_note_controllers.dart';
import 'package:tugas_api/app/http/controllers/vendor_controllers.dart';
import 'package:vania/vania.dart';
import 'package:tugas_api/app/http/controllers/home_controller.dart';
import 'package:tugas_api/app/http/middleware/authenticate.dart';
import 'package:tugas_api/app/http/middleware/home_middleware.dart';
import 'package:tugas_api/app/http/middleware/error_response_middleware.dart';

class ApiRoute implements Route {
  @override
  void register() {
    /// Base RoutePrefix
    Router.basePrefix('api');

    Router.get("/home", homeController.index);

    Router.get("/hello-world", () {
      return Response.html('Hello World');
    }).middleware([HomeMiddleware()]);

    // Return error code 400
    Router.get('wrong-request',
            () => Response.json({'message': 'Hi wrong request'}))
        .middleware([ErrorResponseMiddleware()]);

    // Return Authenticated user data
    Router.get("/user", () {
      return Response.json(Auth().user());
    }).middleware([AuthenticateMiddleware()]);

    Router.group(() {
      Router.get('/', customerControllers.index);
      Router.post('/', customerControllers.store);
      Router.put('/{id}', customerControllers.update);
      Router.delete('/{id}', customerControllers.destroy);
    }, prefix: '/customers');

    Router.group(() {
      Router.get('/', vendorControllers.index);
      Router.post('/', vendorControllers.store);
      Router.put('/{id}', vendorControllers.update);
      Router.delete('/{id}', vendorControllers.destroy);
    }, prefix: '/vendors');

    Router.group(() {
      Router.get('/', productControllers.index);
      Router.post('/', productControllers.store);
      Router.put('/{id}', productControllers.update);
      Router.delete('/{id}', productControllers.destroy);
    }, prefix: '/products');

    Router.group(() {
      Router.get('/', productNoteControllers.index);
      Router.post('/', productNoteControllers.store);
      Router.put('/{id}', productNoteControllers.update);
      Router.delete('/{id}', productNoteControllers.destroy);
    }, prefix: '/productNote');
  }
}
