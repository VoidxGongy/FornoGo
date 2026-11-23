import 'package:cloud_firestore/cloud_firestore.dart';

import 'campos_firestore.dart';

/// Existencias actuales en inventario/{productoId}.
class Inventario {
  final String productoId;
  final int existencias;
  final int stockMinimo;
  final DateTime? actualizadoEn;

  Inventario({
    required this.productoId,
    required this.existencias,
    required this.stockMinimo,
    this.actualizadoEn,
  }) {
    idCatalogoDesdeDocumento(productoId, null);
    RangeError.checkNotNegative(existencias, 'existencias');
    RangeError.checkNotNegative(stockMinimo, 'stockMinimo');
  }

  bool get stockBajo => existencias <= stockMinimo;

  /// stockBajo se materializa para consultar alertas con where.
  Map<String, dynamic> toMap() => {
        'existencias': existencias,
        'stockMinimo': stockMinimo,
        'stockBajo': stockBajo,
        if (actualizadoEn != null)
          'actualizadoEn': Timestamp.fromDate(actualizadoEn!),
      };

  factory Inventario.fromMap(
    Map<String, dynamic> datos, {
    required String productoId,
  }) {
    final inventario = Inventario(
      productoId: productoId,
      existencias: datos['existencias'] as int,
      stockMinimo: datos['stockMinimo'] as int,
      actualizadoEn: fechaDesdeFirestore(datos['actualizadoEn']),
    );
    if (datos['stockBajo'] != inventario.stockBajo) {
      throw const FormatException('La alerta de inventario es inconsistente.');
    }
    return inventario;
  }
}

enum TipoMovimientoInventario { entrada, venta, devolucion, ajuste }

/// Evento auditable en inventario/{productoId}/movimientos/{id}.
class MovimientoInventario {
  final String id;
  final String productoId;
  final TipoMovimientoInventario tipo;
  final int cantidadDelta;
  final int existenciasAnteriores;
  final String? pedidoId;
  final String? usuarioId;
  final String? motivo;
  final DateTime? fecha;

  MovimientoInventario({
    required this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidadDelta,
    required this.existenciasAnteriores,
    this.pedidoId,
    this.usuarioId,
    this.motivo,
    this.fecha,
  }) {
    idCatalogoDesdeDocumento(productoId, null);
    RangeError.checkNotNegative(existenciasAnteriores, 'existenciasAnteriores');
    RangeError.checkNotNegative(
        existenciasResultantes, 'existenciasResultantes');
    if (cantidadDelta == 0 ||
        (tipo == TipoMovimientoInventario.venta && cantidadDelta > 0) ||
        ((tipo == TipoMovimientoInventario.entrada ||
                tipo == TipoMovimientoInventario.devolucion) &&
            cantidadDelta < 0)) {
      throw ArgumentError.value(
          cantidadDelta, 'cantidadDelta', 'Signo inválido.');
    }
    if ((tipo == TipoMovimientoInventario.venta ||
            tipo == TipoMovimientoInventario.devolucion) &&
        (pedidoId == null || pedidoId!.isEmpty)) {
      throw ArgumentError('Una venta o devolución requiere el ID del pedido.');
    }
  }

  int get existenciasResultantes => existenciasAnteriores + cantidadDelta;

  Map<String, dynamic> toMap() => {
        'tipo': tipo.name,
        'cantidadDelta': cantidadDelta,
        'existenciasAnteriores': existenciasAnteriores,
        'existenciasResultantes': existenciasResultantes,
        'pedidoId': pedidoId,
        'usuarioId': usuarioId,
        'motivo': motivo,
        if (fecha != null) 'fecha': Timestamp.fromDate(fecha!),
      };

  factory MovimientoInventario.fromMap(
    Map<String, dynamic> datos, {
    required String id,
    required String productoId,
  }) {
    final movimiento = MovimientoInventario(
      id: id,
      productoId: productoId,
      tipo: TipoMovimientoInventario.values.byName(datos['tipo'] as String),
      cantidadDelta: datos['cantidadDelta'] as int,
      existenciasAnteriores: datos['existenciasAnteriores'] as int,
      pedidoId: datos['pedidoId'] as String?,
      usuarioId: datos['usuarioId'] as String?,
      motivo: datos['motivo'] as String?,
      fecha: fechaDesdeFirestore(datos['fecha']),
    );
    if (datos['existenciasResultantes'] != movimiento.existenciasResultantes) {
      throw const FormatException('El saldo del movimiento es inconsistente.');
    }
    return movimiento;
  }
}
