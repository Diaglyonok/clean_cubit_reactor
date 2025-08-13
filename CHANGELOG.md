## 1.0.0

- Initial release of **Clean Cubit Reactor**.
- Provides a `Reactor` abstraction for coordinating data updates between multiple `Cubit`s without direct coupling.
- Includes:
  - `Reactor` base mixin
  - `CubitListener` for subscribing cubits to specific response types
  - Local caching and session history support
  - Example project demonstrating usage with `ItemsCubit` and `UpdateItemCubit`