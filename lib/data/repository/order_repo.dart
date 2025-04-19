import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import '../failure.dart';
import '../model/order_data.dart' as model; // Add alias here

abstract class IOrderRepository {
  Future<Either<Failure, List<model.Order>>> getAllOrders(); // Use alias
  Future<Either<Failure, List<model.Order>>> getUserOrders(String userId);
  Future<Either<Failure, String>> saveOrder(model.Order order);
  Stream<List<model.Order>> ordersStream();
  Stream<List<model.Order>> userOrdersStream(String userId);
}

class OrderRepository implements IOrderRepository {
  final FirebaseDatabase _database;
  final String _dbPath = 'orders';

  OrderRepository(this._database);

  @override
  Future<Either<Failure, List<model.Order>>> getAllOrders() async {
    try {
      final snapshot = await _database.ref().child(_dbPath).get();

      if (snapshot.value == null) {
        return Right([]);
      }

      final ordersData = Map<String, dynamic>.from(snapshot.value as Map);
      final orders = ordersData.entries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value as Map);
        data['orderId'] = entry.key;
        return model.Order.fromJson(data); // Use alias
      }).toList();

      return Right(orders);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch orders: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<model.Order>>> getUserOrders(String userId) async {
    try {
      final snapshot = await _database
          .ref()
          .child(_dbPath)
          .orderByChild('customerId')
          .equalTo(userId)
          .get();

      if (snapshot.value == null) {
        return Right([]);
      }

      final ordersData = Map<String, dynamic>.from(snapshot.value as Map);
      final orders = ordersData.entries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value as Map);
        data['orderId'] = entry.key;
        return model.Order.fromJson(data); // Use alias
      }).toList();

      return Right(orders);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch user orders: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> saveOrder(model.Order order) async { // Use alias
    try {
      final newOrderRef = _database.ref().child(_dbPath).push();
      await newOrderRef.set(order.toJson());
      return Right(newOrderRef.key!);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save order: ${e.toString()}'));
    }
  }

  @override
  Stream<List<model.Order>> ordersStream() { // Use alias
    return _database.ref().child(_dbPath).onValue.map((event) {
      if (event.snapshot.value == null) {
        return [];
      }

      final ordersData = Map<String, dynamic>.from(event.snapshot.value as Map);
      return ordersData.entries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value as Map);
        data['orderId'] = entry.key;
        return model.Order.fromJson(data); // Use alias
      }).toList();
    });
  }

  @override
  Stream<List<model.Order>> userOrdersStream(String userId) { // Use alias
    return _database
        .ref()
        .child(_dbPath)
        .orderByChild('customerId')
        .equalTo(userId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        return [];
      }

      final ordersData = Map<String, dynamic>.from(event.snapshot.value as Map);
      return ordersData.entries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value as Map);
        data['orderId'] = entry.key;
        return model.Order.fromJson(data); // Use alias
      }).toList();
    });
  }
}