import 'package:flutter/material.dart';

class CustomTextFeild extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function validator;
  final void Function(String?) onSaved;

  const CustomTextFeild({
    super.key,
    required this.text,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.validator,
    required this.onSaved,
  });

  @override
  State<CustomTextFeild> createState() => _CustomTextFeildState();
}

class _CustomTextFeildState extends State<CustomTextFeild> {
  bool _isPasswordVisible = false;

  _passwordToggle() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText ? !_isPasswordVisible : false,
        keyboardType: widget.keyboardType,
        validator: (value) => widget.validator(value),
        onSaved: widget.onSaved,
        decoration: InputDecoration(
          suffixIcon: widget.obscureText
              ? IconButton(
                  onPressed: _passwordToggle,
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                )
              : null,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          labelText: widget.text,
        ),
      ),
    );
  }
}
