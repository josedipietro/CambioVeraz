import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown(
      {super.key,
      required this.title,
      required this.value,
      required this.onChange,
      required this.items});

  final String title;
  final T? value;
  final Function(T?) onChange;
  final List<T> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)
              ]),
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<T>(
                    isExpanded: true,
                    underline: Container(),
                    hint: const Text('Seleccionar...'),
                    value: value,
                    items: [
                      for (var item in items)
                        DropdownMenuItem(
                          value: item,
                          child: Text(item.toString()),
                        )
                    ],
                    onChanged: onChange),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
