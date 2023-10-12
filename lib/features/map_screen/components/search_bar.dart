import 'package:flutter/material.dart';

class FloatingSearchBar extends StatelessWidget {
  const FloatingSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: MediaQuery.of(context).size.width - 40,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Image.asset(
            'assets/images/vietmap.jpg',
            width: 25,
            height: 25,
          ),
          const SizedBox(width: 10),
          const Text('Nhập từ khoá để tìm kiếm')
        ],
      ),
    );
  }
}
