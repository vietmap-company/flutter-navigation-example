import 'failure.dart';

class ApiServerFailure extends Failure {
  final String message;
  const ApiServerFailure(this.message);
}
