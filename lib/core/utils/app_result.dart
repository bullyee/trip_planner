sealed class AppResult<T> {
  const AppResult();
}

class Success<T> extends AppResult<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends AppResult<T> {
  final String error;
  final StackTrace? stackTrace;
  
  const Failure(this.error, [this.stackTrace]);
}