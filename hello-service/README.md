1. Build the service using `.ci-cd/build.shh`  command
1. Push the service to the registry using `.ci-cd/push.sh` command
1. Deploy the service using `.ci-cd/deploy.sh` command
1. Test the service using `http http://hello.local.gd` command


# About Gin

The control flow for a typical web application, API server or a microservice looks as follows:

Request -> Route Parser -> [Optional Middleware] -> Route Handler -> [Optional Middleware] -> Response

When a request comes in, Gin first parses the route. If a matching route definition is found, Gin invokes the route handler and zero or more middleware in an order defined by the route definition. We will see how this is done when we take a look at the code in a later section.

unctionalities offered by Gin:

Routing — to handle various URLs,
Custom rendering — to handle the response format, and
Middleware — to implement authentication.