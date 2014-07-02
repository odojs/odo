# Odo frontend components
These files and folders are hosted at `/odo` by the public backend plugin, which also hosts a local `/public` folder.

## Auth
The Auth component is an API for performing authentication and authorisation activities such as changing email address, resetting passwords and disconnecting authentication providers. This API may change in the future.

## Durandal
The durandal folder provides several enhancements to the infrastructure provided by [durandal](http://durandaljs.com/).

See the [durandal front end folder](https://github.com/tcoats/odo/tree/master/public/durandal) for more information.

## Href
A utility to decompose the current url into it's pieces - protocol, subdomain, domain, etc.

## Humanize
A collection of formatting functions to make things human readable. It does things like `[1, 2, 3] => "1, 2, and 3"`.

## Inject
A wrapper for [injectinto](https://github.com/tcoats/injectinto), a dependency injection technique useful for providing extension points for cross app integration.
