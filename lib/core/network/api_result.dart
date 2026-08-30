/// A sealed success/failure wrapper returned by repository methods, so
/// Cubits handle outcomes explicitly instead of relying on thrown
/// exceptions crossing the data/presentation boundary.
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.message);

  final String message;
}
