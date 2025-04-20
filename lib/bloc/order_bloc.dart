import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/model/order_data.dart';
import '../data/repository/order_repo.dart';

// Events
abstract class OrderEvent {}

class LoadAllOrders extends OrderEvent {}

class LoadUserOrders extends OrderEvent {
  final String userId;
  LoadUserOrders(this.userId);
}

class SaveOrder extends OrderEvent {
  final Order order;
  SaveOrder(this.order);
}

class UpdateOrder extends OrderEvent {
  final Order order;
  UpdateOrder(this.order);
}

class StartOrdersStream extends OrderEvent {}

class StartUserOrdersStream extends OrderEvent {
  final String userId;
  StartUserOrdersStream(this.userId);
}

class OrdersUpdated extends OrderEvent {
  final List<Order> orders;
  OrdersUpdated(this.orders);
}

// States
abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  OrdersLoaded(this.orders);
}

class OrderOperationSuccess extends OrderState {
  final String message;
  OrderOperationSuccess(this.message);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

// Bloc
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final IOrderRepository _repository;
  StreamSubscription? _ordersSubscription;

  OrderBloc(this._repository) : super(OrderInitial()) {
    on<LoadAllOrders>(_onLoadAllOrders);
    on<LoadUserOrders>(_onLoadUserOrders);
    on<SaveOrder>(_onSaveOrder);
    on<StartOrdersStream>(_onStartOrdersStream);
    on<StartUserOrdersStream>(_onStartUserOrdersStream);
    on<OrdersUpdated>(_onOrdersUpdated);
    on<UpdateOrder>(_onUpdateOrder);
  }

  Future<void> _onLoadAllOrders(
      LoadAllOrders event,
      Emitter<OrderState> emit,
      ) async {
    emit(OrderLoading());
    try {
      final result = await _repository.getAllOrders();

      result.fold(
            (failure) => emit(OrderError(failure.message)),
            (orders) => emit(OrdersLoaded(orders)),
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onLoadUserOrders(
      LoadUserOrders event,
      Emitter<OrderState> emit,
      ) async {
    emit(OrderLoading());
    try {
      final result = await _repository.getUserOrders(event.userId);

      result.fold(
            (failure) => emit(OrderError(failure.message)),
            (orders) => emit(OrdersLoaded(orders)),
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrder(
      UpdateOrder event,
      Emitter<OrderState> emit,
      ) async {
    //emit(OrderLoading());
    try {
      final result = await _repository.updateOrder(event.order);

      result.fold(
            (failure) => emit(OrderError(failure.message)),
            (_) => emit(OrderOperationSuccess('Order Completed')),
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onSaveOrder(
      SaveOrder event,
      Emitter<OrderState> emit,
      ) async {
    emit(OrderLoading());
    try {
      final result = await _repository.saveOrder(event.order);

      result.fold(
            (failure) => emit(OrderError(failure.message)),
            (orderId) {
          emit(OrderOperationSuccess('Order saved successfully with ID: $orderId'));
        },
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  void _onStartOrdersStream(
      StartOrdersStream event,
      Emitter<OrderState> emit,
      ) {
    _cancelCurrentSubscription();

    _ordersSubscription = _repository.ordersStream().listen(
          (orders) {
        add(OrdersUpdated(orders));
      },
      onError: (error) {
        emit(OrderError(error.toString()));
      },
    );
  }

  void _onStartUserOrdersStream(
      StartUserOrdersStream event,
      Emitter<OrderState> emit,
      ) {
    _cancelCurrentSubscription();

    _ordersSubscription = _repository.userOrdersStream(event.userId).listen(
          (orders) {
        add(OrdersUpdated(orders));
      },
      onError: (error) {
        emit(OrderError(error.toString()));
      },
    );
  }

  void _onOrdersUpdated(
      OrdersUpdated event,
      Emitter<OrderState> emit,
      ) {
    emit(OrdersLoaded(event.orders));
  }

  void _cancelCurrentSubscription() {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
  }

  @override
  Future<void> close() {
    _cancelCurrentSubscription();
    return super.close();
  }
}