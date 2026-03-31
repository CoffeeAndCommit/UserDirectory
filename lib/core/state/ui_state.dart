abstract class UIState<T> {}

class UIInitial<T> extends UIState<T> {}

class UILoading<T> extends UIState<T> {}

class UISuccess<T> extends UIState<T> {
  final T data;
  UISuccess(this.data);
}

class UIEmpty<T> extends UIState<T> {}

class UIError<T> extends UIState<T> {
  final String message;
  UIError(this.message);
}
