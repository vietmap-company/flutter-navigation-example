import 'package:flutter/material.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/features/map_screen/components/category_item.dart';
import '../bloc/bloc.dart';

class CategoryBar extends StatefulWidget {
  const CategoryBar({super.key, this.controller});
  final VietmapController? controller;

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  var categoryPoint = {
    1000: 'Ăn & Uống',
    2000: 'Chỗ ở',
    3000: 'Mua sắm',
    4000: 'Giải trí & Thư giãn',
    5000: 'Thể thao',
    6000: 'Sản xuất - dịch vụ',
    7000: 'Y tế',
    8000: 'Cộng đồng',
    9000: 'Cơ quan - chính quyền',
    10000: 'Xe',
    11000: 'Phương tiện đi lại',
    12000: 'Tên giao lộ',
    13000: 'Giáo dục',
    14000: 'Tôn giáo - nơi thờ phụng',
  };
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: 30,
      child: ListView.builder(
        itemCount: categoryPoint.length,
        itemBuilder: (context, index) => CategoryItem(
            name: categoryPoint[(index + 1) * 1000] ?? '',
            onPressed: () {
              context.read<MapBloc>().add(MapEventGetAddressFromCategory(
                  categoryCode: (index + 1) * 1000,
                  latLng: widget.controller?.cameraPosition?.target));
            },
            catId: (index + 1) * 1000),
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
