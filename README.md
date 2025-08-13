# Clean Cubit Reactor

**Clean Cubit Reactor** is a lightweight coordination layer between your `Repository` and multiple `Cubit`s.  
It automatically synchronizes their states without direct coupling between cubits and without manually triggering updates from the UI.

> 📂 See full code and examples in this repository.  

---

## Problem

In many real-world Flutter apps, a single screen is composed of multiple independent UI parts:

- A list of data
- A button to add or update an item
- A filter widget
- etc.

Often, these parts share the same data source but use **different cubits**:

- `LoadingCubit` — loads and displays data
- `UpdateCubit` — adds or updates items

The problem:  
When `UpdateCubit` changes the data, `LoadingCubit` is unaware of the change unless the UI manually triggers a reload (e.g., via a `BlocListener`).  
This breaks the separation of concerns — the UI should not manage business logic.

---

## Solution: Reactor

`Reactor` is an object that:

- Has a reference to a `Repository`
- Stores a local cache of the latest data
- Broadcasts updates **only** to cubits subscribed to the corresponding data type
- Automatically updates all subscribed cubits when the repository data changes

**Result:**

- Cubits don’t know about each other
- The UI stays simple
- Synchronization happens automatically

---

## How it works

> ![telegram-cloud-photo-size-2-5253519944413476335-y](https://github.com/user-attachments/assets/292aa484-e434-4e6d-96e6-bf937d3ea404)


---

## Example

### Reactor
```dart
class ItemsRepoReactor extends CubitReactor<ListenersType, ItemsBaseResponse> {
  Future<void> loadItems() async {
    setLoading(currentData: ItemsLoadResponse(data: last<ItemsLoadResponse>()?.data));
    final items = await repository.getItems();
    provideDataToListeners(ItemsLoadResponse(data: items));
  }

  Future<void> updateItem(Item item) async {
    setLoading(currentData: ItemsUpdateResponse(updateItem: item));
    final updatedItems = await repository.updateItem(item);
    provideDataToListeners(ItemsUpdateResponse(updateItem: item));
    provideDataToListeners(ItemsLoadResponse(data: updatedItems));
  }
}
```

### Cubit listening for load responses
```dart
class ItemsCubit extends CubitListener<ListenersType, ItemsLoadResponse, ItemsState> {
  ItemsCubit(this._reactor)
      : super(const ItemsInitial(), _reactor, ListenersType.loadListener);

  final ItemsRepoReactor _reactor;

  @override
  void emitOnResponse(ItemsLoadResponse response) {
    if (response.error != null) {
      emit(ItemsError(response.error!));
    } else {
      emit(ItemsLoaded(response.data ?? []));
    }
  }

  @override
  void setLoading({required ItemsLoadResponse data}) {
    emit(ItemsLoading(lastData: data.data));
  }
}
```

See [`example/`](./example) for a full working demo.

---

## Benefits

- **Single Responsibility** — small cubits, simple states
- **Automatic synchronization** — one update → all relevant cubits are notified
- **Flexible** — add new operation types (load, update, delete) with minimal changes
- **Local caching** — instant data delivery to new subscribers
- **No `rxdart` or `BehaviorSubject` required**

---

## Drawbacks

- Adds an extra layer to the architecture
- Cubits must unsubscribe in `close()` to avoid memory leaks
- New developers may need time to understand the `Cubit ↔ Reactor ↔ Repository` chain

---

## When to use

- Multiple independent UI components rely on the same data
- Automatic synchronization between cubits is important
- You want to avoid passing events through the UI layer

---

## License
MIT License.
