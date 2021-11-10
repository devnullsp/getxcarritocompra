import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class Producto {
  String nombre;
  String id;
  int precio;
  Producto(this.nombre, this.id, this.precio);
}

class ProductoEnCarrito {
  Producto producto;
  int cantidad;
  ProductoEnCarrito(this.producto, this.cantidad);
}

List<Producto> listaExistencias = [
  Producto("Articulo 1", "a01", 10),
  Producto("Articulo 2", "a02", 20),
  Producto("Articulo 3", "a03", 30),
  Producto("Articulo 4", "a04", 40),
];

class Carrito {
  static Map<String, ProductoEnCarrito> listaProductos =
      <String, ProductoEnCarrito>{};
  static final total = 0.obs;
  static int unidades = 0;
  static ponerProducto(String id) {
    if (listaProductos[id] == null) {
      listaProductos[id] = ProductoEnCarrito(
          listaExistencias.firstWhere((element) => element.id == id), 0);
    }
    listaProductos[id]!.cantidad++;
    total.value += listaProductos[id]!.producto.precio;
    unidades++;
  }

  static quitarProducto(String id) {
    if (listaProductos[id] == null) {
      return;
    }
    listaProductos[id]!.cantidad--;
    total.value -= listaProductos[id]!.producto.precio;
    unidades--;
    if (listaProductos[id]!.cantidad == 0) {
      listaProductos.remove(id);
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Material App',
        home: Obx(() => Scaffold(
            appBar: AppBar(
              title: Text(
                  'Cesta de compra - Total Prod.: ${Carrito.listaProductos.length} Unidades: ${Carrito.unidades} Total €: ${Carrito.total}'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(child: generarListaProductos()),
                  Expanded(
                      flex: 2,
                      child: DataTable(
                          columns: obtenerColumnas(), rows: obtenerFilas()))
                ],
              ),
            ))));
  }

  ListView generarListaProductos() {
    return ListView.builder(
      itemCount: listaExistencias.length,
      itemBuilder: (_, i) {
        final ele = listaExistencias[i];
        return ListTile(
          title: Text("${ele.id}: ${ele.nombre}"),
          subtitle: Row(
            children: [
              TextButton(
                  onPressed: () {
                    Carrito.ponerProducto(ele.id);
                  },
                  child: const Text("+", style: TextStyle(fontSize: 25))),
              Text(
                  "En carrito: ${Carrito.listaProductos[ele.id]?.cantidad ?? 0}"),
              TextButton(
                  onPressed: () {
                    Carrito.quitarProducto(ele.id);
                  },
                  child: const Text("-", style: TextStyle(fontSize: 25))),
            ],
          ),
        );
      },
    );
  }

  List<DataColumn> obtenerColumnas() {
    return const [
      DataColumn(label: Text("Nombre")),
      DataColumn(label: Text("Precio")),
      DataColumn(label: Text("Cantidad")),
      DataColumn(label: Text("Total")),
    ];
  }

  List<DataRow> obtenerFilas() {
    List<DataRow> lista = [];
    Carrito.listaProductos.forEach((key, value) {
      lista.add(DataRow(cells: [
        DataCell(Text(value.producto.nombre)),
        DataCell(Text(value.producto.precio.toString())),
        DataCell(Text(value.cantidad.toString())),
        DataCell(Text((value.cantidad * value.producto.precio).toString())),
      ]));
    });
    lista.add(DataRow(cells: [
      const DataCell(Text("")),
      const DataCell(Text("TOTAL:")),
      DataCell(Text(Carrito.unidades.toString())),
      DataCell(Text(Carrito.total.toString())),
    ]));
    return lista;
  }
}
