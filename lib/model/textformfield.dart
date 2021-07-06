import 'package:flutter/material.dart';

class TFFxM extends StatelessWidget {
  TFFxM(this._userName,this.imptyText);

  final TextEditingController _userName;
  final String imptyText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _userName,
          validator: (value) {
            if (value.isEmpty) {
              return '$imptyText can not be empty';
            }

            return null;
          },
          decoration: new InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white,
                    width: 0.0),
                borderRadius:
                    BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey[200],
                    width: 0.0),
                borderRadius:
                    BorderRadius.circular(10)),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.red[300],
                    width: 0.0),
                borderRadius:
                    BorderRadius.circular(10)),
            focusedErrorBorder:
                OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.red[300],
                        width: 0.0),
                    borderRadius: BorderRadius
                        .circular(10)),
            filled: true,
            border: InputBorder.none,
            hintText: imptyText,
          ),
        ),
      ),
    );
  }
}
