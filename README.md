# CombineErgonomics
[![StreetEasy](https://circleci.com/gh/StreetEasy/combine-ergonomics.svg?style=shield&circle-token=213a75d2855fa385609c78813b678aa8edcabd25)](https://app.circleci.com/pipelines/github/StreetEasy/combine-ergonomics)
![](https://img.shields.io/badge/spm-compatible-green.svg)

This package contains useful extensions for Combine that make it easier to develop with and test.

To add this package to your project, go into your project settings and add the url `https://github.com/StreetEasy/combine-ergonomics.git` to your Swift Packages. To use it, just `import CombineErgonomics` at the top of your swift files.

## Benefits

### Attach handlers to Publishers

CombineErgonomics makes it easier to dispatch background tasks and handle their errors, with syntax inspired by [PromiseKit](https://github.com/mxcl/PromiseKit). For example, consider this class that facilitates login:
```swift
import Combine

class LoginHelper {

    var store = Set<AnyCancellable>()

    func login() {
        let future = Future<User, Error> { promise in
            // network call to log in
        }
        future.subscribe(on: DispatchQueue.global())
            .sink { completion in
                if case .failure(let error) = completion {
                    // handle error
                }
            } receiveValue: { user in
                // handle user logged in, i.e. update UI
            }
            .store(in: &store)
    }
}
```

Can be reduced to:

```swift
import Combine
import CombineErgonomics

class LoginHelper { 

    func login() {
        let future = Future<User, Error> { promise in
            // network call to log in
        }
        future.done { user in
            // handle user logged in, i.e. update UI
        }.catch { error in
            //handle error
        }
    }
}
```

### Chain together multiple Futures

Rather than using a chain of `Combine.FlatMap`, `Future`s can be neatly chained using the `.then` method.

```swift
import Combine
import CombineErgonomics

class LoginHelper { 

    func login() {
        let future = Future<User, Error> { promise in
            // network call to log in
        }
        future.then { user -> Future<ProfileImage, Error> in
            return ProfileImageHelper.fetchProfileImage(for: user)
        }.done { profileImage in 
            // update UI with new profile image
        }.catch { error in
            //handleError
        }
    }
}
```
